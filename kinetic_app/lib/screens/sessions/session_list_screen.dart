import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../models/workout_session.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  final ApiClient _apiClient = ApiClient();
  List<WorkoutSession> _allSessions = [];
  List<WorkoutSession> _filteredSessions = [];
  bool _isLoading = true;
  String _errorMsg = '';

  String? _gymId;
  String? _trainerId;
  String _selectedFilter = 'ALL'; // TODAY | WEEK | ALL

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      if (authService.currentRole == UserRole.owner) {
        // Fetch owner's gym first
        final gymRes = await _apiClient.getGyms();
        if (gymRes.statusCode == 200) {
          final body = jsonDecode(gymRes.body);
          if (body['success'] == true && body['data'] != null) {
            final gymsList = body['data'] as List;
            if (gymsList.isNotEmpty) {
              _gymId = gymsList[0]['id']?.toString();
            }
          }
        }
        if (_gymId == null) {
          setState(() {
            _errorMsg = 'No active gym profile found for this owner.';
            _isLoading = false;
          });
          return;
        }
        await _fetchGymSessions();
      } else if (authService.currentRole == UserRole.trainer) {
        // Fetch trainer's id from dashboard stats
        final statsRes = await _apiClient.getTrainerDashboardStats();
        if (statsRes.statusCode == 200) {
          final body = jsonDecode(statsRes.body);
          if (body['success'] == true && body['data'] != null) {
            _trainerId = body['data']['trainer_id']?.toString();
          }
        }
        if (_trainerId == null) {
          setState(() {
            _errorMsg = 'No personal trainer profile found.';
            _isLoading = false;
          });
          return;
        }
        await _fetchTrainerSessions();
      } else {
        setState(() {
          _errorMsg = 'Access Denied.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchGymSessions() async {
    final res = await _apiClient.getGymSessions(_gymId!);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final List list = body['data']['results'] ?? body['data'];
        _allSessions = list.map((s) => WorkoutSession.fromJson(s)).toList();
        _applyFilter();
      } else {
        _errorMsg = body['message'] ?? 'Failed to load sessions';
      }
    } else {
      _errorMsg = 'Error fetching sessions. Code: ${res.statusCode}';
    }
  }

  Future<void> _fetchTrainerSessions() async {
    final res = await _apiClient.getTrainerSessions(_trainerId!);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final List list = body['data']['results'] ?? body['data'];
        _allSessions = list.map((s) => WorkoutSession.fromJson(s)).toList();
        _applyFilter();
      } else {
        _errorMsg = body['message'] ?? 'Failed to load sessions';
      }
    } else {
      _errorMsg = 'Error fetching sessions. Code: ${res.statusCode}';
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final weekLater = now.add(const Duration(days: 7));

    setState(() {
      if (_selectedFilter == 'TODAY') {
        _filteredSessions = _allSessions.where((s) => s.sessionDate == todayStr).toList();
      } else if (_selectedFilter == 'WEEK') {
        _filteredSessions = _allSessions.where((s) {
          try {
            final sDate = DateTime.parse(s.sessionDate);
            return sDate.isAfter(now.subtract(const Duration(days: 1))) && sDate.isBefore(weekLater);
          } catch (_) {
            return false;
          }
        }).toList();
      } else {
        _filteredSessions = List.from(_allSessions);
      }
    });
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilter();
  }

  Color _getCapacityColor(WorkoutSession session) {
    if (session.maxCapacity <= 0) return Colors.green;
    final ratio = session.bookedCount / session.maxCapacity;
    if (ratio >= 1.0) return Colors.red;
    if (ratio >= 0.8) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final showFAB = authService.currentRole == UserRole.owner || authService.currentRole == UserRole.trainer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'WORKOUT SESSIONS',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: showFAB
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryFixed,
              foregroundColor: AppColors.background,
              onPressed: () async {
                final refresh = await context.push('/owner/sessions/create');
                if (refresh == true) {
                  _loadData();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'All Sessions'),
                  const SizedBox(width: 8),
                  _buildFilterChip('TODAY', 'Today'),
                  const SizedBox(width: 8),
                  _buildFilterChip('WEEK', 'This Week'),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryFixed,
                onRefresh: _loadData,
                child: _isLoading
                    ? _buildSkeletonList()
                    : _errorMsg.isNotEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
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
                        : _filteredSessions.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  const Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.event_busy, size: 64, color: AppColors.onSurfaceVariant),
                                        SizedBox(height: 16),
                                        Text(
                                          'No sessions scheduled',
                                          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Check back later or schedule a new one.',
                                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: _filteredSessions.length,
                                itemBuilder: (context, index) {
                                  final session = _filteredSessions[index];
                                  final color = _getCapacityColor(session);

                                  return GestureDetector(
                                    onTap: () async {
                                      final refresh = await context.push('/owner/sessions/detail', extra: session);
                                      if (refresh == true) {
                                        _loadData();
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF201F1F),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.white10),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  session.title,
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      session.sessionDate,
                                                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${session.startTime} - ${session.endTime}',
                                                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.person, size: 14, color: Colors.white38),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      session.trainerName,
                                                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: color.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              '${session.bookedCount}/${session.maxCapacity}',
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => _changeFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryFixed : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
