import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lammah/fetcher/data/model/user_info.dart';

class AuthCacheService {
  static const String _userCacheKey = 'cached_user_data';

  Future<void> saveUserData(UserInfoData userInfo) async {
    final prefs = await SharedPreferences.getInstance();

    final userJsonString = jsonEncode(userInfo.toJson());

    await prefs.setString(_userCacheKey, userJsonString);
  }

  Future<UserInfoData?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString(_userCacheKey);

    if (userJsonString != null) {
      final userJsonMap = jsonDecode(userJsonString) as Map<String, dynamic>;

      return UserInfoData.fromJson(userJsonMap);
    }
    return null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
  }
}
