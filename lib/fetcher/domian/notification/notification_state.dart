part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationScheduledSuccess extends NotificationState {
  final int notificationId;
  const NotificationScheduledSuccess(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class NotificationCancelledSuccess extends NotificationState {}

class NotificationPermissionState extends NotificationState {
  final bool isGranted;
  const NotificationPermissionState(this.isGranted);

  @override
  List<Object> get props => [isGranted];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}
