import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIBillingApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF131313);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAIBillingApp extends StatelessWidget {
  const VelocityAIBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Billing & Payments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const BillingDashboardScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

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
                        24.0, 100.0, 24.0, isDesktop ? 48.0 : 120.0
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const PageHeader(),
                          const SizedBox(height: 32),
                          _buildBentoGrid(isDesktop),
                          const SizedBox(height: 48),
                          const SecurityFooter(),
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
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 ? const MobileBottomNav() : null,
    );
  }

  Widget _buildBentoGrid(bool isDesktop) {
    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 8, child: RevenueChartCard()),
              SizedBox(width: 24),
              Expanded(flex: 4, child: StatsColumn()),
            ],
          )
        else
          Column(
            children: const [
              RevenueChartCard(),
              SizedBox(height: 24),
              StatsColumn(),
            ],
          ),
        const SizedBox(height: 24),
        const TransactionHistoryCard(),
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            children: const [
              Expanded(child: ManageInvoicesCard()),
              SizedBox(width: 24),
              Expanded(child: PaymentGatewaysCard()),
            ],
          )
        else
          Column(
            children: const [
              ManageInvoicesCard(),
              SizedBox(height: 24),
              PaymentGatewaysCard(),
            ],
          ),
      ],
    );
  }
}

// --- WIDGETS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BILLING & PAYMENTS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
        const SizedBox(height: 8),
        const Text('Manage your financial data and subscriptions.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.warning, color: kError),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Pending Dues: $420.00 for Coaching Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.black),
                onPressed: () {},
                child: const Text('PAY NOW'),
              )
            ],
          ),
        )
      ],
    );
  }
}

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Total Revenue (30D)', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                  Text('\$12,450.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('+14%', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 48),
          const SizedBox(height: 200, child: _LineChartPainter()),
        ],
      ),
    );
  }
}

class _LineChartPainter extends StatelessWidget {
  const _LineChartPainter();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChartPainter(),
      child: Container(),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kPrimary..strokeWidth = 3..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.4);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StatsColumn extends StatelessWidget {
  const StatsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.account_balance_wallet, color: kPrimary),
              const SizedBox(height: 16),
              const Text('Current Balance', style: TextStyle(color: kOnSurfaceVariant)),
              const Text('\$4,821.50', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: 0.65, color: kPrimary, backgroundColor: Colors.white10),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.receipt_long, color: kOnSurfaceVariant),
              const SizedBox(height: 16),
              const Text('Pending Invoices', style: TextStyle(color: kOnSurfaceVariant)),
              const Text('03', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Due in 2 days', style: TextStyle(color: kError, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionHistoryCard extends StatelessWidget {
  const TransactionHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Transactions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _TransactionItem(title: 'Advanced AI Training', date: 'May 24, 2024', amount: '-\$149.00', icon: Icons.bolt, color: kSecondaryContainer),
          const SizedBox(height: 16),
          _TransactionItem(title: 'Tournament Reward', date: 'May 21, 2024', amount: '+\$1,200.00', icon: Icons.military_tech, color: kPrimary),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title, date, amount;
  final IconData icon;
  final Color color;

  const _TransactionItem({required this.title, required this.date, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(date, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12))])),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ManageInvoicesCard extends StatelessWidget {
  const ManageInvoicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Invoices', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: kOnSurfaceVariant),
            title: const Text('Invoice #VEL-2024-05'),
            subtitle: const Text('May 01, 2024 • \$149.00'),
            trailing: const Icon(Icons.download),
          )
        ],
      ),
    );
  }
}

class PaymentGatewaysCard extends StatelessWidget {
  const PaymentGatewaysCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Gateways', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.credit_card, color: kPrimary)),
              const SizedBox(width: 12),
              const Text('Visa ...4242'),
            ],
          )
        ],
      ),
    );
  }
}

class SecurityFooter extends StatelessWidget {
  const SecurityFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.verified_user, color: kPrimary), SizedBox(width: 8), Text('Secured by Velocity Vault™')]),
        const SizedBox(height: 8),
        const Text('All transactions encrypted via 256-bit AES.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10), textAlign: TextAlign.center),
      ],
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
                Row(children: const [Icon(Icons.bolt, color: kPrimary), SizedBox(width: 8), Text('VELOCITY AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: kPrimary))]),
                IconButton(icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant), onPressed: () {}),
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
      decoration: BoxDecoration(color: kSurface.withOpacity(0.7), border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1)))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ListTile(leading: const CircleAvatar(backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBrerOLYgYbn1SNApZGFUfzDR3WdFjaa6N--jj5lLGUxdRFl5aBzGZ9s-Jxa16l21Tyu16c2O_X9aYTzdZgLKCt0dg3tPgZLfB87HQro9VzQo0WIwEav-dOnJ7cgkC0oaj7biMHLLfiv-XWcuISFsN-gTxfYnCyHm4m8p_4HNvwTVY8EqEYEZlLQo8drto7OqB0i7PtjsGxkBjyKO-QMF5TX-Bsz1zsUZxCyh7CA1PoqpGKtBactT0N9WUyx4uf9r7MZQwEqGDrEng')), title: const Text('Alex Rivers'), subtitle: const Text('Pro Athlete • Lvl 42')),
            _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
            _NavTile(icon: Icons.fitness_center, title: 'Training'),
            _NavTile(icon: Icons.monitoring, title: 'Analytics'),
            _NavTile(icon: Icons.group, title: 'Members'),
            _NavTile(icon: Icons.military_tech, title: 'Rewards'),
            const Spacer(),
            _NavTile(icon: Icons.settings, title: 'Settings', isActive: true),
          ],
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
  Widget build(BuildContext context) => ListTile(leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant), title: Text(title, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant)), onTap: () {});
}

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 80, decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), border: const Border(top: BorderSide(color: Colors.white12))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [Icon(Icons.home), Icon(Icons.fitness_center), Icon(Icons.smart_toy), Icon(Icons.equalizer)]));
}