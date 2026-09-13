import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static late SharedPreferences _prefs;
  
  static String get apiBaseUrl => 
      _prefs.getString('api_base_url') ?? 'https://artisan-ai-backend-eb1c.onrender.com/api';
  
  static String get userId => _prefs.getString('user_id') ?? '';
  static String get authToken => _prefs.getString('auth_token') ?? '';
  static String get userLanguage => _prefs.getString('user_language') ?? 'en';
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static Future<void> setApiBaseUrl(String url) async {
    await _prefs.setString('api_base_url', url);
  }
  
  static Future<void> setAuth(String userId, String token) async {
    await _prefs.setString('user_id', userId);
    await _prefs.setString('auth_token', token);
  }
  
  static Future<void> setUserLanguage(String lang) async {
    await _prefs.setString('user_language', lang);
  }
  
  static Future<void> clearAuth() async {
    await _prefs.remove('user_id');
    await _prefs.remove('auth_token');
  }
  
  static bool get isAuthenticated => authToken.isNotEmpty;
}
