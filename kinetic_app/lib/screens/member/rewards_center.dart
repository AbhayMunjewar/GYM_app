import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class RewardsCenter extends StatefulWidget {
  const RewardsCenter({super.key});

  @override
  State<RewardsCenter> createState() => _RewardsCenterState();
}

class _RewardsCenterState extends State<RewardsCenter> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  int _pointsBalance = 0;
  List<dynamic> _catalog = [];
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Load Points Balance
      final pointsRes = await _apiClient.getPointsBalance();
      if (pointsRes.statusCode == 200) {
        final body = jsonDecode(pointsRes.body);
        if (body['success'] == true) {
          _pointsBalance = body['data']['balance'] ?? 0;
        }
      }

      // 2. Load Catalog
      final catalogRes = await _apiClient.getRewardCatalog();
      if (catalogRes.statusCode == 200) {
        final body = jsonDecode(catalogRes.body);
        if (body['success'] == true) {
          _catalog = body['data'] ?? [];
        }
      }

      // 3. Load Redemption History
      final historyRes = await _apiClient.getRedemptionHistory();
      if (historyRes.statusCode == 200) {
        final body = jsonDecode(historyRes.body);
        if (body['success'] == true) {
          _history = body['data'] ?? [];
        }
      }
    } catch (e) {
      print('Error loading rewards data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _redeemReward(String rewardId, String title, int cost) async {
    if (_pointsBalance < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient points to redeem this reward.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Confirm Redemption', style: TextStyle(color: AppColors.white)),
        content: Text('Are you sure you want to redeem "$title" for $cost points?', style: const TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
            child: const Text('Redeem', style: TextStyle(color: AppColors.onPrimaryFixed)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.redeemReward(rewardId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully claimed "$title"! Gym owner approval is pending.'), backgroundColor: Colors.green),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Failed to redeem reward.'), backgroundColor: Colors.redAccent),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text('REWARDS CENTER', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryFixed,
            labelColor: AppColors.primaryFixed,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            tabs: [
              Tab(text: 'Catalog'),
              Tab(text: 'My Claims'),
            ],
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      _buildPointsHeader(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildCatalogTab(),
                            _buildHistoryTab(),
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

  Widget _buildPointsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryFixed.withOpacity(0.25),
            AppColors.primaryFixed.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primaryFixed.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('YOUR BALANCE', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: AppColors.primaryFixed, size: 36),
              const SizedBox(width: 8),
              Text(
                '$_pointsBalance',
                style: const TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Text('pts', style: TextStyle(color: AppColors.primaryFixed, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogTab() {
    if (_catalog.isEmpty) {
      return const Center(child: Text('No rewards available in the catalog.', style: TextStyle(color: AppColors.onSurfaceVariant)));
    }

    return ListView.builder(
      itemCount: _catalog.length,
      itemBuilder: (context, index) {
        final item = _catalog[index];
        final id = item['id'];
        final title = item['title'] ?? 'Reward';
        final desc = item['description'] ?? '';
        final cost = item['points_cost'] ?? 0;
        final canRedeem = _pointsBalance >= cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF201F1F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: canRedeem ? AppColors.primaryFixed.withOpacity(0.2) : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canRedeem ? AppColors.primaryFixed.withOpacity(0.1) : AppColors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: canRedeem ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 8),
                    Text('$cost pts', style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: canRedeem ? () => _redeemReward(id, title, cost) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  disabledBackgroundColor: AppColors.white.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Claim',
                  style: TextStyle(
                    color: canRedeem ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(child: Text('You have not claimed any rewards yet.', style: TextStyle(color: AppColors.onSurfaceVariant)));
    }

    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final claim = _history[index];
        final title = claim['reward_title'] ?? 'Reward';
        final cost = claim['points_spent'] ?? 0;
        final status = claim['status'] ?? 'PENDING';
        final dateStr = claim['redemption_date']?.toString().split('T').first ?? '';

        Color statusColor;
        IconData statusIcon;

        switch (status.toUpperCase()) {
          case 'APPROVED':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle_outline;
            break;
          case 'REJECTED':
            statusColor = Colors.redAccent;
            statusIcon = Icons.highlight_off;
            break;
          default:
            statusColor = Colors.orangeAccent;
            statusIcon = Icons.hourglass_empty;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF201F1F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('$cost pts', style: const TextStyle(color: AppColors.primaryFixed, fontSize: 13, fontWeight: FontWeight.w600)),
                        if (dateStr.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text('•', style: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5))),
                          const SizedBox(width: 8),
                          Text(dateStr, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
