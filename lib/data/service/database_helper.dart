import 'package:lammah/data/model/category.dart';
import 'package:lammah/data/model/transaction.dart';
import 'package:lammah/data/model/note.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // ========== التعديل هنا ==========
    await db.execute('''
    CREATE TABLE transactions(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,      -- هذا هو العمود الصحيح للمبلغ
      date TEXT NOT NULL,
      type TEXT NOT NULL,
      categoryId TEXT NOT NULL   -- هذا هو العمود الصحيح لمعرف دافئة
    )
    ''');

    await db.execute('''
    CREATE TABLE notes(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT,
      date TEXT NOT NULL
    )
    ''');
  }

  // --- عمليات الملاحظات (Notes) ---
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesForDay(DateTime date) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final maps = await db.query(
      'notes',
      where: 'date = ?',
      whereArgs: [dateString],
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  // --- عمليات المعاملات (Transactions) ---
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    // الآن هذه الدالة ستعمل بدون أخطاء
    return await db.insert('transactions', transaction.toMapForDb());
  }

  Future<List<Transaction>> getAllTransactions(
    List<Category> allCategories,
  ) async {
    final db = await instance.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      final map = maps[i];
      // ابحث عن الفئة المطابقة للـ categoryId
      final category = allCategories.firstWhere(
        (cat) => cat.id == map['categoryId'],
        orElse: () => defaultCategories[0], // فئة افتراضية في حالة عدم العثور
      );

      return Transaction(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: map['amount'] as double,
        date: DateTime.parse(map['date'] as String),
        type: (map['type'] as String) == TransactionType.income.name
            ? TransactionType.income
            : TransactionType.expense,
        category: category,
      );
    });
  }

  Future<List<Transaction>> getTransactionsForDay(
    DateTime date,
    List<Category> allCategories, // تحتاج إلى قائمة الفئات لربط البيانات
  ) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'transactions',
      where: 'SUBSTR(date, 1, 10) = ?',
      whereArgs: [dateString],
    );

    if (maps.isEmpty) return [];

    // نفس منطق الربط الموجود في getAllTransactions
    return List.generate(maps.length, (i) {
      final map = maps[i];
      final category = allCategories.firstWhere(
        (cat) => cat.id == map['categoryId'],
        orElse: () => defaultCategories[0], // فئة احتياطية
      );

      return Transaction(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: map['amount'] as double,
        date: DateTime.parse(map['date'] as String),
        type: (map['type'] as String) == TransactionType.income.name
            ? TransactionType.income
            : TransactionType.expense,
        category: category,
      );
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<dynamic>> getEventsForDay(
    DateTime day,
    List<Category> allCategories,
  ) async {
    // استخدم .toUtc() لضمان تطابق التواريخ بدون تأثير المنطقة الزمنية
    final dateOnly = DateTime.utc(day.year, day.month, day.day);

    // ١. جلب الملاحظات لهذا اليوم
    final notes = await getNotesForDay(dateOnly);
    print("Found ${notes.length} notes for $dateOnly"); // <-- أضف هذا للتحقق

    // ٢. جلب المعاملات لهذا اليوم
    final transactions = await getTransactionsForDay(dateOnly, allCategories);
    print(
      "Found ${transactions.length} transactions for $dateOnly",
    ); // <-- أضف هذا للتحقق

    // ٣. دمج القائمتين
    return [...notes, ...transactions];
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final maps = await db.query('notes', orderBy: 'date DESC');
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> deleteNote(String id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
