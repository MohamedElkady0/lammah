part of 'chat_cubit.dart';

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatSuccess extends ChatState {}

class ChatLoading extends ChatState {}

class ChatFailure extends ChatState {
  final String errorMessage;

  ChatFailure(this.errorMessage);
}

class FriendRequestStateChanged extends ChatState {
  final bool isFriendRequestSent;

  FriendRequestStateChanged({required this.isFriendRequestSent});
}

class MessageSentState extends ChatState {
  final bool isMessageSent;

  MessageSentState({required this.isMessageSent});
}

class NavChat extends ChatState {
  NavChat();
}

class NavChatCall extends ChatState {
  NavChatCall();
}

class UserBlockedStateChanged extends ChatState {
  final bool isUserBlocked;

  UserBlockedStateChanged({required this.isUserBlocked});
}

class RecordingStateChanged extends ChatState {
  final bool isRecording;

  RecordingStateChanged(this.isRecording);
}
