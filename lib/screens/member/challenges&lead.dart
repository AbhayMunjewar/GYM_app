import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIChallengesApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF131313);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kGold = Color(0xFFFFD700);

class VelocityAIChallengesApp extends StatelessWidget {
  const VelocityAIChallengesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Challenges & Leaderboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const ChallengesScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

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
          final isDesktop = constraints.maxWidth > 1024;
          final isTablet = constraints.maxWidth > 768 && constraints.maxWidth <= 1024;
          
          return Row(
            children: [
              if (isDesktop || isTablet) const DesktopSideNav(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        24.0, 
                        100.0, 
                        24.0, 
                        isDesktop || isTablet ? 48.0 : 120.0
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const HubHeader(),
                          const SizedBox(height: 32),
                          _buildMainGrid(isDesktop || isTablet),
                          const SizedBox(height: 32),
                          const AchievementShelf(),
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
      floatingActionButton: const CustomFAB(),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 768 
          ? const MobileBottomNav() 
          : null,
    );
  }

  Widget _buildMainGrid(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            flex: 8,
            child: ActiveChallenges(),
          ),
          SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: LeaderboardSection(),
          ),
        ],
      );
    }
    return Column(
      children: const [
        ActiveChallenges(),
        SizedBox(height: 32),
        LeaderboardSection(),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class HubHeader extends StatelessWidget {
  const HubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMMUNITY HUB', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text(
              'Push your limits with global competitions and track your dominance on the leaderboards.', 
              style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)
            ),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
            shadowColor: kPrimary.withOpacity(0.4),
          ),
          onPressed: () {},
          child: const Text('CREATE CHALLENGE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        )
      ],
    );
  }
}

