import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class CommunicationCenter extends StatelessWidget {
  const CommunicationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ANNOUNCEMENTS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.campaign),
                label: const Text('NEW BROADCAST'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.onPrimaryFixed,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 4,
                itemBuilder: (context, index) => Card(
                  color: const Color(0xFF201F1F),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.notifications, color: AppColors.primaryFixed),
                    title: const Text('Holiday Hours Update', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Sent to: All Members', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    trailing: const Text('2d ago', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
