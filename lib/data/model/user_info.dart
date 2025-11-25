//import 'package:lammah/fetcher/data/model/user_message.dart';

import 'package:equatable/equatable.dart';

class UserInfoData extends Equatable {
  final String? userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? image;
  final List<String>? friends;
  final String? userPlace;
  final String? userCity;
  final String? userCountry;
  final int? points;
  final int? adsCount;
  final String? language;
  final String? fcmToken;
  final List<String>? friendRequestsSent;
  final List<String>? friendRequestsReceived;
  final List<String>? blockedUsers;
  final String? latitude;
  final String? longitude;

  const UserInfoData({
    this.latitude,
    this.longitude,
    this.friendRequestsSent,
    this.friendRequestsReceived,
    this.blockedUsers,
    this.fcmToken,
    this.userId,
    this.name,
    this.email,
    this.phoneNumber,
    this.image,
    this.friends,
    this.userPlace,
    this.userCity,
    this.userCountry,
    this.points,
    this.adsCount,
    this.language,
  });
  factory UserInfoData.fromJson(Map<String, dynamic> json) => UserInfoData(
    userId: json['userId'],
    name: json['name'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    image: json['image'],
    friends: List<String>.from(json['friends'] ?? []),
    userPlace: json['userPlace'],
    userCity: json['userCity'],
    userCountry: json['userCountry'],
    points: json['points'],
    adsCount: json['adsCount'],
    language: json['language'],
    fcmToken: json['fcmToken'],
    friendRequestsSent: List<String>.from(json['friendRequestsSent'] ?? []),
    friendRequestsReceived: List<String>.from(
      json['friendRequestsReceived'] ?? [],
    ),
    blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
    latitude: json['latitude'],
    longitude: json['longitude'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'image': image,
    'friends': friends,
    'userPlace': userPlace,
    'userCity': userCity,
    'userCountry': userCountry,
    'points': points,
    'adsCount': adsCount,
    'language': language,
    'fcmToken': fcmToken,
    'friendRequestsSent': friendRequestsSent,
    'friendRequestsReceived': friendRequestsReceived,
    'blockedUsers': blockedUsers,
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfoData &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.image == image &&
        other.friends == friends &&
        other.userPlace == userPlace &&
        other.userCity == userCity &&
        other.userCountry == userCountry &&
        other.points == points &&
        other.adsCount == adsCount &&
        other.fcmToken == fcmToken &&
        other.language == language &&
        other.friendRequestsSent == friendRequestsSent &&
        other.friendRequestsReceived == friendRequestsReceived &&
        other.blockedUsers == blockedUsers &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        image.hashCode ^
        friends.hashCode ^
        userPlace.hashCode ^
        userCity.hashCode ^
        userCountry.hashCode ^
        points.hashCode ^
        adsCount.hashCode ^
        fcmToken.hashCode ^
        language.hashCode ^
        friendRequestsSent.hashCode ^
        friendRequestsReceived.hashCode ^
        blockedUsers.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }

  UserInfoData copyWith({
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? image,
    List<String>? friends,
    String? userPlace,
    String? userCity,
    String? userCountry,
    int? points,
    int? adsCount,
    String? language,
    String? fcmToken,
    List<String>? friendRequestsSent,
    List<String>? friendRequestsReceived,
    List<String>? blockedUsers,
    String? latitude,
    String? longitude,
  }) {
    return UserInfoData(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      image: image ?? this.image,
      friends: friends ?? this.friends,
      userPlace: userPlace ?? this.userPlace,
      userCity: userCity ?? this.userCity,
      userCountry: userCountry ?? this.userCountry,
      points: points ?? this.points,
      adsCount: adsCount ?? this.adsCount,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
      friendRequestsSent: friendRequestsSent ?? this.friendRequestsSent,
      friendRequestsReceived:
          friendRequestsReceived ?? this.friendRequestsReceived,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  UserInfoData.fromUserInfoData(UserInfoData userInfoData) //this.userMessage
    : userId = userInfoData.userId,

      name = userInfoData.name,
      email = userInfoData.email,
      phoneNumber = userInfoData.phoneNumber,
      image = userInfoData.image,
      friends = List<String>.from(userInfoData.friends ?? []),
      userPlace = userInfoData.userPlace,
      userCity = userInfoData.userCity,
      userCountry = userInfoData.userCountry,
      points = userInfoData.points,
      adsCount = userInfoData.adsCount,
      fcmToken = userInfoData.fcmToken,
      language = userInfoData.language,
      friendRequestsSent = List<String>.from(
        userInfoData.friendRequestsSent ?? [],
      ),
      friendRequestsReceived = List<String>.from(
        userInfoData.friendRequestsReceived ?? [],
      ),

      blockedUsers = List<String>.from(userInfoData.blockedUsers ?? []),
      latitude = userInfoData.latitude,
      longitude = userInfoData.longitude;

  @override
  List<Object?> get props => [userId, name];
}
