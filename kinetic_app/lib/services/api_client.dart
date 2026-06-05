import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders(requireAuth: requireAuth);
    
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.get(url, headers: retryHeaders);
      }
    }
    return response;
  }

  Future<http.Response> post(String path, Map<String, dynamic> body, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final jsonBody = jsonEncode(body);

    var response = await http.post(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.post(url, headers: retryHeaders, body: jsonBody);
      }
    }
    return response;
  }

  Future<bool> _attemptTokenRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/api/auth/token/refresh/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newAccess = data['data']['access'];
          await prefs.setString('access_token', newAccess);
          return true;
        }
      }
    } catch (_) {}

    // Refresh failed, clear session
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    return false;
  }
}
