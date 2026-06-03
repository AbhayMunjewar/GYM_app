// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class RewardsCenterScreen extends StatelessWidget {
//   const RewardsCenterScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('REWARDS CENTER', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             GlassCard(
//               child: Column(
//                 children: [
//                   Text('KINETIC POINTS', style: Theme.of(context).textTheme.labelLarge),
//                   const SizedBox(height: 8),
//                   Text('2,450', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text('Active Challenges', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
//             const SizedBox(height: 16),
//             GlassCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('30-Day Streak', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   LinearProgressIndicator(
//                     value: 20 / 30,
//                     backgroundColor: Colors.white10,
//                     color: AppColors.primary,
//                     minHeight: 8,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   const SizedBox(height: 8),
//                   Text('20/30 Days Complete', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
//                 ],
//               ),
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
  runApp(const VelocityAIRewardsApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF131313);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceLow = Color(0xFF1C1B1B);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIRewardsApp extends StatelessWidget {
  const VelocityAIRewardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VELOCITY AI | Rewards Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const RewardsCenterScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class RewardsCenterScreen extends StatelessWidget {
  const RewardsCenterScreen({super.key});

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
                          const HeroPointBalance(),
                          const SizedBox(height: 48),
                          MarketplaceSection(isDesktop: isDesktop),
                          const SizedBox(height: 48),
                          const RedemptionHistorySection(),
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
      bottomNavigationBar: MediaQuery.of(context).size.width <= 1024 
          ? const MobileBottomNav() 
          : null,
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class HeroPointBalance extends StatelessWidget {
  const HeroPointBalance({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      decoration: BoxDecoration(
        color: kSurfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20)),
        ]
      ),
      child: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 256, height: 256,
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.2), shape: BoxShape.circle),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)),
            ),
          ),
          Positioned(
            bottom: -100, left: -100,
            child: Container(
              width: 256, height: 256,
              decoration: BoxDecoration(color: kSecondary.withOpacity(0.1), shape: BoxShape.circle),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(isMobile ? 32.0 : 48.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    const Text('AVAILABLE BALANCE', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '12,450 ', style: TextStyle(color: Colors.white, fontSize: isMobile ? 48 : 64, fontWeight: FontWeight.w800, height: 1)),
                          TextSpan(text: 'VP', style: TextStyle(color: kPrimary, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
                        ]
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Velocity Points earned through peak performance', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
                  ],
                ),
                if (isMobile) const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(height: 4, width: 48, decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Container(height: 4, width: 48, decoration: BoxDecoration(color: kPrimary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Container(height: 4, width: 48, decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Next Tier: 15,000 VP (Elite Gold)', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 8,
                        shadowColor: kPrimary.withOpacity(0.4),
                      ),
                      onPressed: () {},
                      child: const Text('REDEEM NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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

class MarketplaceSection extends StatelessWidget {
  final bool isDesktop;
  const MarketplaceSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Marketplace', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  SizedBox(height: 4),
                  Text('Redeem your hard-earned VP for exclusive gear and services', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
                ],
              ),
            ),
            Row(
              children: [
                _IconBtn(icon: Icons.filter_list),
                const SizedBox(width: 8),
                _IconBtn(icon: Icons.search),
              ],
            )
          ],
        ),
        const SizedBox(height: 32),
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(flex: 8, child: FeatureRewardCard()),
              SizedBox(width: 24),
              Expanded(flex: 4, child: Tier2RewardCard()),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: CouponCard(title: '20% Store Credit', desc: 'Valid on all nutrition items', points: '1,200', icon: Icons.local_mall, iconColor: kPrimary)),
              SizedBox(width: 24),
              Expanded(child: CouponCard(title: 'Recovery Smoothie', desc: 'Free at any Velocity Hub', points: '450', icon: Icons.coffee, iconColor: kSecondary)),
              SizedBox(width: 24),
              Expanded(child: CouponCard(title: 'Guest Pass', desc: 'Bring a friend for the day', points: '800', icon: Icons.stadium, iconColor: Colors.white)),
            ],
          )
        ] else ...[
          const FeatureRewardCard(),
          const SizedBox(height: 24),
          const Tier2RewardCard(),
          const SizedBox(height: 24),
          const CouponCard(title: '20% Store Credit', desc: 'Valid on all nutrition items', points: '1,200', icon: Icons.local_mall, iconColor: kPrimary),
          const SizedBox(height: 16),
          const CouponCard(title: 'Recovery Smoothie', desc: 'Free at any Velocity Hub', points: '450', icon: Icons.coffee, iconColor: kSecondary),
          const SizedBox(height: 16),
          const CouponCard(title: 'Guest Pass', desc: 'Bring a friend for the day', points: '800', icon: Icons.stadium, iconColor: Colors.white),
        ]
      ],
    );
  }
}

