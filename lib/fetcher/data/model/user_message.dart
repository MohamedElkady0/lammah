import 'package:lammah/fetcher/data/model/user_info.dart';

class UserMessage {
  final String message;

  final bool isMe;
  final DateTime time;
  final UserInfoData userInfo;
  final String chatId;
  final String chatRoom;
  final DateTime lastMessageTime;
  final bool isOnline;

  UserMessage({
    required this.message,
    required this.isMe,
    required this.time,
    required this.userInfo,
    required this.chatId,
    required this.chatRoom,
    required this.lastMessageTime,
    required this.isOnline,
  });

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
      message: json['message'],
      chatId: json['uid'],
      isMe: json['isMe'],
      time: json['time'],
      userInfo: UserInfoData.fromJson(json['userInfo']),

      chatRoom: json['chatRoom'],
      lastMessageTime: json['lastMessageTime'],
      isOnline: json['isOnline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'uid': chatId,
      'isMe': isMe,
      'time': time,
      'userInfo': userInfo.toJson(),
      'chatRoom': chatRoom,
      'lastMessageTime': lastMessageTime,
      'isOnline': isOnline,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserMessage &&
        other.message == message &&
        other.isMe == isMe &&
        other.time == time &&
        other.userInfo == userInfo &&
        other.chatId == chatId &&
        other.chatRoom == chatRoom &&
        other.lastMessageTime == lastMessageTime &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        isMe.hashCode ^
        time.hashCode ^
        userInfo.hashCode ^
        chatId.hashCode ^
        chatRoom.hashCode ^
        lastMessageTime.hashCode ^
        isOnline.hashCode;
  }

  UserMessage copyWith({
    String? message,
    bool? isMe,
    DateTime? time,
    UserInfoData? userInfo,
    String? chatId,
    String? chatRoom,
    DateTime? lastMessageTime,
    bool? isOnline,
  }) {
    return UserMessage(
      message: message ?? this.message,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      userInfo: userInfo ?? this.userInfo,
      chatId: chatId ?? this.chatId,
      chatRoom: chatRoom ?? this.chatRoom,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  UserMessage.fromUserInfoData(UserMessage userMessage)
    : message = userMessage.message,
      isMe = userMessage.isMe,
      time = userMessage.time,
      userInfo = userMessage.userInfo,
      chatId = userMessage.chatId,
      chatRoom = userMessage.chatRoom,
      lastMessageTime = userMessage.lastMessageTime,
      isOnline = userMessage.isOnline;
}
