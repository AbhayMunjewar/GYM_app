import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class GymSettings extends StatelessWidget {
  const GymSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('SETTINGS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader('Gym Profile'),
            _buildSettingTile('Operating Hours', Icons.schedule),
            _buildSettingTile('Location & Contact', Icons.location_on),
            const SizedBox(height: 24),
            _buildSectionHeader('App Configuration'),
            _buildSettingTile('Branding & Colors', Icons.color_lens),
            _buildSettingTile('Integrations', Icons.api),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB4AB), foregroundColor: AppColors.background),
              child: const Text('LOG OUT (OWNER)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildSettingTile(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.white),
        title: Text(title, style: const TextStyle(color: AppColors.white)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () {},
      ),
    );
  }
}
