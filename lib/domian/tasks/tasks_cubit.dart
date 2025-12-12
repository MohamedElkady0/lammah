import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/function/firestore_tasks_service.dart';
import 'package:lammah/data/model/private_task%20.dart';

import 'package:lammah/data/model/public_task.dart';
import 'package:lammah/data/service/database_helper.dart'; // للـ SQLite

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final DatabaseHelper _localDb = DatabaseHelper.instance;
  final FirestoreTasksService _firestoreService = FirestoreTasksService();

  TasksCubit() : super(TasksInitial());

  // --- مهام خاصة (SQLite) ---
  Future<void> loadPrivateTasks() async {
    emit(TasksLoading());
    try {
      // 1. استخدام _localDb هنا
      final tasks = await _localDb.getAllPrivateTasks();

      // يجب إضافة حالة PrivateTasksLoaded في ملف tasks_state.dart
      emit(PrivateTasksLoaded(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  // قمنا بتعديل الدالة لتستقبل الكائن كاملاً
  Future<void> addPrivateTask(PrivateTask task) async {
    try {
      // 2. استخدام _localDb هنا
      await _localDb.insertPrivateTask(task);
      await loadPrivateTasks(); // إعادة التحميل لتحديث الواجهة
    } catch (e) {
      emit(TasksError("فشل إضافة المهمة: $e"));
    }
  }

  Future<void> toggleTaskStatus(String id, bool isCompleted) async {
    await _localDb.updatePrivateTaskStatus(id, isCompleted);
    await loadPrivateTasks();
  }

  // --- مهام عامة (Firestore) ---

  // دالة لإضافة مهمة عامة
  Future<void> postPublicTask(PublicTask task) async {
    try {
      await _firestoreService.addPublicTask(task);
      // لا نحتاج لـ emit هنا لأننا سنستخدم StreamBuilder في الواجهة
    } catch (e) {
      emit(TasksError("فشل نشر المهمة: $e"));
    }
  }

  // دالة لتقديم عرض سعر
  Future<void> submitOffer(String taskId, TaskOffer offer) async {
    try {
      await _firestoreService.submitOffer(taskId, offer);
    } catch (e) {
      emit(TasksError("فشل تقديم العرض: $e"));
    }
  }

  // دالة قبول العرض
  Future<void> acceptTaskOffer(String taskId, String offerId) async {
    try {
      await _firestoreService.acceptOffer(taskId, offerId);
    } catch (e) {
      emit(TasksError("فشل قبول العرض: $e"));
    }
  }

  Future<void> rateWorker(String userId, double rating) async {
    try {
      // استدعاء الخدمة التي أنشأناها
      await _firestoreService.rateUser(userId, rating);
      // يمكنك إضافة emit لرسالة نجاح إذا أردت، أو تركها صامتة
    } catch (e) {
      emit(TasksError("فشل تقديم التقييم: $e"));
    }
  }
}
