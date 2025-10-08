import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/fetcher/data/model/category.dart';
import 'package:lammah/fetcher/data/model/note.dart';
import 'package:lammah/fetcher/data/model/transaction.dart';
import 'package:lammah/fetcher/data/service/database_helper.dart';

import 'package:uuid/uuid.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final dbHelper = DatabaseHelper.instance;

  // في تطبيق حقيقي، هذه ستُقرأ من جدول "categories" في قاعدة البيانات
  final List<Category> _availableCategories = defaultCategories;

  TransactionCubit() : super(TransactionInitial()) {
    // استدعاء تحميل البيانات فورًا عند إنشاء الـ Cubit
    loadInitialData();
  }

  // دالة واحدة لتحميل كل شيء في البداية
  Future<void> loadInitialData() async {
    emit(TransactionLoading());
    try {
      // ١. جلب كل المعاملات
      final allTransactions = await dbHelper.getAllTransactions(
        _availableCategories,
      );

      // ٢. جلب كل الملاحظات (هذا هو الجزء الذي كان يُتجاهل)
      final allNotes = await dbHelper.getAllNotes();

      // ٣. تمرير كلتا القائمتين للدالة التالية (هذا هو الإصلاح الحاسم)
      _recalculateAndEmitState(allTransactions, allNotes);
    } catch (e) {
      emit(TransactionError("فشل في تحميل البيانات: ${e.toString()}"));
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    await dbHelper.deleteTransaction(transactionId);
    // أعد تحميل كل شيء لتحديث الواجهة (الرصيد، القائمة، نقاط التقويم)
    await loadInitialData();
  }

  Future<void> deleteNote(String noteId) async {
    await dbHelper.deleteNote(noteId);
    // أعد تحميل كل شيء لتحديث الواجهة
    await loadInitialData();
  }

  // هذه الدالة ستصبح مركزية. أي تغيير في البيانات سيستدعيها
  void _recalculateAndEmitState(
    List<Transaction> transactions,
    List<Note> notes,
  ) {
    double currentBalance =
        10000.0; // يمكنك حفظ الرصيد المبدئي في SharedPreferences
    for (var t in transactions) {
      currentBalance += (t.type == TransactionType.income
          ? t.amount
          : -t.amount);
    }
    Map<DateTime, List<dynamic>> events = {};
    final now = DateTime.now();
    final monthlyExpenses = <Category, double>{};
    transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .forEach((t) {
          monthlyExpenses.update(
            t.category,
            (value) => value + t.amount,
            ifAbsent: () => t.amount,
          );
        });

    for (var transaction in transactions) {
      final dayKey = DateTime.utc(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      events.putIfAbsent(dayKey, () => []).add(transaction);
    }

    // أضف الملاحظات إلى نفس الخريطة
    for (var note in notes) {
      final dayKey = DateTime.utc(
        note.date.year,
        note.date.month,
        note.date.day,
      );
      events.putIfAbsent(dayKey, () => []).add(note);
    }

    emit(
      TransactionLoaded(
        transactions: transactions,
        totalBalance: currentBalance, // تأكد من أن متغير الرصيد موجود
        monthlyExpensesByCategory:
            monthlyExpenses, // تأكد من أن متغير المصاريف موجود
        events: events,
      ),
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    await dbHelper.insertTransaction(transaction);
    await loadInitialData(); // أعد تحميل كل شيء لتحديث الواجهة
  }

  Future<void> addNote(Note note) async {
    await dbHelper.insertNote(note);
    await loadInitialData(); // أعد تحميل كل شيء لتحديث الواجهة
  }

  // دالة لجلب تفاصيل يوم واحد عند الضغط عليه في التقويم
  Future<List<dynamic>> getEventsForDay(DateTime day) async {
    return await dbHelper.getEventsForDay(day, _availableCategories);
  }

  // ...

  Future<void> loadTransactions() async {
    emit(TransactionLoading());
    // الآن ستحمل البيانات من قاعدة البيانات
    // final allTransactions = await dbHelper.getAllTransactions();
    // ثم تحسب الرصيد والتحليلات...
    _emitCurrentState(); // ستحتاج لتحديث هذه الدالة لتستخدم DB
  }

  // في تطبيق حقيقي، هذه البيانات ستكون من قاعدة بيانات
  final List<Transaction> _transactions = [];
  double _initialBalance = 10000.0; // الرصيد المبدئي القابل للتعديل

  void _emitCurrentState() {
    // حساب الرصيد الإجمالي
    double currentBalance = _initialBalance;
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        currentBalance += transaction.amount;
      } else {
        currentBalance -= transaction.amount;
      }
    }

    // حساب مصاريف الشهر الحالي حسب الفئة
    final now = DateTime.now();
    final monthlyExpenses = <Category, double>{};
    final monthlyTransactions = _transactions.where(
      (t) =>
          t.type == TransactionType.expense &&
          t.date.month == now.month &&
          t.date.year == now.year,
    );

    for (var transaction in monthlyTransactions) {
      monthlyExpenses.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    emit(
      TransactionLoaded(
        transactions: List.from(_transactions),
        totalBalance: currentBalance,
        monthlyExpensesByCategory: monthlyExpenses,
        events: {},
      ),
    );
  }

  Future<void> loadTransactionsLocal() async {
    emit(TransactionLoading());
    // هنا يمكنك تحميل البيانات من قاعدة بيانات (مثل SharedPreferences, sqflite)
    // الآن سنستخدم بيانات وهمية للتوضيح
    _transactions.addAll(_getMockTransactions());
    _emitCurrentState();
  }

  Future<void> addTransactionLocal(Transaction transaction) async {
    _transactions.add(transaction);
    _emitCurrentState();
  }

  Future<void> setInitialBalance(double newBalance) async {
    _initialBalance = newBalance;
    _emitCurrentState();
  }
}

// قائمة فئات افتراضية
final List<Category> defaultCategories = [
  const Category(
    id: '1',
    name: 'طعام وشراب',
    icon: Icons.fastfood,
    color: Colors.orange,
  ),
  const Category(
    id: '2',
    name: 'مواصلات',
    icon: Icons.directions_car,
    color: Colors.blue,
  ),
  const Category(
    id: '3',
    name: 'فواتير',
    icon: Icons.receipt,
    color: Colors.red,
  ),
  const Category(id: '4', name: 'إيجار', icon: Icons.home, color: Colors.green),
  const Category(
    id: '5',
    name: 'ترفيه',
    icon: Icons.movie,
    color: Colors.purple,
  ),
  const Category(id: '6', name: 'صحة', icon: Icons.healing, color: Colors.pink),
  const Category(
    id: '7',
    name: 'تسوق',
    icon: Icons.shopping_cart,
    color: Colors.teal,
  ),
  const Category(
    id: '8',
    name: 'دخل',
    icon: Icons.attach_money,
    color: Colors.lightGreen,
  ),
];

// بيانات وهمية للبدء
List<Transaction> _getMockTransactions() {
  const uuid = Uuid();
  return [
    Transaction(
      id: uuid.v4(),
      title: 'إيجار شهر مايو',
      amount: 1200,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.expense,
      category: defaultCategories[3], // إيجار
    ),
    Transaction(
      id: uuid.v4(),
      title: 'فاتورة كهرباء',
      amount: 150,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.expense,
      category: defaultCategories[2], // فواتير
    ),
  ];
}
