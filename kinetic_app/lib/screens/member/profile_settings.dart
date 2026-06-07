import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final res = await _apiClient.getAttendanceLogs();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _logs = body['data']['results'] ?? [];
          });
        }
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return 'N/A';
    final dt = DateTime.parse(isoString).toLocal();
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('PROFILE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                : _logs.isEmpty 
                  ? const Center(child: Text('No attendance history yet.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                  : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  final checkIn = _formatDateTime(log['check_in_time']);
                  final status = log['attendance_status'] ?? 'PRESENT';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF201F1F),
                      border: Border(left: BorderSide(
                        color: status == 'PRESENT' ? AppColors.primaryFixed : Colors.orange, 
                        width: 4
                      )),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Checked in at $checkIn', style: const TextStyle(color: AppColors.white, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(status, style: const TextStyle(color: AppColors.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: OutlinedButton(
                onPressed: () => context.go('/auth/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFB4AB),
                  side: const BorderSide(color: Color(0xFFFFB4AB)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LOG OUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
