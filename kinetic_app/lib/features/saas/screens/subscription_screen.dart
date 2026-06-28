import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_client.dart';

class SaasSubscriptionScreen extends StatefulWidget {
  const SaasSubscriptionScreen({super.key});

  @override
  State<SaasSubscriptionScreen> createState() => _SaasSubscriptionScreenState();
}

class _SaasSubscriptionScreenState extends State<SaasSubscriptionScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _errorMessage = '';

  Map<String, dynamic>? _subData;
  Map<String, dynamic>? _limitsData;
  final TextEditingController _licenseCtrl = TextEditingController();
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionDetail();
  }

  @override
  void dispose() {
    _licenseCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSubscriptionDetail() async {
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
            _subData = body['data']['subscription'];
            _limitsData = body['data']['limits'];
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load details');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load details. Code: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _activateLicense() async {
    final key = _licenseCtrl.text.trim();
    if (key.isEmpty) return;

    setState(() => _isActivating = true);
    try {
      final res = await _apiClient.activateLicense(key);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        _licenseCtrl.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('License key activated successfully!'), backgroundColor: Colors.green),
          );
        }
        _fetchSubscriptionDetail();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Activation failed'), backgroundColor: Colors.red),
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
      setState(() => _isActivating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planName = _subData?['plan_details']?['name'] ?? 'STARTER';
    final status = _subData?['status'] ?? 'TRIAL';
    final endDate = _subData?['end_date'] ?? '';
    final remDays = _subData?['remaining_days'] ?? 0;

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
          'SAAS SUBSCRIPTION',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage.isNotEmpty) ...[
                      Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                    ],
                    _buildActivePlanCard(planName, status, endDate, remDays),
                    const SizedBox(height: 24),
                    const Text('RESOURCE UTILIZATION', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildGaugeCard('Gym Members limit', _limitsData?['members']),
                    const SizedBox(height: 12),
                    _buildGaugeCard('Trainers limit', _limitsData?['trainers']),
                    const SizedBox(height: 12),
                    _buildGaugeCard('Multi-Branches limit', _limitsData?['branches']),
                    const SizedBox(height: 28),
                    _buildLicenseBox(),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/owner/saas-upgrade'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryFixed,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('UPGRADE PLAN', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/owner/saas-billing'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryFixed,
                              side: const BorderSide(color: AppColors.primaryFixed),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('VIEW BILLING', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActivePlanCard(String name, String status, String end, int days) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2E2D2D), AppColors.primaryFixed.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name.toUpperCase(),
                style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'ACTIVE' ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: status == 'ACTIVE' ? Colors.green : Colors.orange),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: status == 'ACTIVE' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            status == 'TRIAL' 
                ? 'Free Trial ends on $end' 
                : 'Next renewal billing date: $end',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.timer, color: AppColors.primaryFixed, size: 18),
              const SizedBox(width: 8),
              Text(
                '$days Days Remaining',
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGaugeCard(String title, Map<String, dynamic>? data) {
    final used = data?['used'] ?? 0;
    final maxVal = data?['max'] ?? 1;
    final ratio = (used / maxVal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
              Text('$used / $maxVal', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio > 0.85 ? Colors.redAccent : AppColors.primaryFixed,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLicenseBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACTIVATE ENTERPRISE LICENSE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          const Text('Enter your license key here to extend subscription validity.', style: TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _licenseCtrl,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'KEY-XXXX-XXXX',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    fillColor: const Color(0xFF1B1B1B),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isActivating ? null : _activateLicense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryFixed,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isActivating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                      : const Text('ACTIVATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
