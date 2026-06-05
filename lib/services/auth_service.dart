import 'package:flutter/material.dart';

enum UserRole {
  member,
  trainer,
  owner,
}

class AuthService extends ChangeNotifier {
  UserRole? _currentRole;

  UserRole? get currentRole => _currentRole;

  bool get isAuthenticated => _currentRole != null;

  void login(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void logout() {
    _currentRole = null;
    notifyListeners();
  }
}

// Singleton instance for simplicity in this mock
final AuthService authService = AuthService();
