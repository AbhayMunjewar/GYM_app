import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class ChallengesLeaderboard extends StatefulWidget {
  const ChallengesLeaderboard({super.key});

  @override
  State<ChallengesLeaderboard> createState() => _ChallengesLeaderboardState();
}

class _ChallengesLeaderboardState extends State<ChallengesLeaderboard> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _challenges = [];
  List<dynamic> _leaderboard = [];
  Map<String, dynamic>? _myRank;
  String _selectedPeriod = 'all_time';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Challenges
      final challengeRes = await _apiClient.getChallenges();
      if (challengeRes.statusCode == 200) {
        final body = jsonDecode(challengeRes.body);
        if (body['success'] == true) {
          _challenges = body['data'] ?? [];
        }
      }

      // 2. Fetch Leaderboard for selected period
      final lbRes = await _apiClient.getLeaderboard(period: _selectedPeriod);
      if (lbRes.statusCode == 200) {
        final body = jsonDecode(lbRes.body);
        if (body['success'] == true) {
          final lbData = body['data'];
          _leaderboard = lbData['rankings'] ?? [];
          _myRank = lbData['my_rank'];
        }
      }
    } catch (e) {
      print('Error loading challenges/leaderboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinChallenge(String challengeId, String title) async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.joinChallenge(challengeId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined challenge "$title" successfully! Go crush it!'), backgroundColor: Colors.green),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed to join challenge.'), backgroundColor: Colors.redAccent),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onPeriodChanged(String period) {
    if (_selectedPeriod == period) return;
    setState(() {
      _selectedPeriod = period;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('CHALLENGES & RANKS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ACTIVE CHALLENGES',
                      style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    _buildChallengesSection(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'LEADERBOARD',
                          style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        _buildPeriodSelector(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_myRank != null) ...[
                      _buildRankItem(
                        _myRank!['rank'] ?? 0,
                        '${_myRank!['member_name']} (You)',
                        '${_myRank!['total_points']} pts',
                        _myRank!['streak'] ?? 0,
                        isMe: true,
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.white10),
                      const SizedBox(height: 12),
                    ],
                    _buildLeaderboardList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildChallengesSection() {
    if (_challenges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No active challenges at the moment.', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
      );
    }

    return Column(
      children: _challenges.map<Widget>((challenge) {
        final id = challenge['id'];
        final name = challenge['challenge_name'] ?? 'Challenge';
        final desc = challenge['description'] ?? '';
        final reward = challenge['reward_points'] ?? 0;
        final target = challenge['target_value'] ?? 0.0;
        final isJoined = challenge['is_joined'] ?? false;
        final completionPct = (challenge['completion_percentage'] ?? 0.0).toDouble() / 100.0;
        final progress = challenge['progress'] ?? 0.0;
        final unit = challenge['challenge_type'] == 'ATTENDANCE' ? 'check-ins' : 'sessions';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF201F1F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isJoined ? AppColors.primaryFixed.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$reward pts',
                      style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              if (isJoined) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${progress.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(completionPct * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: AppColors.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionPct,
                    backgroundColor: AppColors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryFixed),
                    minHeight: 8,
                  ),
                ),
              ] else
                ElevatedButton(
                  onPressed: () => _joinChallenge(id, name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryFixed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Join Challenge', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodChip('all_time', 'All'),
          _buildPeriodChip('monthly', 'Month'),
          _buildPeriodChip('weekly', 'Week'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => _onPeriodChanged(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (_leaderboard.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: const Text('No ranking data available for this period.', style: TextStyle(color: AppColors.onSurfaceVariant)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final rank = _leaderboard[index];
        final isMe = _myRank != null && rank['member_id'] == _myRank!['member_id'];
        
        // Skip rendering "Me" again in the main list if we already highlight it on top
        if (isMe) return const SizedBox.shrink();

        return _buildRankItem(
          rank['rank'] ?? (index + 1),
          rank['member_name'] ?? 'Member',
          '${rank['total_points']} pts',
          rank['streak'] ?? 0,
        );
      },
    );
  }

  Widget _buildRankItem(int rank, String name, String score, int streak, {bool isMe = false}) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = AppColors.onSurfaceVariant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryFixed.withOpacity(0.12) : const Color(0xFF201F1F),
        border: Border.all(
          color: isMe ? AppColors.primaryFixed : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (streak > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '$streak',
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            score,
            style: TextStyle(
              color: isMe ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