class ActiveChallenges extends StatelessWidget {
  const ActiveChallenges({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ACTIVE CHALLENGES', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: const Text('VIEW ALL', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        ),
        const SizedBox(height: 16),
        // Featured Challenge
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDcithRek7srf1XJ9CNT-Mk25g-i8x7txwtMvrC4yTGSUs_eqQToUSoKeAVZFz1bfZU92gmj6U9t1QuozmnCto2p3ADaq0QydC6QqlwwfK-vP915iD2DHDp_7biV_0wzsPe5LtBq6UEaH5lTIJ-soPJfcOeag74wKuioUvjZxpLU46Gf4rn147GuHtN3nc9Ttwg9hwEKbBKpLMHcHbEykNwIJyLsi_UbEkLWcmiyUGvxX7vp4dLoAKEqVUo_VZiOAOphaVS_BcWbsU',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.4),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [kBackground.withOpacity(0.9), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(4)),
                          child: const Text('FEATURED', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        const Text('GLOBAL EVENT', style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('30-DAY SHRED', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, height: 1)),
                    const SizedBox(height: 8),
                    const Text('12,402 Participants. Join the elite ranks in our most aggressive metabolic conditioning challenge yet.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {},
                          child: const Text('JOIN NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                        const _StackedAvatars(),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Secondary Challenges
        LayoutBuilder(
          builder: (context, constraints) {
            if (isMobile) {
              return Column(
                children: const [
                  SecondaryChallengeCard(
                    title: 'MARATHON READY',
                    desc: '100km total distance goal. Track pace and elevation gains.',
                    badge: '6 DAYS LEFT',
                    icon: Icons.directions_run,
                    progress: 0.64,
                    progressText: '64.2 km / 100 km',
                    isCompleted: false,
                  ),
                  SizedBox(height: 16),
                  SecondaryChallengeCard(
                    title: 'IRON CORE',
                    desc: 'Daily plank and core stability series. Elite finisher status.',
                    badge: 'COMPLETED',
                    icon: Icons.monitor_weight,
                    isCompleted: true,
                  ),
                ],
              );
            }
            return Row(
              children: const [
                Expanded(
                  child: SecondaryChallengeCard(
                    title: 'MARATHON READY',
                    desc: '100km total distance goal. Track pace and elevation gains.',
                    badge: '6 DAYS LEFT',
                    icon: Icons.directions_run,
                    progress: 0.64,
                    progressText: '64.2 km / 100 km',
                    isCompleted: false,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SecondaryChallengeCard(
                    title: 'IRON CORE',
                    desc: 'Daily plank and core stability series. Elite finisher status.',
                    badge: 'COMPLETED',
                    icon: Icons.monitor_weight,
                    isCompleted: true,
                  ),
                ),
              ],
            );
          }
        )
      ],
    );
  }
}

class SecondaryChallengeCard extends StatelessWidget {
  final String title;
  final String desc;
  final String badge;
  final IconData icon;
  final double? progress;
  final String? progressText;
  final bool isCompleted;

  const SecondaryChallengeCard({
    super.key,
    required this.title,
    required this.desc,
    required this.badge,
    required this.icon,
    this.progress,
    this.progressText,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted ? kPrimary.withOpacity(0.2) : kSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: isCompleted ? kPrimary : kSecondary),
              ),
              Text(badge, style: TextStyle(color: isCompleted ? kOnSurfaceVariant : kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 24),
          if (!isCompleted && progress != null) ...[
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(kSecondary),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(progressText!, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                Text('${(progress! * 100).toInt()}%', style: const TextStyle(color: kSecondary, fontSize: 12)),
              ],
            )
          ] else ...[
            Row(
              children: const [
                Icon(Icons.check_circle, color: kPrimary, size: 20),
                SizedBox(width: 8),
                Text('REWARD CLAIMED', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            )
          ]
        ],
      ),
    );
  }
}

class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('LEADERBOARD', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kPrimary, width: 2))),
                  child: const Text('GLOBAL', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                const Text('FRIENDS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(24),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Current User Rank
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.05),
                  border: Border.all(color: kPrimary.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('#42', style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBFiT1aW1cSZtcwo9hXyNG_eIC5LUgc5aIO_h2kIbenJn3LntakKp469ykXSGVOh8Yt3l9dCyRHCERYf9B6nBBlrhQ6-RZqqgEoA40aKL3EURY_FK_c0JqwoH2idnhuhwM2mVZgE16DTNYKJ-0euGfIqDPH5Gd30QBB7MFMmikKiUDXyhqp91eNJGh5LzJVtCSrXXTb3t0FnAAMp8Xtva-tWkwjJS3p986WDsdKTAw8qU5QyZRIUNr4r0TxCuxzfcTUNA0CM0WIuFA'),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Alex Rivers (You)', style: TextStyle(color: Colors.white, fontSize: 14)),
                            Text('2,840 XP', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    const Icon(Icons.keyboard_arrow_up, color: kPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Top 3
              _RankItem(rank: '1st', name: 'Marcus V.', xp: '4,920 XP', lvl: 'LVL 88', img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBQzUcNUOHOIUI2-aoa8RbZ4_Z0yJ2c4GH7wvkLHs5F0ifNl5DYMEYWAMK26W45qmI0leFp4-8aH17_BnmD10UUEwuOoUcEZUgyDxifU3s4rPy01CM5ffcbwpytDJa8hvBCT0Ch-KDvMcRZkMx20ZAJ_fRaBJS6bGUkX_Qgn6cXDTB5bjib_hjGId9g9NuoQhF0VlcotodOjrEiRBwD3DW2PkuaxNuzufdr7kcrLSgoN_3uGCUgWfbhChWkmpJ-J0iStka4qCC631k', iconColor: kGold),
              _RankItem(rank: '2nd', name: 'Sarah Chen', xp: '4,810 XP', lvl: 'LVL 85', img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDeb5wTLPdnhjR969asob0Yyq55x4o-okZ6ZR34-4MYwSk30mWobHWFzmg0w8OiLsbeOGWEPtD-RUl6fWTt9t4l0Cn0yRUTPzBhJo7hE8TeF7ZKF0nzJekkiXKAiWvM_-Lc8owk7y_s79VQUSEVsPQlplG4B1qWORv5BZpHkSCiihW1cXpiL-y9bNFOK9DRcv9gFldIQOMFco36i2W3ih6EUl2McLJF8-4RJbIDuctXNyKV76ATzIa36V3Ic6bYE4GvJxnLItwRPxU', iconColor: Colors.blueGrey),
              _RankItem(rank: '3rd', name: 'Jordan K.', xp: '4,550 XP', lvl: 'LVL 79', img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuArIO6k1_0dpdp4wIcv1JYtSwTizvZE0b8O4CFqZhk9S5UyWbGRZqbWMqVDFtZpcjibMtcTABePKEu0xd7oOuGik6FiGveGm8N9Sn27fL2F919R99CwipoFSQngnna4vAxSU59MtbwYvcppUgxPgKz3umiSsQMB76JqLxRoJzTIxABqhqEj8um_44c1KZDTrDEVXnIVkNh48rcZstNPYigxWtYOaY2p4tI20sfjOdWpzGNz8K5mV7lsYqmNshA1g2FNPk_nTEk4qgg', iconColor: Colors.deepOrange),
              
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
                child: TextButton(
                  onPressed: () {},
                  child: const Text('VIEW FULL RANKINGS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, letterSpacing: 1.5)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _RankItem extends StatelessWidget {
  final String rank;
  final String name;
  final String xp;
  final String lvl;
  final String img;
  final Color iconColor;

  const _RankItem({
    required this.rank,
    required this.name,
    required this.xp,
    required this.lvl,
    required this.img,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech, color: iconColor),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(img),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  Text(xp, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          Text(lvl, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class AchievementShelf extends StatelessWidget {
  const AchievementShelf({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 600 && !isDesktop;

    int crossAxisCount = 2;
    if (isTablet) crossAxisCount = 4;
    if (isDesktop) crossAxisCount = 6;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ACHIEVEMENT SHELF', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
              child: const Text('24 / 128 UNLOCKED', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: const [
            _BadgeCard(title: 'Sonic Boom', desc: 'Top 1% Speed', icon: Icons.bolt, iconColor: kPrimary),
            _BadgeCard(title: 'First Place', desc: 'Won a Challenge', icon: Icons.emoji_events, iconColor: kGold),
            _BadgeCard(title: 'Early Bird', desc: '5AM Workouts', icon: Icons.schedule, iconColor: kSecondary),
            _BadgeCard(title: 'Centurion', desc: '100 Day Streak', icon: Icons.lock, iconColor: Colors.white, isLocked: true),
            _BadgeCard(title: 'Hercules', desc: '500kg Deadlift', icon: Icons.lock, iconColor: Colors.white, isLocked: true),
            _ViewAllBadges(),
          ],
        )
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color iconColor;
  final bool isLocked;

  const _BadgeCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.iconColor,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.3 : 1.0,
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: isLocked ? Colors.transparent : iconColor.withOpacity(0.5)),
                boxShadow: isLocked ? null : [BoxShadow(color: iconColor.withOpacity(0.2), blurRadius: 20)],
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ViewAllBadges extends StatelessWidget {
  const _ViewAllBadges();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: kOnSurfaceVariant, size: 32),
            SizedBox(height: 12),
            Text('ALL BADGES', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  const _StackedAvatars();

  @override
  Widget build(BuildContext context) {
    final images = [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAXq80zVSBgVuva-JYBo7gYuQgX_7yZgBBsaYrh4R-gLz_tvy3ynzN_Gn_Pp52IRwOvJJxp7vQX1cKYB-NAbN9tSaJxsqL0j2ED2G0J1iwjV2p_K2WY_f7Mf1gqRosUUmOxGkbocNco2kqlHFYDYLOM9V7m7NyMVvE37qpn_KUSQoy68KlYviXsbJmET-PnKWdOFJGKx2i5BjAU7ikUVnmqbQcY4LOLzq8Yo2otlSC9FkzBmZlXSDkcSOwHAJYcEwpFixSxMJm6lLU',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCzT46755OTdfoeDBqEX-3ZXRKN2_S2tykBLMgSqpXLzSewqO438pDhIBKXzqQmRriRY4scHI4UFJSzF1kTB_0XM5cqDfWfxrPeuNbmlPDq-TfYqG4fPRt-WtasD0QZjY6yUYeaPmFEdUw3c9mZq3ancopK4hXCaoOXxaBZrq8svK_yjvyqQexcc6ohz4_RSJU8L-N7lQZXaylfpUQ7aWsX7kiB7dlp0dIFVD6tt29Z3WHDiXnRTB1NAiNJdK3EtE77G4AKBCO5SaU',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBC6S68alUfmdiEFfiIGmvS22X3ZHTkfnyQJLF8vgb0vmMP9CUxKIEQqvQrqZ7cg_j4FAtwkr7QkYhq3DDm-ktlZeuhDtNtkyqJDzksvJXz2Kt19vevC1uWo5_ZUG8vG5Pc5JyrkxXxAPG_WQOLgbaEcvjqxXU2EXRVuWNOEwjfg44UfQkHPEMGJCoL2lzhfR1ZdBuzesBXe7D1Jn2ZJ3AU5UaHczJYS9aUBBoxqTppOjWXXC_NySzQh3mHdyCv9HIQc7lo33t8-Hk',
    ];

    return SizedBox(
      width: 120,
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < images.length; i++)
            Positioned(
              left: i * 20.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kBackground, width: 2),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(images[i]),
                ),
              ),
            ),
          Positioned(
            left: images.length * 20.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                shape: BoxShape.circle,
                border: Border.all(color: kBackground, width: 2),
              ),
              alignment: Alignment.center,
              child: const Text('+12k', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          )
        ],
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
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.bolt, color: kPrimary),
                    SizedBox(width: 8),
                    Text('VELOCITY AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: kPrimary, letterSpacing: -1)),
                  ],
                ),
                Row(
                  children: [
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const Text('DASHBOARD', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      const SizedBox(width: 24),
                      const Text('TRAINING', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      const SizedBox(width: 24),
                      const Text('COMMUNITY', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      const Text('MEMBERS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      const SizedBox(width: 24),
                    ],
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const SizedBox(width: 16),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary.withOpacity(0.5)),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAuh2OfSh4mndcvJHcvZWPQLD1bzGYRM5Inb-v4X_EQiN9zw8WOQYDFlbXMzPMFjIOTxhR7ebfhIgsM4nw3RzjPmc1zkWlY8YFUoO71esoymnXNY_hF29iZL3tstVWNUvsxSUVEaGYrZCiSQlHS8uorNSovs6ShN1J-NOcbg_diTBbpC13B9hoChCsTjQ0YqTrU4mpYMQueVoWdndim5hQ-i8ntHQdRJ0EOdsiu0cOnkgbxs27j3aqVauS7bNaXlUsnwKBd9mNp7Qk'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.menu, color: kOnSurfaceVariant),
                        onPressed: () {},
                      ),
                    ]
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
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.7),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCJtlbmgEczVUxx9bsWhmU_sktCllZ9ErPvJKZo6wI6CYXNeSjCKvBoyCwQvHmpY44NpDNwx9nlak31chQPJFGhKJp9fIJ_Guhea1wGwBj-xzFcD-fkHLBNB3PmKnZYWAXvhS0cXOEzju8Koi287XJ0rBBVkfDhWa1VIjwQgLv8SFbbCCeWGqUiIM2Rkd_tO_pZbTUbvYtQOtV5x3eAUasV9SfxFb_kBl2xNrOtrYU57sSAvy8_pEH0lzoy3I_oJiX2Fo8SVc2Lj8s',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const Text('Pro Athlete', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('LEVEL 42', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.military_tech, title: 'Challenges', isActive: true),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                _NavTile(icon: Icons.group, title: 'Members'),
                const Spacer(),
                _NavTile(icon: Icons.settings, title: 'Settings'),
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
        borderRadius: BorderRadius.circular(12),
        border: isActive ? const Border(left: BorderSide(color: kPrimary, width: 4)) : null, // HTML showed left border for active state here 
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
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
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.military_tech, title: 'League', isActive: true),
              _BottomNavIcon(icon: Icons.equalizer, title: 'Stats'),
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

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: kPrimary,
      foregroundColor: Colors.black,
      elevation: 12,
      child: const Icon(Icons.add, size: 32),
    );
  }
}

// --- UTILITY WIDGET ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassCard({super.key, required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: br,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}