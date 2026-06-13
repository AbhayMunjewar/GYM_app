import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _errorMsg = '';

  int _assignedMembersCount = 0;
  int _activeMembersCount = 0;
  int _expiringSoonCount = 0;
  int _todayAttendanceCount = 0;
  String? _nextClient;

  // Diet management states
  int _activeDietPlansCount = 0;
  int _assignedDietMembersCount = 0;
  double _avgDietCompliance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final res = await _apiClient.getTrainerDashboardStats();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final stats = body['data'];
          setState(() {
            _assignedMembersCount = stats['assigned_members_count'] ?? 0;
            _activeMembersCount = stats['active_members_count'] ?? 0;
            _expiringSoonCount = stats['membership_expiring_soon'] ?? 0;
            _todayAttendanceCount = stats['today_attendance_present'] ?? 0;
            _nextClient = stats['next_client'];
          });
        }
      }

      // Fetch Diet stats
      int activeDietPlansCount = 0;
      int assignedDietMembersCount = 0;
      double avgCompliance = 0.0;

      final plansRes = await _apiClient.getDietPlans();
      if (plansRes.statusCode == 200) {
        final body = jsonDecode(plansRes.body);
        if (body['success'] == true) {
          final List results = body['data'] is List 
              ? body['data'] 
              : (body['data']?['results'] ?? []);
          activeDietPlansCount = results.length;
        }
      }

      final assignmentsRes = await _apiClient.getDietAssignments();
      if (assignmentsRes.statusCode == 200) {
        final body = jsonDecode(assignmentsRes.body);
        if (body['success'] == true) {
          final List results = body['data'] ?? [];
          assignedDietMembersCount = results.where((a) => a['status'] == 'ACTIVE').length;
        }
      }

      final reportsRes = await _apiClient.getDietReports('TRAINER_PERFORMANCE');
      if (reportsRes.statusCode == 200) {
        final body = jsonDecode(reportsRes.body);
        if (body['success'] == true) {
          final List results = body['data'] ?? [];
          if (results.isNotEmpty) {
            double sum = 0;
            for (var row in results) {
              sum += double.tryParse(row['average_compliance_percentage']?.toString() ?? '') ?? 0.0;
            }
            avgCompliance = sum / results.length;
          }
        }
      }

      setState(() {
        _activeDietPlansCount = activeDietPlansCount;
        _assignedDietMembersCount = assignedDietMembersCount;
        _avgDietCompliance = avgCompliance;
      });

    } catch (e) {
      setState(() => _errorMsg = 'Network error: $e');
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
        title: const Text(
          'TRAINER HQ',
          style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.white),
            onPressed: () => context.push('/trainer/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryFixed,
          onRefresh: _fetchStats,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
              : _errorMsg.isNotEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              _errorMsg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMetricCard(
                            context,
                            'Next Client',
                            _nextClient != null ? '$_nextClient' : 'No upcoming sessions',
                            Icons.schedule,
                            subValue: _nextClient != null ? 'Assigned' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildMetricCard(
                            context,
                            'Active Clients',
                            '$_activeMembersCount Active',
                            Icons.people,
                            subValue: '$_assignedMembersCount Total Assigned',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Checked In Today',
                                  '$_todayAttendanceCount',
                                  Icons.check_circle_outline,
                                  AppColors.primaryFixed,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Expiring Soon',
                                  '$_expiringSoonCount',
                                  Icons.warning_amber_rounded,
                                  _expiringSoonCount > 0 ? Colors.orange : Colors.grey,
                                ),
                              ),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Diet compliance stats', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.primaryFixed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text(
                                        '${_avgDietCompliance.toStringAsFixed(1)}% compliance',
                                        style: const TextStyle(color: AppColors.primaryFixed, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Diet Plans', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                          const SizedBox(height: 4),
                                          Text('$_activeDietPlansCount Plans', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Assigned Clients', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                          const SizedBox(height: 4),
                                          Text('$_assignedDietMembersCount Members', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (_avgDietCompliance / 100.0).clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: AppColors.white10,
                                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryFixed),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'MANAGEMENT',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              _buildNavCard(context, 'Client Mgmt', Icons.people, '/trainer/clients'),
                              _buildNavCard(context, 'My Sessions', Icons.calendar_month, '/owner/sessions'),
                              _buildNavCard(context, 'Workout Assign', Icons.fitness_center, '/trainer/workout-assign'),
                              _buildNavCard(context, 'Diet Assign', Icons.restaurant, '/trainer/diet-assign'),
                            ],
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    String? subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryFixed, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (subValue != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subValue,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
