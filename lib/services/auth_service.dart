
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static const String _loginKey = 'isLogin';

  // Fungsi registrasi
  static Future<bool> register(
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_loginKey, true);

    return true;
  }

  // Fungsi login
  static Future<bool> login(
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString(_emailKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (email == savedEmail && password == savedPassword) {
      await prefs.setBool(_loginKey, true);
      return true;
    }

    return false;
  }

  // Memeriksa status login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_loginKey) ?? false;
  }

  // Mengambil email pengguna
  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_emailKey) ?? '';
  }

  // Fungsi logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_loginKey, false);
  }
}
