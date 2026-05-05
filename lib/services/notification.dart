import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static int? userId;
  static String? name;
  static String? email;

  static Future<void> saveUser({
    required int id,
    required String name,
    required String email,
  }) async {
    userId = id;
    UserSession.name = name;
    UserSession.email = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
  }

  static Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt('user_id');
    name = prefs.getString('user_name');
    email = prefs.getString('user_email');
  }

  static bool isLoggedIn() {
    return userId != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    userId = null;
    name = null;
    email = null;
  }
}