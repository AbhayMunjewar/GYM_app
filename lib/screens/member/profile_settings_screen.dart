// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../components/glass_card.dart';
// import '../../components/kinetic_button.dart';
// import '../../theme/app_theme.dart';

// class ProfileSettingsScreen extends StatelessWidget {
//   const ProfileSettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('PROFILE & SETTINGS', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             GlassCard(
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 32,
//                     backgroundColor: AppColors.primary,
//                     child: Icon(Icons.person, color: Colors.black, size: 32),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Alex Walker', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
//                         Text('alex@example.com', style: TextStyle(color: AppColors.onSurfaceVariant)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             GlassCard(
//               padding: EdgeInsets.zero,
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.notifications, color: Colors.white),
//                     title: const Text('Notifications'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () {},
//                   ),
//                   const Divider(color: Colors.white10, height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.lock, color: Colors.white),
//                     title: const Text('Privacy & Security'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () {},
//                   ),
//                   const Divider(color: Colors.white10, height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.card_membership, color: Colors.white),
//                     title: const Text('Membership Plan'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             KineticButton(
//               text: 'Log Out',
//               style: KineticButtonStyle.secondary,
//               onPressed: () => context.go('/'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIProfileApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceLow = Color(0xFF1C1B1B);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIProfileApp extends StatelessWidget {
  const VelocityAIProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Profile & Settings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const ProfileSettingsScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _pushNotifs = true;
  bool _darkMode = true;
  bool _hapticFeedback = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopAppBar(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          
          return Row(
            children: [
              if (isDesktop) const DesktopSideNav(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16.0, 
                        100.0, 
                        16.0, 
                        isDesktop ? 48.0 : 120.0 
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const PremiumHeader(),
                          const SizedBox(height: 24),
                          _buildBentoGrid(isDesktop),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 
          ? const MobileBottomNav() 
          : null,
    );
  }

  // --- GRID LAYOUT LOGIC ---
  Widget _buildBentoGrid(bool isDesktop) {
    if (isDesktop) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(flex: 8, child: PersonalInfoCard()),
              SizedBox(width: 24),
              Expanded(flex: 4, child: GoalSettingsCard()),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: AppPreferencesCard(
                  pushNotifs: _pushNotifs,
                  darkMode: _darkMode,
                  hapticFeedback: _hapticFeedback,
                  onPushChanged: (val) => setState(() => _pushNotifs = val),
                  onDarkChanged: (val) => setState(() => _darkMode = val),
                  onHapticChanged: (val) => setState(() => _hapticFeedback = val),
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(flex: 6, child: PrivacySecurityCard()),
            ],
          )
        ],
      );
    }

    return Column(
      children: [
        const PersonalInfoCard(),
        const SizedBox(height: 24),
        const GoalSettingsCard(),
        const SizedBox(height: 24),
        AppPreferencesCard(
          pushNotifs: _pushNotifs,
          darkMode: _darkMode,
          hapticFeedback: _hapticFeedback,
          onPushChanged: (val) => setState(() => _pushNotifs = val),
          onDarkChanged: (val) => setState(() => _darkMode = val),
          onHapticChanged: (val) => setState(() => _hapticFeedback = val),
        ),
        const SizedBox(height: 24),
        const PrivacySecurityCard(),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class PremiumHeader extends StatelessWidget {
  const PremiumHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Abstract Glow Effect
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: kPrimary.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                // Avatar with PRO Badge
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary, width: 4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBeZ3q1Ka9uOgVePRuaB9XCuMsqhbSu8gNy7bqThlqNy_7En9iiez5armuX9dZMNZKvTOhIJ_Lrn4MfqG_k9U9l05OKGX2HVo9L7oQ83-Nhas7u-QjCmG5Q9n8j4BtB3tBBpmGjqeybRcqOyf3Ky-p9OEpbF-HCHsc2V3OpkCABLUsEMCA2B3fwSlpGZxfcaz0KbkKKT7EbY9o1Cxxl6RdF6J7oZ_85wNazG7fJYtX9yFRdZG_W0TQHd_HY_5jKZCMZwtmi85fbUnw'),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                          ),
                          child: const Text('PRO', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 32, height: isMobile ? 24 : 0),
                
                // Info Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                        spacing: 12,
                        runSpacing: 12,
                        children: const [
                          _TagPill(text: 'Tier: Elite Vanguard'),
                          _TagPill(text: 'Member since 2021'),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 32 : 0),

                // Right aligned metrics and CTA
                Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                      children: const [
                        Text('TOTAL ENERGY REPS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text('128,492', style: TextStyle(color: kPrimary, fontSize: 32, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 12,
                        shadowColor: kPrimary.withOpacity(0.3),
                      ),
                      onPressed: () {},
                      child: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    )
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

class _TagPill extends StatelessWidget {
  final String text;
  const _TagPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.person, color: kPrimary),
              SizedBox(width: 12),
              Text('Personal Information', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 32,
            runSpacing: 24,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : (MediaQuery.of(context).size.width / 2.5),
                child: const _InputField(label: 'FULL NAME', initialValue: 'Alex Rivers'),
              ),
              SizedBox(
                width: isMobile ? double.infinity : (MediaQuery.of(context).size.width / 2.5),
                child: const _InputField(label: 'EMAIL ADDRESS', initialValue: 'alex.r@velocity-ai.com'),
              ),
              SizedBox(
                width: isMobile ? double.infinity : (MediaQuery.of(context).size.width / 2.5),
                child: const _InputField(label: 'LOCATION', initialValue: 'San Francisco, CA'),
              ),
              SizedBox(
                width: isMobile ? double.infinity : (MediaQuery.of(context).size.width / 2.5),
                child: const _InputField(label: 'BIO', initialValue: 'Ultra-endurance athlete pushing the limits of human potential.', maxLines: 2),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final int maxLines;

  const _InputField({required this.label, required this.initialValue, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: kSurfaceLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimary)),
            contentPadding: const EdgeInsets.all(16),
          ),
        )
      ],
    );
  }
}

