part of 'chat_cubit.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSuccess extends ChatState {}

class ChatFailure extends ChatState {
  final String errorMessage;
  ChatFailure(this.errorMessage);
}

// حالات سابقة
class FriendRequestStateChanged extends ChatState {
  final bool isFriendRequestSent;
  FriendRequestStateChanged({required this.isFriendRequestSent});
}

class UserBlockedStateChanged extends ChatState {
  final bool isUserBlocked;
  UserBlockedStateChanged({required this.isUserBlocked});
}

class NavChatCall extends ChatState {}

// --- حالات جديدة للجزء الثاني ---

// حالة الانتقال للشات (بعد إنشاء مجموعة مثلاً)
class NavChat extends ChatState {}

// حالات التسجيل الصوتي
class RecordingStateChanged extends ChatState {
  final bool isRecording;
  RecordingStateChanged(this.isRecording);
}

// حالات البحث عن مستخدم عشوائي (Trip/Random Chat)
class FindTripLoading extends ChatState {} // جاري البحث

class TripFoundState extends ChatState {
  final MatchedUser matchedUser;
  TripFoundState(this.matchedUser);
}

class TripNotFoundState extends ChatState {}
