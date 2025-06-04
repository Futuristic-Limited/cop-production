import 'package:shared_preferences/shared_preferences.dart';

class SaveAccessTokenService {
  static const _tokenKey = 'access_token';
  static const _buddyBossTokenKey = 'buddy_boss_token';
  static const _loginStatusKey = 'is_logged_in';
  static const _userIdKey = 'user_id';

  // Save the access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_loginStatusKey, true); // Set isLoggedIn to true
  }

  static Future<void> saveBuddyBossToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_buddyBossTokenKey, token);
  }

  static Future<String?> getBuddyToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_buddyBossTokenKey);
  }

  // Get the access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear the access token and login status on logout
  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.setBool(_loginStatusKey, false); // Set isLoggedIn to false
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStatusKey) ?? false;
  }
}
