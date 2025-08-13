//import 'package:lammah/fetcher/data/model/user_message.dart';

class UserInfoData {
  String? userId;
  String? name;
  String? email;
  String? phoneNumber;
  String? image;
  List<String>? friends;
  String? userPlace;
  String? userCity;
  String? userCountry;
  // UserMessage? userMessage;

  UserInfoData({
    // this.userMessage,
    this.userId,
    this.name,
    this.email,
    this.phoneNumber,
    this.image,
    this.friends,
    this.userPlace,
    this.userCity,
    this.userCountry,
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
    // userMessage: json['userMessage'] != null
    // ? UserMessage.fromJson(json['userMessage'])
    // : null,
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
    // 'userMessage': userMessage?.toJson(),
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
        other.userCountry == userCountry;
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
        userCountry.hashCode;
    // userMessage.hashCode;
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
      userCountry = userInfoData.userCountry;
}
