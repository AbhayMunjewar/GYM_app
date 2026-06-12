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
  bool _isLoadingTrainers = true;
  List<dynamic> _peakHours = [];
  Map<String, dynamic>? _trainerAnalytics;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _isLoadingTrainers = true;
    });

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
    } catch (_) {}

    try {
      final res = await _apiClient.getOwnerTrainerAnalytics();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _trainerAnalytics = body['data'];
          });
        }
      }
    } catch (_) {}

    setState(() {
      _isLoading = false;
      _isLoadingTrainers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalTrainers = _trainerAnalytics?['total_trainers'] ?? 0;
    final int activeTrainers = _trainerAnalytics?['active_trainers'] ?? 0;
    final double utilization = (_trainerAnalytics?['trainer_utilization'] ?? 0.0).toDouble();
    final List<dynamic> topPerformers = _trainerAnalytics?['top_performing_trainers'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('ANALYTICS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryFixed,
          onRefresh: _fetchAnalytics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white10),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insights, size: 48, color: AppColors.primaryFixed),
                        SizedBox(height: 8),
                        Text(
                          'GYM BUSINESS INTELLIGENCE',
                          style: TextStyle(
                            color: Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white10),
                  ),
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
                            child: Text(
                              '${idx + 1}. ${ph['time_range']} (${ph['count']} check-ins)',
                              style: const TextStyle(color: AppColors.onSurfaceVariant),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'STAFF ANALYTICS',
                  style: TextStyle(
                    color: AppColors.primaryFixed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Trainers',
                        '$totalTrainers',
                        Icons.badge,
                        Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Active Trainers',
                        '$activeTrainers',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Staff Utilization',
                            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.fitness_center, color: AppColors.primaryFixed, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${utilization.toStringAsFixed(1)} active clients / trainer',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Average workload distribution across active personal training staff.',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Top Performers (By Client Load)',
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingTrainers)
                        const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                      else if (topPerformers.isEmpty)
                        const Text(
                          'No trainer utilization details found.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        )
                      else
                        ...topPerformers.map((tp) {
                          final String name = tp['name'] ?? 'Staff Member';
                          final int count = tp['clients_count'] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.primaryFixed, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '$count Clients',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
