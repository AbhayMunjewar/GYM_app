import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAITrainerProfileApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceLow = Color(0xFF131313);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAITrainerProfileApp extends StatelessWidget {
  const VelocityAITrainerProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Trainer Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const TrainerProfileScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  bool _alertsEnabled = true;
  bool _visibilityEnabled = true;
  bool _biometricEnabled = false;

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
                        24.0, 
                        100.0, 
                        24.0, 
                        isDesktop ? 48.0 : 120.0
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const ProfileHeaderCard(),
                          const SizedBox(height: 32),
                          _buildStatsAndCerts(isDesktop),
                          const SizedBox(height: 48),
                          _buildSettingsSection(isDesktop),
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

  Widget _buildStatsAndCerts(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(flex: 8, child: CertificationsCard()),
          SizedBox(width: 24),
          Expanded(flex: 4, child: QuickStatsCard()),
        ],
      );
    }
    return Column(
      children: const [
        CertificationsCard(),
        SizedBox(height: 24),
        QuickStatsCard(),
      ],
    );
  }

  Widget _buildSettingsSection(bool isDesktop) {
    final settingsTitle = Row(
      children: const [
        Text('App Settings', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
      ],
    );

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settingsTitle,
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: PersonalInfoCard()),
              const SizedBox(width: 24),
              Expanded(
                child: AppPreferencesCard(
                  alertsEnabled: _alertsEnabled,
                  visibilityEnabled: _visibilityEnabled,
                  biometricEnabled: _biometricEnabled,
                  onAlertsChanged: (val) => setState(() => _alertsEnabled = val),
                  onVisibilityChanged: (val) => setState(() => _visibilityEnabled = val),
                  onBiometricChanged: (val) => setState(() => _biometricEnabled = val),
                ),
              ),
            ],
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsTitle,
        const SizedBox(height: 24),
        const PersonalInfoCard(),
        const SizedBox(height: 24),
        AppPreferencesCard(
          alertsEnabled: _alertsEnabled,
          visibilityEnabled: _visibilityEnabled,
          biometricEnabled: _biometricEnabled,
          onAlertsChanged: (val) => setState(() => _alertsEnabled = val),
          onVisibilityChanged: (val) => setState(() => _visibilityEnabled = val),
          onBiometricChanged: (val) => setState(() => _biometricEnabled = val),
        ),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Abstract Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                // Avatar Area
                SizedBox(
                  width: isMobile ? 128 : 160,
                  height: isMobile ? 128 : 160,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary, width: 4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBz0DkVFEREGufDN2sEBvIXdafMlV5FiVfb-n8kupvAygDlyvOKovrydaQkfScT1IeUb18PB8Ui3aCzS1ncwEtpvIKmyG88J6zQeVxP4csuFXrKx9vfZKBqxEsLd8PcltB6d_Y29dGb2gFsQ5zGdOa_qNH3vZI9pxYrwTkx601GQUxaNJyipTRNZ2lmT0e4pwuzQ3BQ1Qz8d6y2Z66LTQ8F85bpvtil_wxShBZJWeAJpeoVCJLBFEBYTpLgs1X8LEqb15mZWCXcQyM'),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, color: Colors.black, size: 16),
                              SizedBox(width: 4),
                              Text('PRO', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 32, height: isMobile ? 24 : 0),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, letterSpacing: -1, height: 1)),
                      const SizedBox(height: 8),
                      Text(
                        'Master Performance Coach with 12+ years experience in metabolic conditioning and explosive power training.',
                        style: const TextStyle(color: kOnSurfaceVariant, fontSize: 16, height: 1.4),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star, color: kPrimary, size: 20),
                              SizedBox(width: 4),
                              Text('4.9 (1.2k Reviews)', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.location_on, color: kOnSurfaceVariant, size: 20),
                              SizedBox(width: 4),
                              Text('Austin, TX', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 32 : 0),

                // Actions & Stats
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            backgroundColor: Colors.white.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {},
                          child: const Text('SHARE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 8,
                            shadowColor: kPrimary.withOpacity(0.4),
                          ),
                          onPressed: () {},
                          child: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ],
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

