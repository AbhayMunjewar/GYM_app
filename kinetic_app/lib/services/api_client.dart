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

  Future<http.Response> patch(String path, Map<String, dynamic> body, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final jsonBody = jsonEncode(body);

    var response = await http.patch(url, headers: headers, body: jsonBody);
    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.patch(url, headers: retryHeaders, body: jsonBody);
      }
    }
    return response;
  }

  Future<http.Response> delete(String path, {bool requireAuth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _getHeaders(requireAuth: requireAuth);

    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        response = await http.delete(url, headers: retryHeaders);
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
  Future<http.Response> getNotifications() async { return get('/api/notifications/'); }
  Future<http.Response> markNotificationRead(String id) async { 
    final url = Uri.parse('$baseUrl/api/notifications/$id/read/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.patch(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.patch(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }
  Future<http.Response> registerDeviceToken(String fcmToken, String deviceType) async {
    return post('/api/device-tokens/', {
      'fcm_token': fcmToken,
      'device_type': deviceType,
    });
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

  // ==== DIETS MODULE ====
  Future<http.Response> getFoods({String? search, String? category}) async {
    String query = '';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (category != null && category.isNotEmpty) params.add('category=$category');
    if (params.isNotEmpty) query = '?${params.join('&')}';
    return get('/api/foods/$query');
  }

  Future<http.Response> createFood(Map<String, dynamic> data) async {
    return post('/api/foods/', data);
  }

  Future<http.Response> deleteFood(String id) async {
    final url = Uri.parse('$baseUrl/api/foods/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getMealTemplates({String? type}) async {
    final query = (type != null && type.isNotEmpty) ? '?meal_type=$type' : '';
    return get('/api/meal-templates/$query');
  }

  Future<http.Response> createMealTemplate(Map<String, dynamic> data) async {
    return post('/api/meal-templates/', data);
  }

  Future<http.Response> deleteMealTemplate(String id) async {
    final url = Uri.parse('$baseUrl/api/meal-templates/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getDietPlans({String? search, String? goal}) async {
    String query = '';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (goal != null && goal.isNotEmpty) params.add('goal=$goal');
    if (params.isNotEmpty) query = '?${params.join('&')}';
    return get('/api/diet-plans/$query');
  }

  Future<http.Response> createDietPlan(Map<String, dynamic> data) async {
    return post('/api/diet-plans/', data);
  }

  Future<http.Response> deleteDietPlan(String id) async {
    final url = Uri.parse('$baseUrl/api/diet-plans/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getDietAssignments() async {
    return get('/api/diet-assignments/');
  }

  Future<http.Response> assignDietPlan(Map<String, dynamic> data) async {
    return post('/api/diet-assignments/', data);
  }

  Future<http.Response> getMemberDietProgress(int memberId) async {
    return get('/api/member-diets/$memberId/progress/');
  }

  Future<http.Response> logDietMeal(Map<String, dynamic> data) async {
    return post('/api/diet-logs/', data);
  }

  Future<http.Response> getDietReports(String type) async {
    return get('/api/diets/reports/?type=$type');
  }

  Future<http.Response> getDietPlan(String id) async {
    return get('/api/diet-plans/$id/');
  }

  Future<http.Response> getDietLogs() async {
    return get('/api/diet-logs/');
  }

  // ==== PROGRESS TRACKING MODULE ====
  Future<http.Response> getMeasurements({String? memberId}) async {
    final query = memberId != null ? '?member_id=$memberId' : '';
    return get('/api/progress/measurements/$query');
  }

  Future<http.Response> createMeasurement(Map<String, dynamic> data) async {
    return post('/api/progress/measurements/', data);
  }

  Future<http.Response> deleteMeasurement(String id) async {
    final url = Uri.parse('$baseUrl/api/progress/measurements/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getProgressPhotos({String? memberId, String? photoType}) async {
    final params = <String>[];
    if (memberId != null) params.add('member_id=$memberId');
    if (photoType != null) params.add('photo_type=$photoType');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return get('/api/progress/photos/$query');
  }

  Future<http.Response> uploadProgressPhoto({
    required String photoType,
    required String filePath,
    String? memberId,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/api/progress/photos/');
    final request = http.MultipartRequest('POST', url);
    final headers = await _getHeaders(requireAuth: true);
    request.headers.addAll(headers);
    request.fields['photo_type'] = photoType;
    if (memberId != null) request.fields['member'] = memberId;
    if (notes != null) request.fields['notes'] = notes;
    request.files.add(await http.MultipartFile.fromPath('image', filePath));
    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> deleteProgressPhoto(String id) async {
    final url = Uri.parse('$baseUrl/api/progress/photos/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getGoals({String? memberId, String? status}) async {
    final params = <String>[];
    if (memberId != null) params.add('member_id=$memberId');
    if (status != null) params.add('status=$status');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return get('/api/progress/goals/$query');
  }

  Future<http.Response> createGoal(Map<String, dynamic> data) async {
    return post('/api/progress/goals/', data);
  }

  Future<http.Response> updateGoal(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/progress/goals/$id/');
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

  Future<http.Response> deleteGoal(String id) async {
    final url = Uri.parse('$baseUrl/api/progress/goals/$id/');
    final headers = await _getHeaders(requireAuth: true);
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 401) {
      if (await _attemptTokenRefresh()) {
        response = await http.delete(url, headers: await _getHeaders(requireAuth: true));
      }
    }
    return response;
  }

  Future<http.Response> getProgressAnalytics({String? memberId}) async {
    final query = memberId != null ? '?member_id=$memberId' : '';
    return get('/api/progress/analytics/$query');
  }

  Future<http.Response> compareProgress({String? memberId, String? startDate, String? endDate}) async {
    final params = <String>[];
    if (memberId != null) params.add('member_id=$memberId');
    if (startDate != null) params.add('start_date=$startDate');
    if (endDate != null) params.add('end_date=$endDate');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return get('/api/progress/compare/$query');
  }

  // ==== ANALYTICS & REPORTING MODULE ====
  Future<http.Response> getOwnerAnalytics() async {
    return get('/api/analytics/owner/');
  }

  Future<http.Response> getTrainerAnalytics() async {
    return get('/api/analytics/trainer/');
  }

  Future<http.Response> getMemberAnalytics() async {
    return get('/api/analytics/member/');
  }

  // ==== GAMIFICATION SYSTEM APIs ====
  Future<http.Response> getPointsBalance() async {
    return get('/api/rewards/points/');
  }

  Future<http.Response> getPointsHistory() async {
    return get('/api/rewards/history/');
  }

  Future<http.Response> getStreaks() async {
    return get('/api/rewards/streaks/');
  }

  Future<http.Response> getBadges() async {
    return get('/api/rewards/badges/');
  }

  Future<http.Response> getMyBadges() async {
    return get('/api/rewards/my-badges/');
  }

  Future<http.Response> getRewardCatalog() async {
    return get('/api/rewards/catalog/');
  }

  Future<http.Response> redeemReward(String catalogId) async {
    return post('/api/rewards/redeem/', {'reward_id': catalogId});
  }

  Future<http.Response> getRedemptionHistory() async {
    return get('/api/rewards/redemptions/');
  }

  Future<http.Response> approveRedemption(String id) async {
    return post('/api/rewards/redemptions/$id/approve/', {});
  }

  Future<http.Response> rejectRedemption(String id, {String reason = ''}) async {
    return post('/api/rewards/redemptions/$id/reject/', {'reason': reason});
  }

  Future<http.Response> getChallenges() async {
    return get('/api/challenges/');
  }

  Future<http.Response> joinChallenge(String challengeId) async {
    return post('/api/challenges/join/', {'challenge_id': challengeId});
  }

  Future<http.Response> getMyJoinedChallenges() async {
    return get('/api/challenges/my/');
  }

  Future<http.Response> getChallengeDetail(String id) async {
    return get('/api/challenges/$id/');
  }

  Future<http.Response> getLeaderboard({String period = 'all_time'}) async {
    return get('/api/leaderboards/?period=$period');
  }

  // ==== COMMUNITY MODULE APIs ====
  Future<http.Response> getCommunityFeed({int page = 1}) async {
    return get('/api/community/feed/?page=$page');
  }

  Future<http.Response> createCommunityPost(Map<String, dynamic> data) async {
    return post('/api/community/posts/', data);
  }

  Future<http.Response> reactToPost(String postId, String reactionType) async {
    return post('/api/community/posts/$postId/react/', {'reaction_type': reactionType});
  }

  Future<http.Response> deleteReaction(String postId) async {
    return delete('/api/community/posts/$postId/react/');
  }

  Future<http.Response> getPostComments(String postId, {int page = 1}) async {
    return get('/api/community/posts/$postId/comments/?page=$page');
  }

  Future<http.Response> addComment(String postId, Map<String, dynamic> data) async {
    return post('/api/community/posts/$postId/comments/', data);
  }

  Future<http.Response> editComment(String commentId, Map<String, dynamic> data) async {
    return patch('/api/community/comments/$commentId/', data);
  }

  Future<http.Response> deleteComment(String commentId) async {
    return delete('/api/community/comments/$commentId/');
  }

  Future<http.Response> getCommunityEvents({int page = 1}) async {
    return get('/api/community/events/?page=$page');
  }

  Future<http.Response> getCommunityAnalytics() async {
    return get('/api/community/analytics/');
  }

  // ==== COMMUNICATION SYSTEM APIs ====
  Future<http.Response> getQuestions() async {
    return get('/api/questions/');
  }

  Future<http.Response> askQuestion(Map<String, dynamic> data) async {
    return post('/api/questions/', data);
  }

  Future<http.Response> answerQuestion(String questionId, String answer) async {
    return post('/api/questions/$questionId/answers/', {'answer': answer});
  }

  Future<http.Response> getGroups() async {
    return get('/api/groups/');
  }

  Future<http.Response> createGroup(Map<String, dynamic> data) async {
    return post('/api/groups/', data);
  }

  Future<http.Response> joinGroup(String groupId) async {
    return post('/api/groups/$groupId/join/', {});
  }

  Future<http.Response> leaveGroup(String groupId) async {
    return post('/api/groups/$groupId/leave/', {});
  }

  Future<http.Response> getGroupPosts(String groupId) async {
    return get('/api/groups/$groupId/posts/');
  }

  Future<http.Response> createGroupPost(String groupId, String content) async {
    return post('/api/groups/$groupId/posts/', {'content': content});
  }

  Future<http.Response> getAnnouncements() async {
    return get('/api/announcements/');
  }

  Future<http.Response> createAnnouncement(Map<String, dynamic> data) async {
    return post('/api/announcements/', data);
  }

  Future<http.Response> getChatRooms() async {
    return get('/api/chat/rooms/');
  }

  Future<http.Response> createChatRoom(String targetUserId) async {
    return post('/api/chat/rooms/', {'user_id': targetUserId});
  }

  Future<http.Response> getChatMessages(String roomId, {int page = 1}) async {
    return get('/api/chat/messages/?room_id=$roomId&page=$page');
  }

  Future<http.Response> getForumCategories() async {
    return get('/api/forums/categories/');
  }

  Future<http.Response> createForumCategory(Map<String, dynamic> data) async {
    return post('/api/forums/categories/', data);
  }

  Future<http.Response> getForumTopics() async {
    return get('/api/forums/topics/');
  }

  Future<http.Response> createForumTopic(Map<String, dynamic> data) async {
    return post('/api/forums/topics/', data);
  }

  Future<http.Response> getForumReplies(String topicId) async {
    return get('/api/forums/topics/$topicId/replies_list/');
  }

  Future<http.Response> replyToForumTopic(String topicId, String content) async {
    return post('/api/forums/topics/$topicId/replies/', {'content': content});
  }

  Future<http.Response> getEvents() async {
    return get('/api/events/');
  }

  Future<http.Response> createEvent(Map<String, dynamic> data) async {
    return post('/api/events/', data);
  }

  Future<http.Response> registerForEvent(String eventId) async {
    return post('/api/events/$eventId/register/', {});
  }

  Future<http.Response> cancelEventRegistration(String eventId) async {
    return post('/api/events/$eventId/cancel/', {});
  }

  Future<http.Response> createReport(Map<String, dynamic> data) async {
    return post('/api/reports/', data);
  }

  Future<http.Response> getReports() async {
    return get('/api/reports/');
  }

  Future<http.Response> resolveReport(String reportId, String actionTaken) async {
    return patch('/api/reports/$reportId/', {'action_taken': actionTaken});
  }
}