class FeatureRewardCard extends StatelessWidget {
  const FeatureRewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuANd1sOBDCww76Mg-G0ttjmbvtCwta9d-CCn0cqTPhHeEHoULGC4mh22QTw78OEhtH_2furS5OHR8YDPNXNF03xtwpl2xQRgxdXMC4fAe8hDMx4dLfFaHGJjE4pCzM-CAjTpa7yjMOFcRA32v_Ua6VeBQk2URiYAJJU7rP7L7y5Jw-3p0eBqgvpx3ezaKqJyfxX8OiTDDtCj9RV27-2JhxajQSCCbPrDrvB-lToQs6gJXxsQf59dGKifNf8_5sO2xwEOKVdFLL2XBI',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [kBackground, kBackground.withOpacity(0.2), Colors.transparent],
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                color: kSecondary.withOpacity(0.3),
                                child: const Text('LIMITED EDITION', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('1-on-1 Pro Session', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                          const SizedBox(height: 8),
                          const Text(
                            '60-minute technical evaluation with an Olympic-level coach. Focused on biomechanics and speed optimization.',
                            style: TextStyle(color: kOnSurfaceVariant, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('5,000 VP', style: TextStyle(color: kPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () {},
                          child: const Text('REDEEM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Tier2RewardCard extends StatelessWidget {
  const Tier2RewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA7oE4wQu6umhSnUh4-DK7pO4zvp7IJCl48Z8Y3dOg5y2C3oVdzqnVt4CGK6lyfMk-gAsEi4jB2EGQIT1I5CSBpYHFR2XtuTieZ7qOonV0TCgebgxwcbd7SbvbIFKzGax4jCx1miIHji7HnsQkk2x0mQz3qFgc5Me9llwrC6kd_SmYBzJtRsJrPxpfGWU4lzuWamYsGtpOZiRbpjiA80H0qqwBNslnDgeTTQSckXCwqAF0U3vdjxPg94Dm9Z_t2ENMYshb7_ouL_WI',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: kBackground.withOpacity(0.8),
                          child: const Text('NEW GEAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Velocity Speed-X Shoes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Elite Performance Gear', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
              Text('8,200 VP', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {},
              child: const Text('REDEEM NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  final String title;
  final String desc;
  final String points;
  final IconData icon;
  final Color iconColor;

  const CouponCard({
    super.key,
    required this.title,
    required this.desc,
    required this.points,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 96, height: 96,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(color: Colors.transparent)),
            ),
          ),
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Text(points, style: const TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class RedemptionHistorySection extends StatelessWidget {
  const RedemptionHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'item': 'Velocity Tech Tee - Black/Lime', 'cat': 'Apparel', 'date': 'Oct 24, 2023', 'cost': '2,400 VP', 'status': 'Shipped'},
      {'item': 'Hydro-Pro Supplement Kit', 'cat': 'Nutrition', 'date': 'Oct 12, 2023', 'cost': '1,800 VP', 'status': 'Completed'},
      {'item': 'Guest Day Pass', 'cat': 'Access', 'date': 'Sep 28, 2023', 'cost': '800 VP', 'status': 'Expired', 'isExpired': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.history, color: kOnSurfaceVariant),
            SizedBox(width: 16),
            Text('Redemption History', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width > 900 ? 900 : MediaQuery.of(context).size.width),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
                dividerThickness: 1,
                dataRowMinHeight: 70,
                dataRowMaxHeight: 70,
                columns: const [
                  DataColumn(label: Text('Reward Item', style: TextStyle(color: kOnSurfaceVariant))),
                  DataColumn(label: Text('Category', style: TextStyle(color: kOnSurfaceVariant))),
                  DataColumn(label: Text('Date', style: TextStyle(color: kOnSurfaceVariant))),
                  DataColumn(label: Text('Cost', style: TextStyle(color: kOnSurfaceVariant))),
                  DataColumn(label: Text('Status', style: TextStyle(color: kOnSurfaceVariant))),
                ],
                rows: transactions.map((t) {
                  final isExpired = t['isExpired'] == true;
                  return DataRow(
                    cells: [
                      DataCell(Text(t['item'] as String, style: const TextStyle(color: Colors.white))),
                      DataCell(Text(t['cat'] as String, style: const TextStyle(color: kOnSurfaceVariant))),
                      DataCell(Text(t['date'] as String, style: const TextStyle(color: kOnSurfaceVariant))),
                      DataCell(Text(t['cost'] as String, style: const TextStyle(color: kOnSurfaceVariant, fontFamily: 'JetBrains Mono'))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isExpired ? Colors.white.withOpacity(0.1) : const Color(0xFF596c00).withOpacity(0.2), 
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            (t['status'] as String).toUpperCase(), 
                            style: TextStyle(
                              color: isExpired ? Colors.white.withOpacity(0.4) : const Color(0xFFb0d500), 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            )
                          ),
                        )
                      ),
                    ]
                  );
                }).toList(),
              ),
            ),
          ),
        )
      ],
    );
  }
}

// --- APP BAR & NAV COMPONENTS ---

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      child: Icon(icon, color: Colors.white),
    );
  }
}

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
                      const Text('COMMUNITY', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      const Text('MEMBERS', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
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
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBgsXylZCc3n2-lwWIjJ7ixHyb2oRM7spKJa5fZc6MJkyhtdBXILdMfJMVlhluzH273pKykCV-2eXI1NAsRXOO7-QXcnfoEPomnfhv_4tjrJzwwNG2YumV8YZjvKb-ksZDy9wviHp5faNwrORqLTAsDt7lWBR_SxtqhCFGX3wV3_psresJs5N_U8l1csqTNf-zTTAnoOKs7NxIA-WlKH77lPjzgjudT449M1uhxpOcsHfyEPdSSCIioOmY8oYP1-AFs7sI6b_Q4gkE'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pro Athlete', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(4)),
                      child: const Text('Lvl 42', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.military_tech, title: 'Rewards', isActive: true),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                _NavTile(icon: Icons.group, title: 'Members'),
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
              _BottomNavIcon(icon: Icons.exercise, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.military_tech, title: 'Rewards', isActive: true),
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

// --- UTILITY ---
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
