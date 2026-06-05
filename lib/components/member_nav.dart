import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../utils/nav_utils.dart';

class DesktopSideNav extends StatelessWidget {
  final String activeTitle;
  const DesktopSideNav({super.key, required this.activeTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        border: const Border(right: BorderSide(color: Colors.white10)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBeZ3q1Ka9uOgVePRuaB9XCuMsqhbSu8gNy7bqThlqNy_7En9iiez5armuX9dZMNZKvTOhIJ_Lrn4MfqG_k9U9l05OKGX2HVo9L7oQ83-Nhas7u-QjCmG5Q9n8j4BtB3tBBpmGjqeybRcqOyf3Ky-p9OEpbF-HCHsc2V3OpkCABLUsEMCA2B3fwSlpGZxfcaz0KbkKKT7EbY9o1Cxxl6RdF6J7oZ_85wNazG7fJYtX9yFRdZG_W0TQHd_HY_5jKZCMZwtmi85fbUnw'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('LEVEL 42', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _NavTile(icon: Icons.dashboard, title: 'Dashboard', isActive: activeTitle == 'Dashboard'),
                      _NavTile(icon: Icons.fitness_center, title: 'Workouts', isActive: activeTitle == 'Workouts'),
                      _NavTile(icon: Icons.restaurant, title: 'Diets', isActive: activeTitle == 'Diets'),
                      _NavTile(icon: Icons.camera_alt, title: 'Form Check', isActive: activeTitle == 'Form Check'),
                      _NavTile(icon: Icons.analytics, title: 'Progress', isActive: activeTitle == 'Progress'),
                      _NavTile(icon: Icons.emoji_events, title: 'Challenges', isActive: activeTitle == 'Challenges'),
                      _NavTile(icon: Icons.military_tech, title: 'Rewards', isActive: activeTitle == 'Rewards'),
                      _NavTile(icon: Icons.card_membership, title: 'Membership', isActive: activeTitle == 'Membership'),
                      _NavTile(icon: Icons.notifications, title: 'Notifications', isActive: activeTitle == 'Notifications'),
                      _NavTile(icon: Icons.settings, title: 'Settings', isActive: activeTitle == 'Settings'),
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
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _NavTile({required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? const Border(right: BorderSide(color: AppColors.primary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => navigateByTitle(context, title),
      ),
    );
  }
}

class MobileBottomNav extends StatelessWidget {
  final String activeTitle;
  const MobileBottomNav({super.key, required this.activeTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E).withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavIcon(icon: Icons.home, title: 'Home', isActive: activeTitle == 'Dashboard'),
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts', isActive: activeTitle == 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy', isActive: activeTitle == 'AI Buddy'),
              _BottomNavIcon(icon: Icons.bar_chart, title: 'Stats', isActive: activeTitle == 'Progress'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _BottomNavIcon({required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateByTitle(context, title),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          ]
        ],
      ),
    );
  }
}
