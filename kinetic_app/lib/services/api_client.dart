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

  // ==== QR ATTENDANCE MODULE ====
  Future<http.Response> generateQRCode(Map<String, dynamic> data) async { return post('/api/qr-attendance/generate/', data); }
  Future<http.Response> scanQRCode(Map<String, dynamic> data) async { return post('/api/qr-attendance/scan/', data); }

  // ==== BILLING MODULE ====
  Future<http.Response> getBillingSettings() async { return get('/api/billing/settings/'); }
  Future<http.Response> updateBillingSettings(Map<String, dynamic> data) async { 
    final url = Uri.parse('$baseUrl/api/billing/settings/');
    final headers = await _getHeaders(requireAuth: true);
    final jsonBody = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.patch(url, headers: await _getHeaders(requireAuth: true), body: jsonBody);
      }
    }
    return response;
  }
  Future<http.Response> getInvoices() async { return get('/api/billing/invoices/'); }
  Future<http.Response> createInvoice(Map<String, dynamic> data) async { return post('/api/billing/invoices/', data); }
  Future<http.Response> getPayments() async { return get('/api/billing/payments/'); }
  Future<http.Response> recordPayment(Map<String, dynamic> data) async { return post('/api/billing/payments/record/', data); }
  Future<http.Response> acknowledgePayment(String paymentId, Map<String, dynamic> data) async { return post('/api/billing/payments/$paymentId/acknowledge/', data); }
  Future<http.Response> getBillingAnalytics() async { return get('/api/billing/analytics/'); }

  // ==== NOTIFICATIONS ====
  Future<http.Response> getNotifications() async { return get('/api/billing/notifications/'); }
  Future<http.Response> markNotificationRead(String id) async { 
    final url = Uri.parse('$baseUrl/api/billing/notifications/$id/read/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.patch(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.patch(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  // ==== TRAINERS MODULE ====
  Future<http.Response> getTrainers({String query = ''}) async {
    return get('/api/trainers/?$query');
  }

  Future<http.Response> createTrainer(Map<String, dynamic> data) async {
    return post('/api/trainers/', data);
  }

  Future<http.Response> getTrainer(String id) async {
    return get('/api/trainers/$id/');
  }

  Future<http.Response> updateTrainer(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/trainers/$id/');
    final headers = await _getHeaders(requireAuth: true);
    final jsonBody = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.patch(url, headers: await _getHeaders(requireAuth: true), body: jsonBody);
      }
    }
    return response;
  }

  Future<http.Response> deleteTrainer(String id) async {
    final url = Uri.parse('$baseUrl/api/trainers/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getTrainerAssignments({String query = ''}) async {
    return get('/api/trainer-assignments/?$query');
  }

  Future<http.Response> createTrainerAssignment(Map<String, dynamic> data) async {
    return post('/api/trainer-assignments/', data);
  }

  Future<http.Response> updateTrainerAssignment(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/trainer-assignments/$id/');
    final headers = await _getHeaders(requireAuth: true);
    final jsonBody = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.patch(url, headers: await _getHeaders(requireAuth: true), body: jsonBody);
      }
    }
    return response;
  }

  Future<http.Response> deleteTrainerAssignment(String id) async {
    final url = Uri.parse('$baseUrl/api/trainer-assignments/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getTrainerDashboardStats() async {
    return get('/api/trainers/dashboard/');
  }

  Future<http.Response> getTrainerMembers(String trainerId, {String query = ''}) async {
    return get('/api/trainers/$trainerId/members/?$query');
  }

  Future<http.Response> getOwnerTrainerAnalytics() async {
    return get('/api/trainers/analytics/owner/');
  }

  Future<http.Response> getTrainerReports({String type = 'PERFORMANCE'}) async {
    return get('/api/trainers/reports/?type=$type');
  }

  // ==== WORKOUT SESSIONS MODULE ====
  Future<http.Response> getGymSessions(String gymId, {String? date}) async {
    final queryStr = date != null ? '?date=$date' : '';
    return get('/api/sessions/gym/$gymId/$queryStr');
  }

  Future<http.Response> getTrainerSessions(String trainerId) async {
    return get('/api/sessions/trainer/$trainerId/');
  }

  Future<http.Response> createSession(Map<String, dynamic> data) async {
    return post('/api/sessions/', data);
  }

  Future<http.Response> updateSession(String sessionId, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/sessions/$sessionId/');
    final headers = await _getHeaders(requireAuth: true);
    final jsonBody = jsonEncode(data);
    var response = await http.put(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.put(url, headers: await _getHeaders(requireAuth: true), body: jsonBody);
      }
    }
    return response;
  }

  Future<http.Response> deleteSession(String sessionId) async {
    final url = Uri.parse('$baseUrl/api/sessions/$sessionId/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> bookMember(String sessionId, int memberId) async {
    return post('/api/bookings/', {
      'session': sessionId,
      'member': memberId,
    });
  }

  Future<http.Response> getMemberSchedule(int memberId) async {
    return get('/api/bookings/member/$memberId/');
  }

  Future<http.Response> cancelBooking(String bookingId) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId/cancel/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.put(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.put(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getSessionBookings(String sessionId) async {
    return get('/api/bookings/?session_id=$sessionId');
  }
}
