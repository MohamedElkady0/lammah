import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/category.dart';
import 'package:lammah/data/model/note.dart';
import 'package:lammah/data/model/private_task%20.dart';
import 'package:lammah/data/model/transaction.dart';
import 'package:lammah/data/service/database_helper.dart';
import 'package:uuid/uuid.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final dbHelper = DatabaseHelper.instance;

  // الرصيد المبدئي (يفضل حفظه في SharedPreferences لاحقاً ليبقى محفوظاً)
  double _initialBalance = 10000.0;

  final List<Category> _availableCategories = defaultCategories;

  TransactionCubit() : super(TransactionInitial()) {
    loadInitialData();
  }

  // --- دوال التحميل والتحديث ---

  Future<void> loadInitialData() async {
    emit(TransactionLoading());
    try {
      final allTransactions = await dbHelper.getAllTransactions(
        _availableCategories,
      );
      final allNotes = await dbHelper.getAllNotes();

      // 1. جلب المهام الخاصة (الإصلاح هنا)
      final allPrivateTasks = await dbHelper.getAllPrivateTasks();

      // 2. تمرير القوائم الثلاثة للدالة
      _recalculateAndEmitState(allTransactions, allNotes, allPrivateTasks);
      await _processRecurringTransactions();
    } catch (e) {
      emit(TransactionError("فشل في تحميل البيانات: ${e.toString()}"));
    }
  }

  // دالة لتغيير الرصيد المبدئي
  Future<void> setInitialBalance(double newBalance) async {
    _initialBalance = newBalance;
    // هنا يجب حفظ الرصيد الجديد في SharedPreferences إذا كنت تريد استمراره
    // await prefs.setDouble('initial_balance', newBalance);

    // إعادة تحميل البيانات لتحديث الحسابات
    await loadInitialData();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await dbHelper.deleteTransaction(transactionId);
    await loadInitialData();
  }

  Future<void> addNote(Note note) async {
    await dbHelper.insertNote(note);
    await loadInitialData();
  }

  Future<void> deleteNote(String noteId) async {
    await dbHelper.deleteNote(noteId);
    await loadInitialData();
  }

  // --- دوال مساعدة ---

  Future<List<dynamic>> getEventsForDay(DateTime day) async {
    return await dbHelper.getEventsForDay(day, _availableCategories);
  }

  // --- المنطق المركزي للحسابات ---

  void _recalculateAndEmitState(
    List<Transaction> transactions,
    List<Note> notes,
    List<PrivateTask> allPrivateTasks,
  ) {
    // 1. حساب الرصيد بناءً على الرصيد المبدئي للمكعب
    double currentBalance = _initialBalance;

    for (var t in transactions) {
      currentBalance += (t.type == TransactionType.income
          ? t.amount
          : -t.amount);
    }

    // 2. حساب مصاريف الشهر الحالي
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

    // 3. تجهيز أحداث التقويم (Transactions + Notes)
    Map<DateTime, List<dynamic>> events = {};

    // إضافة المعاملات
    for (var transaction in transactions) {
      // استخدام DateUtils أو تطبيع التاريخ لإزالة الوقت (الساعات والدقائق) مهم جداً لمفاتيح الـ Map
      final dayKey = DateTime.utc(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      events.putIfAbsent(dayKey, () => []).add(transaction);
    }

    // إضافة الملاحظات
    for (var note in notes) {
      final dayKey = DateTime.utc(
        note.date.year,
        note.date.month,
        note.date.day,
      );
      events.putIfAbsent(dayKey, () => []).add(note);
    }
    // 3. إضافة المهام الخاصة
    for (var task in allPrivateTasks) {
      final dayKey = DateTime.utc(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      events.putIfAbsent(dayKey, () => []).add(task);
    }

    emit(
      TransactionLoaded(
        transactions: transactions,
        totalBalance: currentBalance,
        monthlyExpensesByCategory: monthlyExpenses,
        events: events,
      ),
    );
  }

  // دالة مساعدة لفحص الميزانية
  Future<void> _checkBudgetAlert(Transaction newTransaction) async {
    if (newTransaction.type == TransactionType.income) return;

    // 1. جلب حد الميزانية لهذه الفئة
    final budgets = await dbHelper.getAllBudgets();
    final limit = budgets[newTransaction.category.id];

    if (limit == null) return; // لا توجد ميزانية محددة لهذه الفئة

    // 2. حساب إجمالي المصاريف الحالية لهذه الفئة في هذا الشهر
    final now = DateTime.now();
    final allTransactions = await dbHelper.getAllTransactions(
      _availableCategories,
    );

    double currentSpent = 0.0;
    for (var t in allTransactions) {
      // لاحظ التغيير هنا 👇
      if (t.category.id == newTransaction.category.id &&
          t.type == TransactionType.expense &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        currentSpent += t.amount;
      }
    }

    // 3. التحقق من النسبة (80%)
    // نضيف المصروف الجديد للمجموع الحالي
    double totalAfterAdd = currentSpent + newTransaction.amount;
    double percentage = (totalAfterAdd / limit);

    if (percentage >= 0.8 && percentage < 1.0) {
      // إرسال تنبيه محلي (تحتاج لاستدعاء NotificationCubit هنا أو استخدام خدمة التنبيهات مباشرة)
      print(
        "تنبيه: لقد استهلكت ${percentage * 100}% من ميزانية ${newTransaction.category.name}",
      );
      // context.read<NotificationCubit>().showLocalNotification(...)
    } else if (percentage >= 1.0) {
      print("تنبيه: لقد تجاوزت ميزانية ${newTransaction.category.name}!");
    }
  }

  // عدل دالة addTransaction لتشمل الفحص
  Future<void> addTransaction(Transaction transaction) async {
    await dbHelper.insertTransaction(transaction);

    // تحقق من الميزانية بعد الإضافة
    await _checkBudgetAlert(transaction);

    await loadInitialData();
  }

  Future<void> _processRecurringTransactions() async {
    final recurringItems = await dbHelper.getRecurringTransactions();
    final now = DateTime.now();

    for (var item in recurringItems) {
      final dayOfMonth = item['dayOfMonth'] as int;
      final lastProcessedStr = item['lastProcessedDate'] as String?;

      // هل جاء يوم الدفع لهذا الشهر؟
      if (now.day >= dayOfMonth) {
        bool shouldAdd = false;

        if (lastProcessedStr == null) {
          shouldAdd = true;
        } else {
          final lastProcessed = DateTime.parse(lastProcessedStr);
          // إذا كان آخر تحديث في شهر سابق، يعني يجب الإضافة لهذا الشهر
          if (lastProcessed.month != now.month ||
              lastProcessed.year != now.year) {
            shouldAdd = true;
          }
        }

        if (shouldAdd) {
          // إنشاء المعاملة تلقائياً
          final newTx = Transaction(
            id: const Uuid().v4(),
            title: "${item['title']} (تلقائي)",
            amount: item['amount'] as double,
            date: DateTime.now(),
            type: TransactionType.expense,
            category: _availableCategories.firstWhere(
              (c) => c.id == item['categoryId'],
            ),
          );

          await dbHelper.insertTransaction(newTx);
          // تحديث تاريخ آخر معالجة لتجنب التكرار في نفس الشهر
          await dbHelper.updateRecurringLastProcessed(
            item['id'],
            DateTime.now(),
          );
        }
      }
    }
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
List<Transaction> getMockTransactions() {
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
