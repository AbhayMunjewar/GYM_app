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
        // We are using `adb reverse tcp:8000 tcp:8000` to tunnel the connection
        // directly from the phone to the laptop via USB. This makes the connection lightning fast!
        // It also bypasses the Windows Defender Firewall.
        return 'http://127.0.0.1:8000';
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

  // ---- GYM APIs ----
  Future<http.Response> createGym(Map<String, dynamic> data) async {
    return post('/api/gyms/', data);
  }

  Future<http.Response> getGyms() async {
    return get('/api/gyms/');
  }

  Future<http.Response> updateGym(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/gyms/$id/');
    final headers = await _getHeaders(requireAuth: true);
    final jsonBody = jsonEncode(data);

    var response = await http.patch(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.patch(url, headers: retryHeaders, body: jsonBody);
      }
    }
    return response;
  }

  Future<http.Response> deleteGym(String id) async {
    final url = Uri.parse('$baseUrl/api/gyms/$id/');
    final headers = await _getHeaders(requireAuth: true);

    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.delete(url, headers: retryHeaders);
      }
    }
    return response;
  }

  // ---- MEMBER APIs ----
  Future<http.Response> getMembers({String query = ''}) async {
    return get('/api/members/?$query');
  }

  Future<http.Response> createMember(Map<String, dynamic> data) async {
    return post('/api/members/', data);
  }

  Future<http.Response> updateMember(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/members/$id/');
    final headers = await _getHeaders(requireAuth: true);
    final jsonBody = jsonEncode(data);

    var response = await http.patch(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.patch(url, headers: retryHeaders, body: jsonBody);
      }
    }
    return response;
  }

  Future<http.Response> deleteMember(String id) async {
    final url = Uri.parse('$baseUrl/api/members/$id/');
    final headers = await _getHeaders(requireAuth: true);

    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.delete(url, headers: retryHeaders);
      }
    }
    return response;
  }

  // ---- MEMBERSHIP PLANS APIs ----
  Future<http.Response> getMembershipPlans({String query = ''}) async {
    return get('/api/memberships/plans/?$query');
  }

  Future<http.Response> createMembershipPlan(Map<String, dynamic> data) async {
    return post('/api/memberships/plans/', data);
  }

  Future<http.Response> updateMembershipPlan(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/memberships/plans/$id/');
    final headers = await _getHeaders(requireAuth: true);
    final jsonBody = jsonEncode(data);

    var response = await http.patch(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.patch(url, headers: retryHeaders, body: jsonBody);
      }
    }
    return response;
  }

  Future<http.Response> deleteMembershipPlan(String id) async {
    final url = Uri.parse('$baseUrl/api/memberships/plans/$id/');
    final headers = await _getHeaders(requireAuth: true);

    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.delete(url, headers: retryHeaders);
      }
    }
    return response;
  }

  // ---- MEMBERSHIP ASSIGNMENTS APIs ----
  Future<http.Response> assignMembership(Map<String, dynamic> data) async {
    return post('/api/memberships/assignments/', data);
  }

  Future<http.Response> getDashboardStats() async {
    return get('/api/memberships/assignments/dashboard-stats/');
  }

  // ==== ATTENDANCE MODULE ====
  Future<http.Response> checkInAttendance(Map<String, dynamic> data) async { return post('/api/attendance/check-in/', data); }
  Future<http.Response> checkOutAttendance(Map<String, dynamic> data) async { return post('/api/attendance/check-out/', data); }
  Future<http.Response> getAttendanceLogs({String? date, String? status, String? search}) async { String query = '?'; if (date != null) query += 'date=&'; if (status != null) query += 'status=&'; if (search != null) query += 'search=&'; return get('/api/attendance/'); }
  Future<http.Response> getMemberDashboardAttendance() async { return get('/api/attendance/dashboard/member/'); }
  Future<http.Response> getOwnerDashboardAttendance() async { return get('/api/attendance/dashboard/owner/'); }
  Future<http.Response> getAttendanceAnalytics() async { return get('/api/attendance/reports/analytics/'); }
}
