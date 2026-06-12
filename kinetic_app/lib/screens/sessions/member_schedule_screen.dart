import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/workout_session.dart';

class MemberScheduleScreen extends StatefulWidget {
  final int? memberId;

  const MemberScheduleScreen({super.key, this.memberId});

  @override
  State<MemberScheduleScreen> createState() => _MemberScheduleScreenState();
}

class _MemberScheduleScreenState extends State<MemberScheduleScreen> {
  final ApiClient _apiClient = ApiClient();
  List<SessionBooking> _bookings = [];
  bool _isLoading = true;
  String _errorMsg = '';
  int? _resolvedMemberId;

  @override
  void initState() {
    super.initState();
    _resolvedMemberId = widget.memberId;
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      // 1. Resolve member ID if not passed
      if (_resolvedMemberId == null) {
        final res = await _apiClient.getMemberDashboardAttendance();
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          if (body['success'] == true && body['data'] != null) {
            _resolvedMemberId = body['data']['member_id'];
          }
        }
      }

      if (_resolvedMemberId == null) {
        setState(() {
          _errorMsg = 'Member profile details not found.';
          _isLoading = false;
        });
        return;
      }

      // 2. Fetch bookings schedule
      final res = await _apiClient.getMemberSchedule(_resolvedMemberId!);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'];
          setState(() {
            _bookings = list.map((b) => SessionBooking.fromJson(b)).toList();
          });
        }
      } else {
        setState(() => _errorMsg = 'Failed to load schedule.');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(SessionBooking booking) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF201F1F),
            title: const Text('Cancel Session Booking?'),
            content: Text('Are you sure you want to cancel your booking for "${booking.sessionTitle}"?'),
            actions: [
              TextButton(onPressed: () => context.pop(false), child: const Text('NO', style: TextStyle(color: Colors.white30))),
              TextButton(onPressed: () => context.pop(true), child: const Text('YES, CANCEL', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.cancelBooking(booking.id);
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session booking cancelled.')));
        }
        _loadSchedule();
      } else {
        final body = jsonDecode(res.body);
        _showSnackBar(body['message'] ?? 'Failed to cancel booking.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return AppColors.primaryFixed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelfView = widget.memberId == null;

    // Local grouping logic by session Date
    final Map<String, List<SessionBooking>> groupedBookings = {};
    for (var b in _bookings) {
      final dateStr = b.sessionDate ?? 'Date Not Specified';
      if (!groupedBookings.containsKey(dateStr)) {
        groupedBookings[dateStr] = [];
      }
      groupedBookings[dateStr]!.add(b);
    }

    final sortedDates = groupedBookings.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isSelfView ? 'MY WORKOUT SCHEDULE' : 'MEMBER SCHEDULE',
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryFixed,
          onRefresh: _loadSchedule,
          child: _isLoading && _bookings.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
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
                  : _bookings.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_today, size: 64, color: AppColors.onSurfaceVariant),
                                  SizedBox(height: 16),
                                  Text(
                                    'No upcoming sessions',
                                    style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Book workout sessions with gym trainers.',
                                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: sortedDates.length,
                          itemBuilder: (context, dateIndex) {
                            final dateStr = sortedDates[dateIndex];
                            final list = groupedBookings[dateStr]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                                  child: Text(
                                    dateStr.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primaryFixed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                ...list.map((booking) {
                                  final color = _getStatusColor(booking.status);
                                  return Container(
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
                                                booking.sessionTitle ?? 'Workout Session',
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${booking.sessionStartTime ?? ""} - ${booking.sessionEndTime ?? ""}',
                                                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.person_outline, size: 14, color: Colors.white38),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Trainer: ${booking.trainerName ?? ""}',
                                                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                booking.status.toUpperCase(),
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            if (booking.status.toLowerCase() == 'booked') ...[
                                              const SizedBox(height: 12),
                                              TextButton(
                                                onPressed: () => _cancelBooking(booking),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.redAccent,
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(50, 30),
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
