import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

enum UserRole {
  member,
  trainer,
  owner,
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserRole? _currentRole;
  String? _fullName;
  String? _email;
  bool _isLoading = false;

  UserRole? get currentRole => _currentRole;
  String? get fullName => _fullName;
  String? get email => _email;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentRole != null;

  // Initialize and load session if access token exists
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken != null) {
        final response = await ApiClient().get('/api/auth/me/');
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['success'] == true) {
            final data = body['data'];
            _fullName = data['full_name'];
            _email = data['email'];
            _currentRole = _mapStringToRole(data['role']);
          } else {
            await clearSession();
          }
        } else {
          await clearSession();
        }
      }
    } catch (_) {
      await clearSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login operation
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient().post('/api/auth/login/', {
        'email': email,
        'password': password,
      }, requireAuth: false);

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        
        final user = data['user'];
        _fullName = user['full_name'];
        _email = user['email'];
        _currentRole = _mapStringToRole(user['role']);
        
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        notifyListeners();
        return body['message'] ?? 'Invalid email or password.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Login Error: $e';
    }
  }

  // Register operation
  Future<String?> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient().post('/api/auth/register/', {
        'full_name': fullName,
        'username': username.isNotEmpty ? username : email.split('@')[0],
        'email': email,
        'password': password,
        'phone_number': '',
        'role': role.toUpperCase(),
      }, requireAuth: false);

      final body = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201 && body['success'] == true) {
        return null; // Success
      } else {
        if (body['errors'] != null && body['errors'] is List && (body['errors'] as List).isNotEmpty) {
          final firstErr = body['errors'][0];
          if (firstErr is Map && firstErr.containsKey('message')) {
            return firstErr['message'];
          }
        }
        return body['message'] ?? 'Registration failed.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Registration Error: $e';
    }
  }

  // Logout operation
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken != null) {
        await ApiClient().post('/api/auth/logout/', {
          'refresh': refreshToken,
        });
      }
    } catch (_) {}

    await clearSession();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _currentRole = null;
    _fullName = null;
    _email = null;
  }

  UserRole? _mapStringToRole(String? roleStr) {
    if (roleStr == null) return null;
    switch (roleStr.toUpperCase()) {
      case 'OWNER':
        return UserRole.owner;
      case 'TRAINER':
        return UserRole.trainer;
      case 'MEMBER':
        return UserRole.member;
      default:
        return null;
    }
  }
}

// Global singleton instance
final AuthService authService = AuthService();
