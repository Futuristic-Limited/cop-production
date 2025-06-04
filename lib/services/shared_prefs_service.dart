import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static Future<void> saveUserSession({
    required String accessToken,
    required String refreshToken,
    required String tokenExpiresAt,
    required String userName,
    required String userId,
    required String buddyBossToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('token_expires_at', tokenExpiresAt);
    await prefs.setString('user_name', userName);
    await prefs.setString('user_id', userId);
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('buddy_boss_token', buddyBossToken);
  }

  static Future<void> saveProfilePhotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo_url', url);
  }

  static Future<String?> getBuddyBossToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('buddy_boss_token');
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<String?> getProfilePhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_photo_url');
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// logout handler
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expires_at');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    await prefs.remove('is_logged_in');
    await prefs.remove('profile_photo_url');
  }
}
