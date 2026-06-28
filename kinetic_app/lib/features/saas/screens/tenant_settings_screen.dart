import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_client.dart';

class SaasTenantSettingsScreen extends StatefulWidget {
  const SaasTenantSettingsScreen({super.key});

  @override
  State<SaasTenantSettingsScreen> createState() => _SaasTenantSettingsScreenState();
}

class _SaasTenantSettingsScreenState extends State<SaasTenantSettingsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isSaving = false;

  String _selectedTimezone = 'Asia/Kolkata (IST)';
  String _selectedCurrency = 'INR (₹)';
  String _selectedThemeColor = 'Kinetic Neon Green';

  final List<String> _timezones = [
    'Asia/Kolkata (IST)',
    'UTC (GMT)',
    'America/New_York (EST)',
    'Europe/London (GMT/BST)',
    'Asia/Singapore (SGT)'
  ];

  final List<String> _currencies = ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'];
  final List<String> _themeColors = ['Kinetic Neon Green', 'Sleek Crimson Red', 'Cyberpunk Purple', 'Oceanic Blue'];

  void _saveSettings() {
    setState(() => _isSaving = true);
    
    // Simulate updating settings on server
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant settings updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    });
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
          'TENANT SETTINGS',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('SYSTEM CONFIGURATIONS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 20),
              _buildDropdown('Default System Timezone', _selectedTimezone, _timezones, (val) {
                if (val != null) setState(() => _selectedTimezone = val);
              }),
              const SizedBox(height: 16),
              _buildDropdown('Billing Currency Symbol', _selectedCurrency, _currencies, (val) {
                if (val != null) setState(() => _selectedCurrency = val);
              }),
              const SizedBox(height: 16),
              _buildDropdown('Branding Theme Accent Color', _selectedThemeColor, _themeColors, (val) {
                if (val != null) setState(() => _selectedThemeColor = val);
              }),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                    : const Text('SAVE SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            dropdownColor: const Color(0xFF201F1F),
            style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.bold),
            items: items.map((i) {
              return DropdownMenuItem<String>(
                value: i,
                child: Text(i),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
