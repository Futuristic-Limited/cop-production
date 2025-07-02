import 'package:shared_preferences/shared_preferences.dart';
import 'package:APHRC_COP/notifiers/profile_photo_notifier.dart';

class SharedPrefsService {
  /// Save current logged-in user's session
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

  /// Save and also cache for last-user avatar
  static Future<void> saveProfilePhotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo_url', url);
    await prefs.setString('last_user_photo_url', url); // cached for next login
  }
// Add near other save/get methods
  static Future<void> saveUserPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', password);
  }

  static Future<String?> getUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_password');
  }

  static Future<void> clearUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_password');
  }

  /// Save last user for "Continue as"
  static Future<void> saveLastUser({required String email, required String userName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_email', email);
    await prefs.setString('last_user_name', userName);
  }
  /// Save last user info (name, email, and photo) for "Continue as" UI
  static Future<void> saveLastUserInfo({
    required String userName,
    required String email,
    required String photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_name', userName);
    await prefs.setString('last_user_email', email);
    await prefs.setString('last_user_photo_url', photoUrl);
  }


  /// Getters for last user info
  static Future<String?> getLastUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_user_email');
  }

  static Future<String?> getLastUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_user_name');
  }

  static Future<String?> getLastUserPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_user_photo_url');
  }

  static Future<void> clearLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_user_email');
    await prefs.remove('last_user_name');
    await prefs.remove('last_user_photo_url');
  }

  /// Individual accessors
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

  /// Logout clears session but keeps last user for quick login
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expires_at');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    await prefs.remove('profile_photo_url');
    await prefs.setBool('is_logged_in', false);

    ProfilePhotoNotifier.profilePhotoUrl.value = '';

  }


  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ProfilePhotoNotifier.profilePhotoUrl.value = '';
  }
}
