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
  int _pointsBalance = 0;
  int? _rank;

  // Diet tracking metrics
  int _consumedCalories = 0;
  int _targetCalories = 0;

  // Progress tracking metrics
  double _currentWeight = 0.0;
  double _weightChange = 0.0;
  int _activeGoalsCount = 0;

  // Analytics metrics
  double _consistencyRate = 0.0;
  int _daysRemaining = 0;
  String? _planName;

  // Daily AI tip metrics
  String? _tipTitle;
  String? _tipContent;
  String? _tipArticleTitle;

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
      }

      if (_memberId != null) {
        final dietRes = await _apiClient.getMemberDietProgress(_memberId!);
        if (dietRes.statusCode == 200) {
          final dietBody = jsonDecode(dietRes.body);
          if (dietBody['success'] == true) {
            final progress = dietBody['data'];
            setState(() {
              _consumedCalories = progress['consumed_calories'] ?? 0;
              _targetCalories = progress['target_calories'] ?? 0;
            });
          }
        }

        // Fetch Progress Analytics
        final progressRes = await _apiClient.getProgressAnalytics(memberId: _memberId!.toString());
        if (progressRes.statusCode == 200) {
          final progressBody = jsonDecode(progressRes.body);
          if (progressBody['success'] == true) {
            final pData = progressBody['data'];
            final summary = pData['transformation_summary'] ?? {};
            setState(() {
              _currentWeight = double.tryParse(summary['current_weight']?.toString() ?? '0.0') ?? 0.0;
              _weightChange = double.tryParse(summary['weight_change']?.toString() ?? '0.0') ?? 0.0;
              _activeGoalsCount = pData['active_goals_count'] ?? 0;
            });
          }
        }
      }

      // Fetch consolidated member analytics
      try {
        final analyticsRes = await _apiClient.getMemberAnalytics();
        if (analyticsRes.statusCode == 200) {
          final analyticsBody = jsonDecode(analyticsRes.body);
          if (analyticsBody['success'] == true) {
            final aData = analyticsBody['data'];
            setState(() {
              _consistencyRate = (aData['attendance']?['consistency_rate_30d'] ?? 0.0).toDouble();
              _daysRemaining = aData['membership']?['days_remaining'] ?? 0;
              _planName = aData['membership']?['plan_name'];
            });
          }
        }
      } catch (_) {}

      // Fetch Gamification points balance
      try {
        final pointsRes = await _apiClient.getPointsBalance();
        if (pointsRes.statusCode == 200) {
          final pointsBody = jsonDecode(pointsRes.body);
          if (pointsBody['success'] == true) {
            setState(() {
              _pointsBalance = pointsBody['data']['balance'] ?? 0;
            });
          }
        }
      } catch (_) {}

      // Fetch Gamification personal rank
      try {
        final leaderboardRes = await _apiClient.getLeaderboard(period: 'all_time');
        if (leaderboardRes.statusCode == 200) {
          final lbBody = jsonDecode(leaderboardRes.body);
          if (lbBody['success'] == true) {
            final myRank = lbBody['data']['my_rank'];
            if (myRank != null) {
              setState(() {
                _rank = myRank['rank'];
              });
            }
          }
        }
      } catch (_) {}

      // Fetch daily tip
      try {
        final tipRes = await _apiClient.getDashboardTip();
        if (tipRes.statusCode == 200) {
          final tipBody = jsonDecode(tipRes.body);
          if (tipBody['success'] == true) {
            final tData = tipBody['data'];
            setState(() {
              _tipTitle = tData['tip_title'];
              _tipContent = tData['tip_content'];
              if (tData['related_article'] != null) {
                _tipArticleTitle = tData['related_article']['title'];
              }
            });
          }
        }
      } catch (_) {}
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
              _buildPointsAndRankCard(),
              const SizedBox(height: 16),
              _buildMetricCard(context, 'Next Session', 'Upper Body Power', Icons.fitness_center),
              const SizedBox(height: 16),
              _buildMetricCard(
                context,
                'Nutrition',
                _targetCalories > 0 ? '$_consumedCalories / $_targetCalories kcal' : 'No active diet plan',
                Icons.restaurant,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.push('/member/progress-tracker'),
                child: _buildMetricCard(
                  context,
                  'Weight & Transformation Goals',
                  _currentWeight > 0.0
                      ? '${_currentWeight.toStringAsFixed(1)} kg (${_weightChange >= 0 ? '+' : ''}${_weightChange.toStringAsFixed(1)} kg change) • $_activeGoalsCount Active Goals'
                      : 'Log your first weight measurement!',
                  Icons.trending_up,
                ),
              ),
              const SizedBox(height: 16),
              // Membership & Attendance Analytics Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Consistency (30d)', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '${_consistencyRate.toStringAsFixed(1)}%',
                            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    if (_planName != null) Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_planName ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '$_daysRemaining days left',
                            style: TextStyle(
                              color: _daysRemaining <= 7 ? Colors.orange : AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_tipTitle != null) ...[
                const SizedBox(height: 16),
                _buildDailyTipCard(),
              ],
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
                  _buildNavCard(context, 'AI Nutrition Planner', Icons.restaurant_menu, '/member/nutrition-dashboard'),
                  _buildNavCard(context, 'Exercise Library', Icons.menu_book, '/member/exercise-library'),
                  _buildNavCard(context, 'AI Gym Buddy', Icons.smart_toy, '/member/ai-buddy'),
                  _buildNavCard(context, 'AI Form Check', Icons.camera_alt, '/member/ai-form-check'),
                  _buildNavCard(context, 'Progress Tracker', Icons.trending_up, '/member/progress-tracker'),
                  _buildNavCard(context, 'Billing & Payments', Icons.payment, '/member/billing'),
                  _buildNavCard(context, 'Challenges', Icons.emoji_events, '/member/challenges'),
                  _buildNavCard(context, 'Rewards', Icons.star, '/member/rewards'),
                  _buildNavCard(context, 'Community Hub', Icons.forum, '/member/community'),
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

  Widget _buildPointsAndRankCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryFixed.withOpacity(0.15),
            AppColors.primaryFixed.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primaryFixed.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: AppColors.primaryFixed, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('REWARD POINTS', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('$_pointsBalance pts', style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          if (_rank != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text('Rank #$_rank', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
        ],
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

  Widget _buildDailyTipCard() {
    return GestureDetector(
      onTap: () => context.push('/member/ai-buddy'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1C1B1B),
              Color(0xFF25241C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.primaryFixed.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.primaryFixed, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "TODAY'S AI FITNESS TIP",
                  style: TextStyle(
                    color: AppColors.primaryFixed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: AppColors.primaryFixed.withOpacity(0.6), size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _tipTitle ?? '',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _tipContent ?? '',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (_tipArticleTitle != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book, color: Colors.blueAccent, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Read: $_tipArticleTitle',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
