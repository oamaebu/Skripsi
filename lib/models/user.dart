import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart';

class UserModel with ChangeNotifier {
  String? _username;
  final AuthService _authService = AuthService();

  String? get username => _username;
  AuthService get authService => _authService;

  UserModel() {
    // Initialize AuthService
    _authService.init().then((_) {
      notifyListeners();
    });
  }

  Future<bool> checkLoginStatus(BuildContext context) async {
    print('Checking login status...');
    bool isLoggedIn = await authService.isLoggedIn();
    print('Is logged in: $isLoggedIn');

    return isLoggedIn;
  }

  Future<void> login(
      String username, String password, BuildContext context) async {
    bool success = await _authService.login(username, password);
    if (success) {
      _username = username;
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/profilanak');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid username or password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _username = null;
    notifyListeners();
  }
}
