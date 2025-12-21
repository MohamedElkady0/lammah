import 'package:lammah/data/model/category.dart';
import 'package:lammah/data/model/private_task%20.dart';
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
    // لاحظ أننا نستخدم النسخة 1 لأنك ستمسح التطبيق
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. جدول المعاملات
    await db.execute('''
    CREATE TABLE transactions(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      type TEXT NOT NULL,
      categoryId TEXT NOT NULL
    )
    ''');

    // 2. جدول الملاحظات
    // ==========================================
    await db.execute('''
    CREATE TABLE notes(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT,
      date TEXT NOT NULL,
      isCompleted INTEGER DEFAULT 0  
    )
    ''');
    // ==========================================

    // 3. جدول المهام الخاصة
    await db.execute('''
    CREATE TABLE private_tasks(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      isCompleted INTEGER NOT NULL,
      deadline TEXT NOT NULL
    )
    ''');

    // 4. جدول الميزانيات
    await db.execute('''
      CREATE TABLE budgets(
        categoryId TEXT PRIMARY KEY,
        limitAmount REAL NOT NULL
      )
    ''');

    // 5. جدول المعاملات المتكررة
    await db.execute('''
      CREATE TABLE recurring_transactions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        dayOfMonth INTEGER NOT NULL,
        lastProcessedDate TEXT
      )
    ''');
  }

  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesForDay(DateTime date) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'notes',
      where: 'SUBSTR(date, 1, 10) = ?',
      whereArgs: [dateString],
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final maps = await db.query('notes', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> deleteNote(String id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // دوال المعاملات ... (كما كانت)
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
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
      final category = allCategories.firstWhere(
        (cat) => cat.id == map['categoryId'],
        orElse: () => defaultCategories[0],
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

  Future<List<dynamic>> getEventsForDay(
    DateTime day,
    List<Category> allCategories,
  ) async {
    final dateOnly = DateTime.utc(day.year, day.month, day.day);
    final notes = await getNotesForDay(dateOnly);

    // جلب المعاملات (تحتاج لكتابة getTransactionsForDay أو استخدام getAll وتصفيتها)
    // للتبسيط سنفترض وجود getTransactionsForDay كما كتبناها سابقاً
    final db = await instance.database;
    final dateString = dateOnly.toIso8601String().substring(0, 10);
    final tMaps = await db.query(
      'transactions',
      where: 'SUBSTR(date, 1, 10) = ?',
      whereArgs: [dateString],
    );

    final transactions = List.generate(tMaps.length, (i) {
      final map = tMaps[i];
      final category = allCategories.firstWhere(
        (cat) => cat.id == map['categoryId'],
        orElse: () => defaultCategories[0],
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

    return [...notes, ...transactions];
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // دوال الميزانية
  Future<int> setCategoryBudget(String categoryId, double limit) async {
    final db = await instance.database;
    return await db.insert('budgets', {
      'categoryId': categoryId,
      'limitAmount': limit,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, double>> getAllBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets');
    final Map<String, double> budgets = {};
    for (var row in result) {
      budgets[row['categoryId'] as String] = row['limitAmount'] as double;
    }
    return budgets;
  }

  // دوال التكرار
  Future<void> insertRecurringTransaction(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('recurring_transactions', data);
  }

  Future<List<Map<String, dynamic>>> getRecurringTransactions() async {
    final db = await instance.database;
    return await db.query('recurring_transactions');
  }

  Future<void> updateRecurringLastProcessed(String id, DateTime date) async {
    final db = await instance.database;
    await db.update(
      'recurring_transactions',
      {'lastProcessedDate': date.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // دوال المهام الخاصة
  Future<int> insertPrivateTask(PrivateTask task) async {
    final db = await instance.database;
    return await db.insert('private_tasks', task.toMap());
  }

  Future<List<PrivateTask>> getAllPrivateTasks() async {
    final db = await instance.database;
    final maps = await db.query('private_tasks', orderBy: 'deadline ASC');
    return List.generate(maps.length, (i) => PrivateTask.fromMap(maps[i]));
  }

  Future<int> updatePrivateTaskStatus(String id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'private_tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================================

  // 1. دالة الحذف
  Future<int> deletePrivateTask(String id) async {
    final db = await instance.database;
    return await db.delete('private_tasks', where: 'id = ?', whereArgs: [id]);
  }

  // 2. دالة التعديل
  Future<int> updatePrivateTask(PrivateTask task) async {
    final db = await instance.database;
    return await db.update(
      'private_tasks',
      task.toMap(), // تأكد أن الموديل يحتوي على toMap
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