class CertificationsCard extends StatelessWidget {
  const CertificationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Icon(Icons.military_tech, size: 200, color: Colors.white.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Expert Certifications', style: TextStyle(color: kPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  _CertBadge(icon: Icons.school, title: 'NASM - CPT', desc: 'Elite Certified Trainer'),
                  _CertBadge(icon: Icons.restaurant, title: 'PN Level 2', desc: 'Precision Nutrition'),
                  _CertBadge(icon: Icons.fitness_center, title: 'CrossFit Level 3', desc: 'Expert Instructor'),
                  _CertBadge(icon: Icons.health_and_safety, title: 'EKG Specialist', desc: 'Medical Fitness'),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _CertBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _CertBadge({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: kPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({super.key});

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
              const Text('PERFORMANCE ROI', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 32),
              _ProgressBar(label: 'Client Success Rate', value: '98%', percent: 0.98),
              const SizedBox(height: 24),
              _ProgressBar(label: 'Session Retention', value: '84%', percent: 0.84),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('4.2k', style: TextStyle(color: kPrimary, fontSize: 48, fontWeight: FontWeight.w800, height: 1)),
              SizedBox(height: 4),
              Text('HOURS COACHED', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          )
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final String value;
  final double percent;

  const _ProgressBar({required this.label, required this.value, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(value, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
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

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: const Text('Personal Information', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: const [
                _InputField(label: 'FULL NAME', initialValue: 'Alex Rivers'),
                SizedBox(height: 24),
                _InputField(label: 'PROFESSIONAL EMAIL', initialValue: 'alex.rivers@velocityai.fit'),
                SizedBox(height: 24),
                _InputField(
                  label: 'EXPERIENCE SUMMARY', 
                  initialValue: 'Focusing on high-intensity metabolic conditioning and neural priming. I specialize in taking elite athletes from plateaus to peak performance using data-driven Velocity AI insights.',
                  maxLines: 4,
                ),
              ],
            ),
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

class AppPreferencesCard extends StatelessWidget {
  final bool alertsEnabled;
  final bool visibilityEnabled;
  final bool biometricEnabled;
  final ValueChanged<bool> onAlertsChanged;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<bool> onBiometricChanged;

  const AppPreferencesCard({
    super.key,
    required this.alertsEnabled,
    required this.visibilityEnabled,
    required this.biometricEnabled,
    required this.onAlertsChanged,
    required this.onVisibilityChanged,
    required this.onBiometricChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: const Text('Account Preferences', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _SwitchRow(
                  icon: Icons.notifications_active, 
                  title: 'Real-time Coaching Alerts', 
                  desc: 'Notify when athletes miss targets', 
                  value: alertsEnabled, 
                  onChanged: onAlertsChanged,
                  iconColor: kPrimary,
                ),
                const SizedBox(height: 16),
                _SwitchRow(
                  icon: Icons.visibility, 
                  title: 'Profile Visibility', 
                  desc: 'Visible to elite training network', 
                  value: visibilityEnabled, 
                  onChanged: onVisibilityChanged,
                  iconColor: kPrimary,
                ),
                const SizedBox(height: 16),
                _SwitchRow(
                  icon: Icons.sync, 
                  title: 'Biometric Data Sync', 
                  desc: 'Last sync: 2 minutes ago', 
                  value: biometricEnabled, 
                  onChanged: onBiometricChanged,
                  iconColor: kOnSurfaceVariant,
                ),
                const SizedBox(height: 24),
                Container(height: 1, color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 24),
                _ActionRow(title: 'Security & Password', icon: Icons.chevron_right),
                const SizedBox(height: 12),
                _ActionRow(title: 'Subscription Plan (Pro)', icon: Icons.check_circle, iconColor: kPrimary),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Delete Account', style: TextStyle(color: kError, fontSize: 14, fontWeight: FontWeight.bold)),
                        Icon(Icons.delete, color: kError),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;

  const _SwitchRow({
    required this.icon, 
    required this.title, 
    required this.desc, 
    required this.value, 
    required this.onChanged,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          activeTrackColor: kPrimary,
          inactiveThumbColor: Colors.white.withOpacity(0.5),
          inactiveTrackColor: Colors.white.withOpacity(0.1),
          trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
        )
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _ActionRow({required this.title, required this.icon, this.iconColor = kOnSurfaceVariant});

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
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }
}

// --- APP BAR & NAV ---

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
                      const Text('Dashboard', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 32),
                      const Text('Training', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 32),
                      const Text('Analytics', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 32),
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
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD46a5anjeUdIIo6jEZnlFEI_YslCM5IcO3Hw-tsDUEr1qvMyGoL5Bd3W2UP9MhRzfPApAztI5vvoi8hFzpc1pTu-Oi-GnbHTJ2HSpPT2RcVRtQ_qUSu53d-ykH_J230nnxwq4M6LboPfMSL5pptmR3F9L6X0M6MOzUhfhgdo8z0-qhPobaJVfR5mRBeMTX69wB8tSkR-6gKQtRGq-a7UFWxNVXVsF8q2RimFsIQuGF2B0FG63hQmQqRw6M-ob-pckOnLDRMynuOyg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Level 42 Athlete', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                const Spacer(),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavIcon(icon: Icons.home, title: 'Home'),
              _BottomNavIcon(icon: Icons.exercise, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.settings, title: 'Stats', isActive: true),
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
          padding: padding ?? const EdgeInsets.all(24),
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