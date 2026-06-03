import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIMembershipApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFFADC6FF);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF131313);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAIMembershipApp extends StatelessWidget {
  const VelocityAIMembershipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Membership Center | VELOCITY AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MembershipDashboardScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class MembershipDashboardScreen extends StatefulWidget {
  const MembershipDashboardScreen({super.key});

  @override
  State<MembershipDashboardScreen> createState() => _MembershipDashboardScreenState();
}

class _MembershipDashboardScreenState extends State<MembershipDashboardScreen> {
  int _qrSeconds = 24;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _qrSeconds--;
        if (_qrSeconds < 0) {
          _qrSeconds = 30; // Reset timer
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleManagePlan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account management portal launching...', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimary,
        duration: Duration(seconds: 2),
      )
    );
  }

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
                        isDesktop ? 48.0 : 120.0 // Extra padding on mobile for bottom nav
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const PageHeader(),
                          const SizedBox(height: 32),
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
            children: [
              Expanded(flex: 8, child: MembershipStatusCard(onManageTap: _handleManagePlan)),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: QrAccessCard(seconds: _qrSeconds)),
            ],
          ),
          const SizedBox(height: 24),
          const PaymentHistoryTable(),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: FeatureActionCard(title: 'Guest Passes', desc: 'You have 4 passes remaining for this month.', icon: Icons.card_membership, color: kSecondaryContainer)),
              SizedBox(width: 24),
              Expanded(child: FeatureActionCard(title: 'Pause Membership', desc: 'Temporarily freeze your account for up to 3 months.', icon: Icons.cancel, color: kError)),
            ],
          )
        ],
      );
    }

    return Column(
      children: [
        MembershipStatusCard(onManageTap: _handleManagePlan),
        const SizedBox(height: 24),
        QrAccessCard(seconds: _qrSeconds),
        const SizedBox(height: 24),
        const PaymentHistoryTable(),
        const SizedBox(height: 24),
        const FeatureActionCard(title: 'Guest Passes', desc: 'You have 4 passes remaining for this month.', icon: Icons.card_membership, color: kSecondaryContainer),
        const SizedBox(height: 16),
        const FeatureActionCard(title: 'Pause Membership', desc: 'Temporarily freeze your account for up to 3 months.', icon: Icons.cancel, color: kError),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

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
            const Text('MEMBERSHIP DASHBOARD', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Account Management', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            border: Border.all(color: kPrimary.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('PLATINUM MEMBER', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
        )
      ],
    );
  }
}

class MembershipStatusCard extends StatelessWidget {
  final VoidCallback onManageTap;
  const MembershipStatusCard({super.key, required this.onManageTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Platinum Elite', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Unlimited access to all global locations & AI coaching.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.verified, color: kPrimary, size: 40),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _StatusColumn(label: 'Status', value: 'Active', valueColor: kPrimary)),
              Expanded(child: _StatusColumn(label: 'Expiry Date', value: 'Dec 2024', valueColor: Colors.white)),
              if (!isMobile)
                Expanded(child: _StatusColumn(label: 'Auto-Renewal', value: 'Enabled', valueColor: Colors.white)),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onManageTap,
                child: const Text('MANAGE PLAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatusColumn({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class QrAccessCard extends StatelessWidget {
  final int seconds;
  const QrAccessCard({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Gradient Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [kPrimary.withOpacity(0.1), Colors.transparent],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ENTRY PASS', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuCpvDz2IXnrPwIPyLgEnlH1S3aODWgbfATsmOtt-rStxh1p2n-_pa-sQ-wVbY6Ma-xz1s2tq3Wk38MUk353LKfrKv2cNp7X08E9q0_F3eDhFfB91Xgw_wmuFd133zPskJU4WqEGcrsCKPbqOmPQM9Alk3Uh848ItyFoctC4_9IOO63GoGSTHn8Ufi7mwpMnNjJBpMObzlm6zfXLat8PoTXppFIYtoXOLVvw7GahfVhhqljfL23a05GLouMnNowmteMu_305niYzRr8', width: 140, height: 140, fit: BoxFit.cover),
                    // Simulated Pulse Border
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: kPrimary.withOpacity(0.4), width: 4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Scan to Enter', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14, fontFamily: 'Inter'),
                  children: [
                    const TextSpan(text: 'Refreshes in '),
                    TextSpan(text: '${seconds}s', style: const TextStyle(color: kPrimary, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold)),
                  ]
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentHistoryTable extends StatelessWidget {
  const PaymentHistoryTable({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'id': '#VEL-98210', 'date': 'Nov 01, 2023', 'desc': 'Monthly Platinum Membership', 'amt': '\$149.00', 'status': 'Success'},
      {'id': '#VEL-97542', 'date': 'Oct 01, 2023', 'desc': 'Monthly Platinum Membership', 'amt': '\$149.00', 'status': 'Success'},
      {'id': '#VEL-96331', 'date': 'Sep 01, 2023', 'desc': 'Monthly Platinum Membership', 'amt': '\$149.00', 'status': 'Success'},
    ];

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment History', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Icon(Icons.file_download, color: kPrimary, size: 18),
                      SizedBox(width: 8),
                      Text('Export All (PDF)', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width > 900 ? 900 : MediaQuery.of(context).size.width),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
                dataRowMaxHeight: 80,
                dataRowMinHeight: 80,
                dividerThickness: 1,
                columns: const [
                  DataColumn(label: Text('TRANSACTION ID', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DATE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DESCRIPTION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('AMOUNT', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('RECEIPT', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                ],
                rows: transactions.map((t) {
                  return DataRow(
                    cells: [
                      DataCell(Text(t['id']!, style: const TextStyle(color: kOnSurfaceVariant))),
                      DataCell(Text(t['date']!, style: const TextStyle(color: Colors.white))),
                      DataCell(Text(t['desc']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      DataCell(Text(t['amt']!, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(t['status']!.toUpperCase(), style: const TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.download, color: kOnSurfaceVariant),
                          onPressed: () {},
                        )
                      ),
                    ]
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FeatureActionCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const FeatureActionCard({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kOnSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// --- LAYOUT COMPONENTS ---

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
                    if (MediaQuery.of(context).size.width > 900) ...[
                      const Text('Dashboard', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Training', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Members', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 32),
                      const Text('Settings', style: TextStyle(color: kOnSurfaceVariant)),
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
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCBW8MS8g27M9Q1ILjKhor9q9ExCZSehf6OJ38dq7PQAQ1WaFOSgsY2SaSHWXXm2fqatmkrWzLHUeXeoSHvzosKBCBZD98Zy9Sb6Jtk5beZ2mPq6yi1-YBVZoXeIPiEoPwEUsb88X3HPOrwCravco4FdLAMsoiqXGyTQ2EFEnMeTr-RLV2_wr0W2OPU9Uzm2TqO5OOu5T2W8X4pqsQ_DBMTpb0JhcmjSUpsJN4AQE1fqeBPLzcuMqhTKbp16GpPlA0swqq245RO_KQ'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • Level 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.group, title: 'Members', isActive: true),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
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
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.group, title: 'Members', isActive: true),
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
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}