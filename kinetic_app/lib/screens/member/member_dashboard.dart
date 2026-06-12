import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  int _currentStreak = 0;
  int? _memberId;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final res = await _apiClient.getMemberDashboardAttendance();
      print('MemberDashboard response: ${res.statusCode} - ${res.body}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final data = body['data'];
          setState(() {
            _isCheckedIn = data['is_checked_in'] ?? false;
            _isCheckedOut = data['is_checked_out'] ?? false;
            _currentStreak = data['streak_info']['current_streak'] ?? 0;
            _memberId = data['member_id'];
          });
        }
      } else {
        print('Error fetching member dashboard: ${res.body}');
      }
    } catch (e) {
      print('Exception in MemberDashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckIn() async {
    if (_memberId == null) return;
    try {
      final res = await _apiClient.checkInAttendance({'member_id': _memberId});
      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked In successfully')));
        _fetchDashboardData();
      } else {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Failed to check in')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleCheckOut() async {
    if (_memberId == null) return;
    try {
      final res = await _apiClient.checkOutAttendance({'member_id': _memberId});
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked Out successfully')));
        _fetchDashboardData();
      } else {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Failed to check out')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openQRScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Scan Gym QR', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String code = barcodes.first.rawValue ?? '';
                      if (code.isNotEmpty) {
                        context.pop();
                        _handleQRCheckIn(code);
                      }
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleQRCheckIn(String qrToken) async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.scanQRCode({'qr_token': qrToken});
      if (res.statusCode == 201 || res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Check In successful!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        _fetchDashboardData();
      } else {
        if (!mounted) return;
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Failed to check in'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
        title: const Text('MEMBER DASHBOARD', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: AppColors.white), onPressed: () => context.push('/notifications')),
          IconButton(icon: const Icon(Icons.person, color: AppColors.white), onPressed: () => context.push('/member/profile')),
        ],
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
          : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAttendanceCard(),
              const SizedBox(height: 16),
              _buildMetricCard(context, 'Next Session', 'Upper Body Power', Icons.fitness_center),
              const SizedBox(height: 16),
              _buildMetricCard(context, 'Nutrition', '1,850 / 2,400 kcal', Icons.restaurant),
              const SizedBox(height: 32),
              const Text('MODULES', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildNavCard(context, 'Workout Center', Icons.fitness_center, '/member/workout-center'),
                  _buildNavCard(context, 'Diet Center', Icons.apple, '/member/diet-center'),
                  _buildNavCard(context, 'Exercise Library', Icons.menu_book, '/member/exercise-library'),
                  _buildNavCard(context, 'AI Gym Buddy', Icons.smart_toy, '/member/ai-buddy'),
                  _buildNavCard(context, 'AI Form Check', Icons.camera_alt, '/member/ai-form-check'),
                  _buildNavCard(context, 'Progress Tracker', Icons.trending_up, '/member/progress-tracker'),
                  _buildNavCard(context, 'Billing & Payments', Icons.payment, '/member/billing'),
                  _buildNavCard(context, 'Challenges', Icons.emoji_events, '/member/challenges'),
                  _buildNavCard(context, 'Rewards', Icons.star, '/member/rewards'),
                  _buildNavCard(context, 'My Schedule', Icons.calendar_month, '/member/schedule'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Check-in', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text('$_currentStreak Day Streak', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          if (!_isCheckedIn)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryFixed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Manual In', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openQRScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Scan QR', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          else if (!_isCheckedOut)
            ElevatedButton(
              onPressed: _handleCheckOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Check Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Text('Checked Out for Today', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryFixed, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
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
        decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 32),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int index) {
    return BottomNavigationBar(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primaryFixed,
      unselectedItemColor: AppColors.onSurfaceVariant,
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 0) context.go('/member/dashboard');
        if (i == 1) context.push('/member/workout-center');
        if (i == 2) context.push('/member/diet-center');
        if (i == 3) context.push('/member/progress-tracker');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
      ],
    );
  }
}
