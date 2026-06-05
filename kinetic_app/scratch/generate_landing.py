import os

landing_page_dart = """import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: AppColors.background.withValues(alpha: 0.8),
              elevation: 0,
              title: Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.primaryFixed),
                  const SizedBox(width: 8),
                  Text(
                    'VELOCITY AI',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primaryFixed,
                        ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: AppColors.onSurfaceVariant),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryFixed.withValues(alpha: 0.15),
                    blurRadius: 120,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.1),
                    blurRadius: 120,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeroSection(),
                const SizedBox(height: 80),
                const _FeaturesShowcase(),
                const SizedBox(height: 80),
                const _TestimonialsSlider(),
                const SizedBox(height: 80),
                const _FinalCta(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'NEXT-GEN AI FITNESS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primaryFixed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Transform\\nYour Life',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Unlock peak performance with the world\\'s most advanced AI training ecosystem. Precision data, elite coaching, and real-time biomechanics.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryFixed,
              foregroundColor: AppColors.onPrimaryFixed,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 10,
              shadowColor: AppColors.primaryFixed.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('GET STARTED', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.white20),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.white10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('WATCH DEMO', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.play_circle_fill),
              ],
            ),
          ),
          const SizedBox(height: 48),
          
          // Floating KPI Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURRENT RECOVERY', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text('94%', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.primaryFixed)),
                      ],
                    ),
                    const Icon(Icons.trending_up, color: AppColors.secondaryContainer, size: 36),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: Container(height: 16, decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 24, decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 32, decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 40, decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 48, decoration: BoxDecoration(color: AppColors.primaryFixed, borderRadius: BorderRadius.circular(2)))),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesShowcase extends StatelessWidget {
  const _FeaturesShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text('Technical Precision', style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Data-driven tools built for elite athletes.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
          const SizedBox(height: 40),
          
          _FeatureCard(
            icon: Icons.smart_toy,
            iconColor: AppColors.primaryFixed,
            title: 'AI Coaching',
            desc: 'Personalized training logic that adapts in real-time based on your HRV, sleep data, and past performance.',
            action: 'LEARN MORE',
          ),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.restaurant,
            iconColor: AppColors.secondaryContainer,
            title: 'Diet Planning',
            desc: 'Fuel your engine with precision macros calculated for your specific metabolic output and daily goals.',
            action: 'VIEW PLANS',
          ),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.fitness_center,
            iconColor: AppColors.white,
            title: 'Form Check',
            desc: 'Computer vision analyzes your movement patterns to prevent injury and maximize every repetition.',
            action: 'TRY IT NOW',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final String action;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.white10),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(action, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Icon(Icons.chevron_right, color: iconColor),
            ],
          )
        ],
      ),
    );
  }
}

class _TestimonialsSlider extends StatelessWidget {
  const _TestimonialsSlider();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Elite Athletes', style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Join the community of 1M+ performers.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 450,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: const [
              _TestimonialCard(
                image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDRQgloyW4d0rvFk6n0CdSOntLZTR6zWvguU44pHF-RUeaHMCVicqkw2OwTRSqRSMHTYmdxvgekByubLR2NHot6VYTWeDFvO28LDzDJ3-m-4OHaNCQJfDG4sjqrSxwbnHvv53FGpyxxirzjkMESL00dghKdxeXxg4bnKBeEsvdSbPsknfur_sk_IrffflCHHiT4r0fxodSmArGYUBmwv9vNNt9BlsA3ujnU4dZ1a5fjp0-O0KoEJDUwW2QGXYWMtUXNg77Bft-xQbQ',
                quote: '\\"Velocity AI completely changed how I approach my recovery days. The precision is unmatched.\\"',
                name: 'Marcus Sterling',
                role: 'Pro Triathlete',
                avatarColor: AppColors.primaryFixed,
              ),
              SizedBox(width: 16),
              _TestimonialCard(
                image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALDB2gnSnTyBeDW73F01PGufdUgVferJmBGD3K5O_VAYlOokPSnbDEDTIEgtIZJfmIMpZyss56nh5do0B8q6srLoA6BhNXd97UdZ6CpKe0QFnU8eRu3X4GOdVIknqH7lZEaiD5cjdK8KuyW8wO3wVZPjEW323t3Ntzr3_Wukhb87kppeYGLWVevVWBDj6KI7IlFIFMZw7Bp8g9p08z6qlGXATU_zKY0wp8ANJMoYc4hjQfzG4dsb7He1NnUzBPvuHW4ru45BfbBiM',
                quote: '\\"The form check feature caught a shoulder misalignment my human coach missed. Essential tool.\\"',
                name: 'Elena Rodriguez',
                role: 'Olympic Hopeful',
                avatarColor: AppColors.secondaryContainer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String image;
  final String quote;
  final String name;
  final String role;
  final Color avatarColor;

  const _TestimonialCard({
    required this.image,
    required this.quote,
    required this.name,
    required this.role,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(image, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (_) => const Icon(Icons.star, color: AppColors.primaryFixed, size: 16)),
                ),
                const SizedBox(height: 16),
                Text(quote, style: const TextStyle(color: AppColors.white, fontStyle: FontStyle.italic, fontSize: 16)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: avatarColor.withValues(alpha: 0.2), shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                        Text(role, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _FinalCta extends StatelessWidget {
  const _FinalCta();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            const Text('READY TO ASCEND?', style: TextStyle(color: AppColors.onPrimaryFixedVariant, fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            const Text('Download the app and start your 14-day free trial today. No commitment required.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF131313),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.apple),
                  SizedBox(width: 12),
                  Text('APP STORE', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onPrimaryFixedVariant,
                side: BorderSide(color: AppColors.onPrimaryContainer.withValues(alpha: 0.2)),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 0),
                backgroundColor: AppColors.white.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 12),
                  Text('GOOGLE PLAY', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: AppColors.white10)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(icon: Icons.home, title: 'Home', isActive: true),
              _NavIcon(icon: Icons.fitness_center, title: 'Workouts', isActive: false),
              _NavIcon(icon: Icons.smart_toy, title: 'AI Buddy', isActive: false),
              _NavIcon(icon: Icons.bar_chart, title: 'Stats', isActive: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _NavIcon({required this.icon, required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryFixed : AppColors.onSurfaceVariant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: color, fontSize: 12)),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ]
      ],
    );
  }
}
"""

with open('d:/GYM/kinetic_app/lib/screens/landing_page.dart', 'w', encoding='utf-8') as f:
    f.write(landing_page_dart)
print("Created landing_page.dart")