class GoalSettingsCard extends StatelessWidget {
  const GoalSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.track_changes, color: kPrimary),
                  SizedBox(width: 12),
                  Text('Current Goals', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              _ProgressBar(title: 'Weekly Distance', valueText: '85km / 100km', percent: 0.85),
              const SizedBox(height: 24),
              _ProgressBar(title: 'Calorie Target', valueText: '2.4k / 3k daily', percent: 0.70),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Text('ADJUST TARGETS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String title;
  final String valueText;
  final double percent;

  const _ProgressBar({required this.title, required this.valueText, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(valueText, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kSecondaryContainer, kPrimary]),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class AppPreferencesCard extends StatelessWidget {
  final bool pushNotifs;
  final bool darkMode;
  final bool hapticFeedback;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onDarkChanged;
  final ValueChanged<bool> onHapticChanged;

  const AppPreferencesCard({
    super.key,
    required this.pushNotifs,
    required this.darkMode,
    required this.hapticFeedback,
    required this.onPushChanged,
    required this.onDarkChanged,
    required this.onHapticChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune, color: kPrimary),
              SizedBox(width: 12),
              Text('App Preferences', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          _CustomSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Real-time alerts for training cues',
            value: pushNotifs,
            onChanged: onPushChanged,
          ),
          const SizedBox(height: 16),
          _CustomSwitchTile(
            title: 'Dark Mode (Obsidian)',
            subtitle: 'Optimized for high-contrast visibility',
            value: darkMode,
            onChanged: onDarkChanged,
          ),
          const SizedBox(height: 16),
          _CustomSwitchTile(
            title: 'Haptic Feedback',
            subtitle: 'Tactile response during heavy lifts',
            value: hapticFeedback,
            onChanged: onHapticChanged,
          ),
        ],
      ),
    );
  }
}

class _CustomSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitchTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kBackground, // Thumb color when active
            activeTrackColor: kPrimary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          )
        ],
      ),
    );
  }
}

class PrivacySecurityCard extends StatelessWidget {
  const PrivacySecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield, color: kPrimary),
              SizedBox(width: 12),
              Text('Privacy & Security', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          _ActionRow(
            icon: Icons.lock,
            title: 'Change Password',
            trailingIcon: Icons.chevron_right,
          ),
          const SizedBox(height: 12),
          _ActionRow(
            icon: Icons.visibility,
            title: 'Profile Visibility',
            trailingText: 'Public',
            trailingTextColor: kPrimary,
          ),
          const SizedBox(height: 12),
          _ActionRow(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            trailingText: 'Enabled',
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.logout, color: kError),
                  SizedBox(width: 16),
                  Text('Sign Out of All Devices', style: TextStyle(color: kError, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final IconData? trailingIcon;
  final String? trailingText;
  final Color trailingTextColor;

  const _ActionRow({
    required this.icon, 
    required this.title, 
    this.trailingIcon, 
    this.trailingText,
    this.trailingTextColor = kOnSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: kOnSurfaceVariant),
                const SizedBox(width: 16),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, color: kOnSurfaceVariant)
            else if (trailingText != null)
              Text(trailingText!, style: TextStyle(color: trailingTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- APP BAR & NAV COMPONENTS ---

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: kBackground.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.bolt, color: kPrimary),
                    SizedBox(width: 8),
                    Text(
                      'VELOCITY AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: kPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const Text('DASHBOARD', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      const Text('TRAINING', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      const Text('PROFILE', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                    ],
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      margin: const EdgeInsets.only(top: 64),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.7),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                        border: Border.all(color: kPrimary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDajYPDH4U8P12UQT0Ty68ANsPa6YMvuEjimb8I9XIQgNKoOfisU2HOMsv_djfaZvSw-9YuEbRWIddyN81tpAJVUm3zu0ZZLlGWQpG_TIRc1hNMMu-nwElAUmEOpc2UPs7t3dOf1829vg9KkpkQZd28apku05nidhu32VoznNFDWMZUCYBpa9GsZK8bxWTTXmjh7moKHufbSdhogl2Zo0_RLkLEfvi4D8L2S-XGlfbQxWbilr364Hcoy7zPe0rQMYmF0kcYr7sSBI0'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Level 42 • Pro Athlete', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                _NavTile(icon: Icons.settings, title: 'Settings', isActive: true),
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
        color: isActive ? kPrimary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? const Border(right: BorderSide(color: kPrimary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {},
      ),
    );
  }
}

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E).withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavIcon(icon: Icons.home, title: 'Home'),
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.person, title: 'Profile', isActive: true),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontSize: 12)),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
        ]
      ],
    );
  }
}

// --- UTILITY WIDGET ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}