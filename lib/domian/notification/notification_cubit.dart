import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/service/notification_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;

  NotificationCubit(this._notificationService) : super(NotificationInitial());

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    try {
      emit(NotificationLoading());

      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String finalPayload = payload ?? 'task_id_$id';

      await _notificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDateTime: scheduledDateTime,
        payload: finalPayload,
      );

      emit(NotificationScheduledSuccess(id));
    } catch (e) {
      emit(NotificationError("فشل في جدولة الإشعار: ${e.toString()}"));
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      emit(NotificationLoading());
      await _notificationService.cancelAllNotifications();
      emit(NotificationCancelledSuccess());
    } catch (e) {
      emit(NotificationError("فشل في إلغاء الإشعارات: ${e.toString()}"));
    }
  }

  Future<void> requestPermissions() async {
    try {
      await _notificationService.requestPermissions();

      emit(const NotificationPermissionState(true));
    } catch (e) {
      emit(const NotificationPermissionState(false));
      emit(NotificationError("حدث خطأ أثناء طلب الأذونات: ${e.toString()}"));
    }
  }
}
