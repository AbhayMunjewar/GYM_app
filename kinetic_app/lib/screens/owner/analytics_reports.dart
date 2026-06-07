import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class AnalyticsReports extends StatefulWidget {
  const AnalyticsReports({super.key});

  @override
  State<AnalyticsReports> createState() => _AnalyticsReportsState();
}

class _AnalyticsReportsState extends State<AnalyticsReports> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _peakHours = [];

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      final res = await _apiClient.getAttendanceAnalytics();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _peakHours = body['data']['peak_hours'] ?? [];
          });
        }
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ANALYTICS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Icon(Icons.bar_chart, size: 64, color: AppColors.primaryFixed)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('New Members', '+45', Icons.trending_up, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Churn Rate', '2.1%', Icons.trending_down, Colors.red)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Peak Hours', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                    else if (_peakHours.isEmpty)
                      const Text('Not enough data to determine peak hours.', style: TextStyle(color: AppColors.onSurfaceVariant))
                    else
                      ..._peakHours.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var ph = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('${idx + 1}. ${ph['time_range']} (${ph['count']} check-ins)', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
