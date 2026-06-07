import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class AttendanceManagement extends StatefulWidget {
  const AttendanceManagement({super.key});

  @override
  State<AttendanceManagement> createState() => _AttendanceManagementState();
}

class _AttendanceManagementState extends State<AttendanceManagement> {
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

  String _formatTime(String? isoString) {
    if (isoString == null) return 'N/A';
    final dt = DateTime.parse(isoString).toLocal();
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ATTENDANCE LOGS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
          : _logs.isEmpty 
            ? const Center(child: Text('No attendance logs found.', style: TextStyle(color: AppColors.onSurfaceVariant)))
            : ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            final memberName = log['member_name'] ?? 'Unknown Member';
            final checkIn = _formatTime(log['check_in_time']);
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(memberName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        Text('Checked in at $checkIn', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
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
    );
  }
}
