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

  // Owner analytics data
  Map<String, dynamic>? _revenue;
  Map<String, dynamic>? _memberships;
  Map<String, dynamic>? _attendance;
  Map<String, dynamic>? _trainers;
  Map<String, dynamic>? _memberGrowth;
  List<dynamic> _revenueTrend = [];
  List<dynamic> _planDistribution = [];

  // Legacy data (fallback)
  List<dynamic> _peakHours = [];
  Map<String, dynamic>? _trainerAnalytics;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Primary: use consolidated analytics endpoint
      final res = await _apiClient.getOwnerAnalytics();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final data = body['data'];
          setState(() {
            _revenue = data['revenue'];
            _memberships = data['memberships'];
            _attendance = data['attendance'];
            _trainers = data['trainers'];
            _memberGrowth = data['members'];
            _revenueTrend = data['revenue_trend'] ?? [];
            _planDistribution = data['plan_distribution'] ?? [];
            _peakHours = data['attendance']?['peak_hours'] ?? [];
          });
        }
      }
    } catch (_) {}

    // Fallback: trainer analytics from legacy endpoint
    try {
      final res = await _apiClient.getOwnerTrainerAnalytics();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() => _trainerAnalytics = body['data']);
        }
      }
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Derived values with null-safe fallbacks
    final int newMembers = _memberships?['new_this_month'] ?? 0;
    final double churnRate = (_memberships?['churn_rate'] ?? 0.0).toDouble();
    final String totalRevenue = _revenue?['total_revenue'] ?? '0.00';
    final String monthlyRevenue = _revenue?['monthly_revenue'] ?? '0.00';
    final String pendingDues = _revenue?['pending_dues'] ?? '0.00';
    final int overdueInvoices = _revenue?['overdue_invoices'] ?? 0;
    final int todayCheckIns = _attendance?['today_check_ins'] ?? 0;
    final double weeklyAvg = (_attendance?['weekly_average'] ?? 0.0).toDouble();

    final int totalTrainers = _trainerAnalytics?['total_trainers'] ?? _trainers?['total_trainers'] ?? 0;
    final int activeTrainers = _trainerAnalytics?['active_trainers'] ?? _trainers?['active_trainers'] ?? 0;
    final double utilization = (_trainerAnalytics?['trainer_utilization'] ?? _trainers?['trainer_utilization'] ?? 0.0).toDouble();
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
            child: _isLoading
                ? const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryFixed)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
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

                      // Revenue Section
                      const SizedBox(height: 24),
                      const Text('REVENUE', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Total Revenue', '\$$totalRevenue', Icons.attach_money, Colors.green)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('This Month', '\$$monthlyRevenue', Icons.calendar_today, Colors.blueAccent)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Pending Dues', '\$$pendingDues', Icons.pending_actions, Colors.orange)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('Overdue', '$overdueInvoices', Icons.warning_amber_rounded, Colors.red)),
                        ],
                      ),

                      // Revenue Trend
                      if (_revenueTrend.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildRevenueTrendCard(),
                      ],

                      // Membership Section
                      const SizedBox(height: 24),
                      const Text('MEMBERS', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('New Members', '+$newMembers', Icons.trending_up, Colors.green)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('Churn Rate', '${churnRate.toStringAsFixed(1)}%', Icons.trending_down, churnRate > 5 ? Colors.red : Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Expiring Soon', '${_memberships?['expiring_soon'] ?? 0}', Icons.timer, Colors.orange)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('Active Members', '${_memberships?['active_members'] ?? 0}', Icons.people, Colors.blueAccent)),
                        ],
                      ),

                      // Plan Distribution
                      if (_planDistribution.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildPlanDistributionCard(),
                      ],

                      // Attendance Section
                      const SizedBox(height: 24),
                      const Text('ATTENDANCE', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("Today's Check-ins", '$todayCheckIns', Icons.how_to_reg, Colors.blueAccent)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('Daily Avg (7d)', weeklyAvg.toStringAsFixed(1), Icons.show_chart, Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPeakHoursCard(),

                      // Staff Analytics Section
                      const SizedBox(height: 24),
                      const Text('STAFF ANALYTICS', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Total Trainers', '$totalTrainers', Icons.badge, Colors.blueAccent)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard('Active Trainers', '$activeTrainers', Icons.check_circle_outline, Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildUtilizationCard(utilization),
                      const SizedBox(height: 16),
                      _buildTopPerformersCard(topPerformers),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueTrendCard() {
    final maxRevenue = _revenueTrend.fold<double>(0.0, (max, item) {
      final val = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0;
      return val > max ? val : max;
    });

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
          const Text('Revenue Trend (6 Months)', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._revenueTrend.map((item) {
            final revenue = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0;
            final barWidth = maxRevenue > 0 ? (revenue / maxRevenue) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      item['month'] ?? '',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: barWidth.clamp(0.0, 1.0),
                        minHeight: 16,
                        backgroundColor: AppColors.white10,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryFixed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${revenue.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlanDistributionCard() {
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
          const Text('Membership Plan Distribution', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._planDistribution.map((plan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: AppColors.primaryFixed, size: 10),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plan['plan_name'] ?? 'Unknown Plan',
                      style: const TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                  ),
                  Text(
                    '${plan['active_count']} active',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${plan['price']}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPeakHoursCard() {
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
          const Text('Peak Hours', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_peakHours.isEmpty)
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
    );
  }

  Widget _buildUtilizationCard(double utilization) {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Staff Utilization', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              Icon(Icons.fitness_center, color: AppColors.primaryFixed, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${utilization.toStringAsFixed(1)} active clients / trainer',
            style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Average workload distribution across active personal training staff.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersCard(List<dynamic> topPerformers) {
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
          const Text('Top Performers (By Client Load)', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (topPerformers.isEmpty)
            const Text('No trainer utilization details found.', style: TextStyle(color: AppColors.onSurfaceVariant))
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
                    Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14))),
                    Text('$count Clients', style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
        ],
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
