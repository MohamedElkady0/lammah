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
    // قمنا بتغيير الإصدار إلى 2 لإجبار التحديث
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // لاحظ تغيير version إلى 2
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
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
    await db.execute('''
    CREATE TABLE notes(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT,
      date TEXT NOT NULL
    )
    ''');

    // 3. جدول المهام الخاصة (الجديد)
    await db.execute('''
    CREATE TABLE private_tasks(
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      isCompleted INTEGER NOT NULL,
      deadline TEXT NOT NULL
    )
    ''');

    await db.execute('''
  CREATE TABLE budgets(
    categoryId TEXT PRIMARY KEY,
    limitAmount REAL NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE recurring_transactions(
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    amount REAL NOT NULL,
    categoryId TEXT NOT NULL,
    dayOfMonth INTEGER NOT NULL, -- يوم التكرار (مثلاً يوم 1 في الشهر)
    lastProcessedDate TEXT -- آخر مرة تم فيها إنشاء المعاملة
  )
''');
  }

  // التعامل مع تحديث التطبيق للمستخدمين الحاليين
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE private_tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        deadline TEXT NOT NULL
      )
      ''');
    }
  }

  // ==========================================================
  // 1. عمليات الملاحظات (Notes)
  // ==========================================================
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesForDay(DateTime date) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().substring(0, 10);

    // تصحيح: استخدام SUBSTR بدلاً من المطابقة التامة لتجاهل الوقت
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
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> deleteNote(String id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================
  // 2. عمليات المهام الخاصة (Private Tasks) - الإضافة الجديدة
  // ==========================================================
  Future<int> insertPrivateTask(PrivateTask task) async {
    final db = await instance.database;
    return await db.insert('private_tasks', task.toMap());
  }

  Future<List<PrivateTask>> getAllPrivateTasks() async {
    final db = await instance.database;
    final maps = await db.query('private_tasks', orderBy: 'deadline ASC');
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => PrivateTask.fromMap(maps[i]));
  }

  // دالة لتحديث حالة المهمة (اكتملت / لم تكتمل)
  Future<int> updatePrivateTaskStatus(String id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'private_tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePrivateTask(String id) async {
    final db = await instance.database;
    return await db.delete('private_tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================
  // 3. عمليات المعاملات (Transactions)
  // ==========================================================
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

  Future<List<Transaction>> getTransactionsForDay(
    DateTime date,
    List<Category> allCategories,
  ) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'transactions',
      where: 'SUBSTR(date, 1, 10) = ?',
      whereArgs: [dateString],
    );

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

  // ==========================================================
  // 4. دالة التقويم الشاملة (لليوم المحدد)
  // ==========================================================
  Future<List<dynamic>> getEventsForDay(
    DateTime day,
    List<Category> allCategories,
  ) async {
    // توحيد التاريخ ليكون UTC لتجنب مشاكل المناطق الزمنية
    final dateOnly = DateTime.utc(day.year, day.month, day.day);

    // أ. جلب الملاحظات
    final notes = await getNotesForDay(dateOnly);

    // ب. جلب المعاملات
    final transactions = await getTransactionsForDay(dateOnly, allCategories);

    // ج. جلب المهام الخاصة التي موعدها اليوم (إضافة جديدة)
    final db = await instance.database;
    final dateString = dateOnly.toIso8601String().substring(0, 10);
    final taskMaps = await db.query(
      'private_tasks',
      where: 'SUBSTR(deadline, 1, 10) = ?',
      whereArgs: [dateString],
    );
    final tasks = List.generate(
      taskMaps.length,
      (i) => PrivateTask.fromMap(taskMaps[i]),
    );

    // دمج الكل
    return [...notes, ...transactions, ...tasks];
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
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
  Future<List<Map<String, dynamic>>> getRecurringTransactions() async {
    final db = await instance.database;
    return await db.query('recurring_transactions');
  }

  Future<void> insertRecurringTransaction(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('recurring_transactions', data);
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
}
