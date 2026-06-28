import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_client.dart';

class SaasSuperAdminDashboardScreen extends StatefulWidget {
  const SaasSuperAdminDashboardScreen({super.key});

  @override
  State<SaasSuperAdminDashboardScreen> createState() => _SaasSuperAdminDashboardScreenState();
}

class _SaasSuperAdminDashboardScreenState extends State<SaasSuperAdminDashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _errorMessage = '';

  Map<String, dynamic>? _platformStats;
  Map<String, dynamic>? _breakdown;
  List<dynamic> _gyms = [];

  final TextEditingController _tenantIdCtrl = TextEditingController();
  final TextEditingController _expiryDaysCtrl = TextEditingController(text: '365');
  bool _isGenerating = false;
  String _generatedKey = '';

  @override
  void initState() {
    super.initState();
    _fetchSuperAdminDashboard();
  }

  @override
  void dispose() {
    _tenantIdCtrl.dispose();
    _expiryDaysCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSuperAdminDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await _apiClient.getSuperAdminDashboard();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _platformStats = body['data']['platform_stats'];
            _breakdown = body['data']['subscription_breakdown'];
            _gyms = body['data']['gyms'] ?? [];
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load dashboard');
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

  Future<void> _generateKey() async {
    final tenantId = _tenantIdCtrl.text.trim();
    final days = int.tryParse(_expiryDaysCtrl.text.trim()) ?? 365;

    if (tenantId.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedKey = '';
    });

    try {
      final res = await _apiClient.generateLicenseKey(tenantId, days);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() {
          _generatedKey = body['data']['license_key'] ?? '';
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Key generation failed'), backgroundColor: Colors.red),
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
      setState(() => _isGenerating = false);
    }
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
          'SUPER ADMIN TELEMETRY',
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
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildKeyGeneratorBox(),
                    const SizedBox(height: 24),
                    const Text('REGISTERED GYM TENANTS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    if (_gyms.isEmpty)
                      const Text('No gyms onboarded yet.', style: TextStyle(color: AppColors.onSurfaceVariant))
                    else
                      ..._gyms.map((g) => _buildGymTenantCard(g)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final revenue = _platformStats?['total_revenue'] ?? 0.00;
    final gymsCount = _platformStats?['total_gyms'] ?? 0;
    final activeCount = _breakdown?['active'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard('Total Revenue', '₹$revenue', Icons.attach_money, const Color(0xFFCAF300)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStatCard('Gym Tenants', '$gymsCount ($activeCount Active)', Icons.domain, const Color(0xFF4B8EFF)),
        )
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              Icon(icon, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildKeyGeneratorBox() {
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
          const Text('GENERATE LICENSE KEY', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _tenantIdCtrl,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Tenant ID (UUID)',
              labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
              fillColor: const Color(0xFF1B1B1B),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryDaysCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Expiry Days',
                    labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                    fillColor: const Color(0xFF1B1B1B),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryFixed,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isGenerating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                      : const Text('GENERATE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          if (_generatedKey.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryFixed.withOpacity(0.2)),
              ),
              child: SelectableText(
                _generatedKey,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildGymTenantCard(Map<String, dynamic> g) {
    final name = g['gym_name'] ?? '';
    final owner = g['owner'] ?? '';
    final city = g['city'] ?? '';
    final plan = g['plan'] ?? 'None';
    final statusVal = g['status'] ?? 'None';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(name, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusVal == 'ACTIVE' ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusVal,
                  style: TextStyle(color: statusVal == 'ACTIVE' ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text('Owner: $owner', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text('Location: $city', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text('SaaS Plan: $plan', style: const TextStyle(color: AppColors.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
