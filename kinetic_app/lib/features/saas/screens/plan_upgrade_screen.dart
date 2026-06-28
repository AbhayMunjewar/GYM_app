import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_client.dart';

class SaasPlanUpgradeScreen extends StatefulWidget {
  const SaasPlanUpgradeScreen({super.key});

  @override
  State<SaasPlanUpgradeScreen> createState() => _SaasPlanUpgradeScreenState();
}

class _SaasPlanUpgradeScreenState extends State<SaasPlanUpgradeScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _errorMessage = '';

  List<dynamic> _plans = [];
  String _activePlanName = 'STARTER';
  String _billingCycle = 'monthly'; // monthly / yearly
  bool _isUpgrading = false;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchSubscriptionPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await _apiClient.getSubscriptionDetail();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _plans = body['data']['available_plans'] ?? [];
            _activePlanName = body['data']['subscription']['plan_details']['name'] ?? 'STARTER';
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load plans');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load plans. Code: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyPlanChange(String planId, String targetName) async {
    final bool isDowngrade = _isPlanSmaller(targetName, _activePlanName);

    setState(() => _isUpgrading = true);
    try {
      final res = isDowngrade 
          ? await _apiClient.downgradePlan(planId)
          : await _apiClient.upgradePlan(planId, _billingCycle);
      
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isDowngrade ? 'Plan downgraded successfully.' : 'Plan upgraded! Please check pending invoices.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Go back
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Action failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isUpgrading = false);
    }
  }

  bool _isPlanSmaller(String target, String current) {
    const weights = {'FREE': 0, 'STARTER': 1, 'PROFESSIONAL': 2, 'ENTERPRISE': 3};
    final targetW = weights[target] ?? 0;
    final currentW = weights[current] ?? 0;
    return targetW < currentW;
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
        title: const Text(
          'COMPARE SAAS PLANS',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage.isNotEmpty) ...[
                      Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                    ],
                    _buildCycleToggle(),
                    const SizedBox(height: 24),
                    ..._plans.map((plan) => _buildPlanComparisonCard(plan)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCycleToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _billingCycle = 'monthly'),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _billingCycle == 'monthly' ? AppColors.primaryFixed : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Monthly Billing',
                  style: TextStyle(
                    color: _billingCycle == 'monthly' ? AppColors.background : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _billingCycle = 'yearly'),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _billingCycle == 'yearly' ? AppColors.primaryFixed : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Yearly Save 20%',
                  style: TextStyle(
                    color: _billingCycle == 'yearly' ? AppColors.background : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanComparisonCard(Map<String, dynamic> plan) {
    final name = plan['name'] as String;
    final planId = plan['id'];
    final isActive = name == _activePlanName;
    
    final priceStr = _billingCycle == 'monthly' 
        ? '₹${plan['price_monthly']}' 
        : '₹${plan['price_yearly']}';
    
    final isSmaller = _isPlanSmaller(name, _activePlanName);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryFixed : AppColors.white.withOpacity(0.04),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isActive ? AppColors.primaryFixed : AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('CURRENT PLAN', style: TextStyle(color: AppColors.primaryFixed, fontSize: 9, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$priceStr / ${_billingCycle == 'monthly' ? 'month' : 'year'}',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const Divider(color: Colors.white10, height: 28),
          _buildFeatureRow('Max Members', '${plan['max_members']}'),
          _buildFeatureRow('Max Trainers', '${plan['max_trainers']}'),
          _buildFeatureRow('Multi-Branches Limit', '${plan['max_branches']} branch(es)'),
          _buildFeatureRow('AI Gym Buddy Module', plan['ai_features_access'] == true ? 'Included' : 'Not Included', has: plan['ai_features_access'] == true),
          _buildFeatureRow('Analytics & Telemetry Reporting', plan['analytics_access'] == true ? 'Included' : 'Not Included', has: plan['analytics_access'] == true),
          _buildFeatureRow('Community Portal & Feeds', plan['community_access'] == true ? 'Included' : 'Not Included', has: plan['community_access'] == true),
          const SizedBox(height: 24),
          if (!isActive)
            ElevatedButton(
              onPressed: _isUpgrading ? null : () => _applyPlanChange(planId, name),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSmaller ? Colors.white12 : AppColors.primaryFixed,
                foregroundColor: isSmaller ? AppColors.white : AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isUpgrading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                  : Text(isSmaller ? 'DOWNGRADE TO $name' : 'UPGRADE TO $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, String desc, {bool has = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(feature, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          Text(
            desc,
            style: TextStyle(
              color: has ? AppColors.white : Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          )
        ],
      ),
    );
  }
}
