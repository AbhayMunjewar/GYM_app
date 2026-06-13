import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final ApiClient _apiClient = ApiClient();
  
  String _revenue = '\$0.00';
  String _membersCount = '0';
  String _checkInsCount = '0';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    bool success = false;
    try {
      final response = await _apiClient.getOwnerAnalytics();
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'];
          setState(() {
            _revenue = '\$${data['revenue']['total_revenue']}';
            _membersCount = data['memberships']['active_memberships'].toString();
            _checkInsCount = data['attendance']['today_check_ins'].toString();
          });
          success = true;
        }
      }
    } catch (_) {}

    if (!success) {
      try {
        final response = await _apiClient.getDashboardStats();
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body['success'] == true) {
            final data = body['data'];
            setState(() {
              _revenue = '\$${data['total_revenue']}';
              _membersCount = data['total_active_memberships'].toString();
            });
          }
        }

        final response2 = await _apiClient.getOwnerDashboardAttendance();
        if (response2.statusCode == 200) {
          final body2 = jsonDecode(response2.body);
          if (body2['success'] == true) {
            final data2 = body2['data'];
            setState(() {
              _checkInsCount = data2['present_today'].toString();
            });
          }
        }
      } catch (_) {}
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('OWNER HQ', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: AppColors.white), onPressed: () => context.push('/notifications')),
          IconButton(icon: const Icon(Icons.settings, color: AppColors.white), onPressed: () => context.push('/owner/settings')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
              else ...[
                _buildMetricCard(context, 'Total Revenue', _revenue, Icons.attach_money),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard(context, 'Active Memberships', _membersCount, Icons.people)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMetricCard(context, 'Check-ins', '$_checkInsCount Today', Icons.how_to_reg)),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              const Text('OPERATIONS', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildNavCard(context, 'Members', Icons.people, '/owner/members'),
                  _buildNavCard(context, 'Trainers', Icons.sports, '/owner/trainers'),
                  _buildNavCard(context, 'Attendance', Icons.how_to_reg, '/owner/attendance'),
                  _buildNavCard(context, 'QR Check-in', Icons.qr_code, null, onTap: () => _showQRCodeSheet(context)),
                  _buildNavCard(context, 'Billing', Icons.payment, '/owner/billing'),
                  _buildNavCard(context, 'Analytics', Icons.bar_chart, '/owner/analytics'),
                  _buildNavCard(context, 'Challenges', Icons.emoji_events, '/owner/challenges'),
                  _buildNavCard(context, 'Comms', Icons.campaign, '/owner/communication'),
                  _buildNavCard(context, 'Plans', Icons.card_membership, '/owner/subscription'),
                  _buildNavCard(context, 'Sessions', Icons.calendar_month, '/owner/sessions'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryFixed, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, String? route, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        if (route != null) context.push(route);
      },
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

  void _showQRCodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return const _QRCodeSheet();
      },
    );
  }
}

class _QRCodeSheet extends StatefulWidget {
  const _QRCodeSheet();

  @override
  State<_QRCodeSheet> createState() => _QRCodeSheetState();
}

class _QRCodeSheetState extends State<_QRCodeSheet> {
  final ApiClient _apiClient = ApiClient();
  String? _qrToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateQR();
  }

  Future<void> _generateQR() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.generateQRCode({'qr_type': 'DYNAMIC'});
      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _qrToken = body['data']['qr_token'];
          });
        }
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('GYM QR CODE', style: TextStyle(color: AppColors.primaryFixed, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (_isLoading)
            const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.primaryFixed)))
          else if (_qrToken != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: QrImageView(
                data: _qrToken!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Scan this code using the Kinetic Member app to check in.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: AppColors.background),
              label: const Text('REGENERATE QR', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _generateQR,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else
            const Text('Failed to generate QR Code.', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
