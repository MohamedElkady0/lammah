import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BackupService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // رفع قاعدة البيانات
  Future<void> backupDatabase(String userId) async {
    try {
      final dbFolder = await getDatabasesPath();
      final dbPath = join(dbFolder, 'app_database.db');
      final file = File(dbPath);

      if (await file.exists()) {
        final ref = _storage.ref().child('backups/$userId/app_database.db');
        await ref.putFile(file);
        print("Backup Completed Successfully");
      }
    } catch (e) {
      print("Backup Failed: $e");
      throw Exception("فشل النسخ الاحتياطي");
    }
  }

  // استعادة قاعدة البيانات
  Future<void> restoreDatabase(String userId) async {
    try {
      final dbFolder = await getDatabasesPath();
      final dbPath = join(dbFolder, 'app_database.db');

      // يجب إغلاق قاعدة البيانات قبل الكتابة عليها
      // DatabaseHelper.instance.close(); (تأكد من وجود دالة close)

      final ref = _storage.ref().child('backups/$userId/app_database.db');
      final file = File(dbPath);

      await ref.writeToFile(file);
      print("Restore Completed Successfully");

      // هنا يجب إعادة تشغيل التطبيق أو إعادة تهيئة DatabaseHelper
    } catch (e) {
      print("Restore Failed: $e");
      throw Exception("فشل الاستعادة");
    }
  }
}
