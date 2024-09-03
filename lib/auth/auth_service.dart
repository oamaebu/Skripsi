import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  bool _loggedIn = false;
  String? _username;

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (_loggedIn) {
      _username = prefs.getString('username');
    }
  }

  Future<bool> isLoggedIn() async {
    await init(); // Initialize login state
    return _loggedIn;
  }

  Future<String?> getUsername() async {
    await init(); // Initialize login state
    return _username;
  }

  Future<bool> login(String username, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulating async operation
    if (password == '12345') {
      _loggedIn = true;
      _username = username;
      // Save login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    _loggedIn = false;
    _username = null;
  }
}
