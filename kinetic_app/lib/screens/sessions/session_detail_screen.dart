import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../models/workout_session.dart';
import '../../models/member.dart';

class SessionDetailScreen extends StatefulWidget {
  final WorkoutSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  late WorkoutSession _currentSession;

  List<SessionBooking> _bookings = [];
  bool _isLoadingBookings = true;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoadingBookings = true;
      _errorMsg = '';
    });

    try {
      final res = await _apiClient.getSessionBookings(_currentSession.id);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'];
          setState(() {
            _bookings = list.map((b) => SessionBooking.fromJson(b)).toList();
          });
        }
      } else {
        setState(() => _errorMsg = 'Failed to load bookings.');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Error: $e');
    } finally {
      setState(() => _isLoadingBookings = false);
    }
  }

  Future<void> _cancelMemberBooking(SessionBooking booking, String memberName) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF201F1F),
            title: const Text('Cancel Booking?'),
            content: Text('Are you sure you want to cancel the booking for $memberName?'),
            actions: [
              TextButton(onPressed: () => context.pop(false), child: const Text('NO', style: TextStyle(color: Colors.white30))),
              TextButton(onPressed: () => context.pop(true), child: const Text('YES, CANCEL', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final res = await _apiClient.cancelBooking(booking.id);
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking for $memberName cancelled.')));
        }
        // Update local session booking count
        setState(() {
          _currentSession = WorkoutSession(
            id: _currentSession.id,
            gymId: _currentSession.gymId,
            trainerId: _currentSession.trainerId,
            trainerName: _currentSession.trainerName,
            title: _currentSession.title,
            description: _currentSession.description,
            sessionDate: _currentSession.sessionDate,
            startTime: _currentSession.startTime,
            endTime: _currentSession.endTime,
            maxCapacity: _currentSession.maxCapacity,
            bookedCount: _currentSession.bookedCount - 1,
            isDeleted: _currentSession.isDeleted,
          );
        });
        _fetchBookings();
      } else {
        final body = jsonDecode(res.body);
        _showSnackBar(body['message'] ?? 'Failed to cancel booking.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _deleteSession() async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF201F1F),
            title: const Text('Delete Workout Session?'),
            content: const Text('Are you sure you want to remove this session? Existing booking history will be preserved as cancelled/deleted.'),
            actions: [
              TextButton(onPressed: () => context.pop(false), child: const Text('CANCEL', style: TextStyle(color: Colors.white30))),
              TextButton(onPressed: () => context.pop(true), child: const Text('DELETE', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final res = await _apiClient.deleteSession(_currentSession.id);
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session deleted successfully.')));
          context.pop(true); // Pop to list and signal refresh
        }
      } else {
        final body = jsonDecode(res.body);
        _showSnackBar(body['message'] ?? 'Failed to delete session.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showBookMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _BookMemberSheet(
          session: _currentSession,
          existingBookings: _bookings,
          onBooked: () {
            context.pop();
            // Update local session booking count
            setState(() {
              _currentSession = WorkoutSession(
                id: _currentSession.id,
                gymId: _currentSession.gymId,
                trainerId: _currentSession.trainerId,
                trainerName: _currentSession.trainerName,
                title: _currentSession.title,
                description: _currentSession.description,
                sessionDate: _currentSession.sessionDate,
                startTime: _currentSession.startTime,
                endTime: _currentSession.endTime,
                maxCapacity: _currentSession.maxCapacity,
                bookedCount: _currentSession.bookedCount + 1,
                isDeleted: _currentSession.isDeleted,
              );
            });
            _fetchBookings();
          },
        );
      },
    );
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double capacityRatio = _currentSession.maxCapacity > 0
        ? _currentSession.bookedCount / _currentSession.maxCapacity
        : 0.0;

    final bool isOwner = authService.currentRole == UserRole.owner;
    final bool canBook = authService.currentRole == UserRole.owner || authService.currentRole == UserRole.trainer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(true),
        ),
        title: const Text('SESSION DETAILS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _deleteSession,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Session Info Card
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
                    Text(
                      _currentSession.title,
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryFixed),
                        const SizedBox(width: 8),
                        Text(_currentSession.sessionDate, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(width: 20),
                        const Icon(Icons.access_time, size: 16, color: AppColors.primaryFixed),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentSession.startTime} - ${_currentSession.endTime}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppColors.primaryFixed),
                        const SizedBox(width: 8),
                        Text(
                          'Trainer: ${_currentSession.trainerName}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    if (_currentSession.description != null && _currentSession.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 8),
                      const Text('Description', style: TextStyle(color: Colors.white30, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        _currentSession.description!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Capacity Indicator
              Container(
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
                        const Text('Booking Capacity', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                        Text(
                          '${_currentSession.bookedCount} / ${_currentSession.maxCapacity} Booked',
                          style: TextStyle(
                            color: capacityRatio >= 1.0
                                ? Colors.red
                                : capacityRatio >= 0.8
                                    ? Colors.orange
                                    : AppColors.primaryFixed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: capacityRatio,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          capacityRatio >= 1.0
                              ? Colors.red
                              : capacityRatio >= 0.8
                                  ? Colors.orange
                                  : AppColors.primaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BOOKED MEMBERS',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  if (canBook && _currentSession.bookedCount < _currentSession.maxCapacity)
                    TextButton.icon(
                      onPressed: _showBookMemberSheet,
                      icon: const Icon(Icons.person_add_alt_1, size: 16, color: AppColors.primaryFixed),
                      label: const Text('Book Member', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Bookings List
              Expanded(
                child: _isLoadingBookings
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
                    : _errorMsg.isNotEmpty
                        ? Center(child: Text(_errorMsg, style: const TextStyle(color: Colors.red)))
                        : _bookings.isEmpty
                            ? const Center(
                                child: Text(
                                  'No members booked in this session.',
                                  style: TextStyle(color: AppColors.onSurfaceVariant),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _bookings.length,
                                itemBuilder: (context, index) {
                                  final booking = _bookings[index];
                                  final memberName = booking.memberName ?? 'Unnamed Member';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF222121),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.white12,
                                          child: Icon(Icons.person, color: Colors.white70, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            memberName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (canBook)
                                          IconButton(
                                            icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                                            onPressed: () => _cancelMemberBooking(booking, memberName),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookMemberSheet extends StatefulWidget {
  final WorkoutSession session;
  final List<SessionBooking> existingBookings;
  final VoidCallback onBooked;

  const _BookMemberSheet({
    required this.session,
    required this.existingBookings,
    required this.onBooked,
  });

  @override
  State<_BookMemberSheet> createState() => _BookMemberSheetState();
}

class _BookMemberSheetState extends State<_BookMemberSheet> {
  final ApiClient _apiClient = ApiClient();
  List<Member> _members = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableMembers();
  }

  Future<void> _loadAvailableMembers() async {
    try {
      final res = await _apiClient.getMembers(query: 'status=ACTIVE');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List list = body['data']['results'] ?? body['data'];
          final parsedMembers = list.map((m) => Member.fromJson(m)).toList();

          // Filter out members that are already booked
          final bookedMemberIds = widget.existingBookings.map((b) => b.memberId.toString()).toSet();
          setState(() {
            _members = parsedMembers.where((m) => !bookedMemberIds.contains(m.id)).toList();
          });
        }
      }
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bookMember(Member member) async {
    setState(() => _isSaving = true);
    try {
      final int memberIdInt = int.parse(member.id);
      final res = await _apiClient.bookMember(widget.session.id, memberIdInt);
      if (res.statusCode == 201) {
        widget.onBooked();
      } else {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Failed to book member'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'BOOK A MEMBER',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(color: AppColors.primaryFixed)))
          else if (_members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'No available active members to book.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final m = _members[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.person, color: Colors.white70),
                    ),
                    title: Text(m.fullName, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(m.email, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    trailing: const Icon(Icons.add_circle_outline, color: AppColors.primaryFixed),
                    onTap: _isSaving ? null : () => _bookMember(m),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
