import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIMembersApp());
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

class VelocityAIMembersApp extends StatelessWidget {
  const VelocityAIMembersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Members Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MembersManagementScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class MembersManagementScreen extends StatelessWidget {
  const MembersManagementScreen({super.key});

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
                          const PageHeader(),
                          const SizedBox(height: 32),
                          const KpiStatsGrid(),
                          const SizedBox(height: 32),
                          const MembersTableSection(),
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
}

// --- WIDGETS: CONTENT COMPONENTS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MEMBERSHIP HUB', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, letterSpacing: -1, height: 1.1)),
            const SizedBox(height: 8),
            const Text('Manage elite performance athletes and membership cycles.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
          ],
        ),
        if (isMobile) const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 12,
            shadowColor: kPrimary.withOpacity(0.4),
          ),
          icon: const Icon(Icons.person_add),
          label: const Text('REGISTER MEMBER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          onPressed: () {},
        )
      ],
    );
  }
}

class KpiStatsGrid extends StatelessWidget {
  const KpiStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 600) crossAxisCount = 2;
        if (constraints.maxWidth >= 1024) crossAxisCount = 4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth < 600 ? 2.5 : 1.5,
          children: const [
            _KpiCardTotalMembers(),
            _KpiCardActiveNow(),
            _KpiCardNewSignups(),
            _KpiCardChurnRisk(),
          ],
        );
      },
    );
  }
}

class _KpiCardTotalMembers extends StatelessWidget {
  const _KpiCardTotalMembers();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            bottom: -30, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [kSecondaryContainer.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Total Members', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 4),
              const Text('1,284', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.trending_up, color: kPrimary, size: 16),
                  SizedBox(width: 4),
                  Text('+12% this month', style: TextStyle(color: kPrimary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              const GradientProgressBar(percent: 0.85),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCardActiveNow extends StatelessWidget {
  const _KpiCardActiveNow();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Active Now', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('86', style: TextStyle(color: kPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('6.7% capacity utilized', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}

class _KpiCardNewSignups extends StatelessWidget {
  const _KpiCardNewSignups();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('New Signups', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('42', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Last 7 days', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}

class _KpiCardChurnRisk extends StatelessWidget {
  const _KpiCardChurnRisk();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      border: const Border(left: BorderSide(color: kError, width: 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Churn Risk', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('18', style: TextStyle(color: kError, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Expiring in 48h', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}

class MembersTableSection extends StatelessWidget {
  const MembersTableSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search members by name, ID, or email...',
                        hintStyle: TextStyle(color: kOnSurfaceVariant.withOpacity(0.4)),
                        prefixIcon: const Icon(Icons.search, color: kOnSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterDropdown(items: const ['All Plans', 'Velocity Pro', 'Elite Performance', 'Basic Training']),
                      const SizedBox(width: 8),
                      _FilterDropdown(items: const ['Status', 'Active', 'Frozen', 'Expired']),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width > 1000 ? 1000 : MediaQuery.of(context).size.width),
              child: Column(
                children: [
                  // Header
                  Container(
                    color: Colors.white.withOpacity(0.02),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: const [
                        Expanded(flex: 3, child: Text('MEMBER', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        Expanded(flex: 2, child: Text('PLAN', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        Expanded(flex: 2, child: Text('JOIN DATE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        Expanded(flex: 2, child: Text('ACTIVITY', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                        Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)))),
                      ],
                    ),
                  ),
                  // Rows
                  _MemberRow(
                    name: 'Jordan Smith', id: 'VEL-9042',
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBA8RcmuIFYDjkDXkRSx03SV9_9LGA1HL4Pe6-fQ2-yMBva2Zwe0xHFPQNPw03RXlaJbw_EOmIDuHUqB_KgKshq2Fy7VhSvAZozs3v0g4PZ8Q2e-ZOFEGjL6A63xY5zIxi10jLrf8ePqWdA4__jDtR-YYSvkLzkhiHlSVh5Be_7yR4QOHR8uOxc2uRJNTYaMZvqYytDb8VaeeG26AH-_Kh2IrJ2HSX2XKIkrKPJXNssfHuNudn8aok29tRF4WgTrdHeSKTKbAXV068',
                    plan: 'Elite Performance', planColor: kSecondaryContainer,
                    date: 'Oct 12, 2023',
                    progress: 0.85,
                    status: 'Active', statusColor: kPrimary, isPulsing: true,
                    actions: [Icons.edit, Icons.ac_unit]
                  ),
                  Container(height: 1, color: Colors.white.withOpacity(0.05)),
                  _MemberRow(
                    name: 'Sarah Chen', id: 'VEL-7731',
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCT9euhdwr1L44KxCyS2WB3JEz1sJxB7PhlPOg_cgfp7rV1tZ6aZgRYsilOE526_-rSZaipL1HYZwcKg_SC-rpkvgg_mLJeX-uD9cjyYyDjYMvH74Y1i1Cy5L3-k4NWYdAmXbKxPd2ZcdvcFD1KRRjxze_-G3HFTfPMntciGI6aABzTsQCE3zqyVIj788sEm3hx4Jz2lNAbTC7yEz78yMpR4Hwio0pS0M4TMRz3wPRD14Enk7BTZX9ZEGY8jXoRfnTMUn3O3jH98cc',
                    plan: 'Velocity Pro', planColor: kPrimary,
                    date: 'Jan 05, 2024',
                    progress: 0.40,
                    status: 'Frozen', statusColor: kOnSurfaceVariant, isPulsing: false,
                    actions: [Icons.edit, Icons.play_circle_outline]
                  ),
                  Container(height: 1, color: Colors.white.withOpacity(0.05)),
                  _MemberRow(
                    name: 'Marcus Vane', id: 'VEL-1120',
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAEqOfii4PQsTtzbrBYE9CgzYjebnARb-Z1lXiVEG1sCqJgIFXLbXGQIYxMvPyJasFoH-74M9Y2710YiyRA7l3hX5ur35vzyKJ6qYb-xUGjf_Q7ccF-lLbzdwpI7BnipTsmCqE6UDFBbtm_xoVdjc2x5gRd7uTIE5U1vfF9X6KtmrS_XTEmA8Pm3Rp4-SxgD7rDB44BTCFfFwHQ7gghAr35wFPfuRCHFPukqHk1Nv3bxnXXmXuSFUBociRqKE_IkpuQZi8MynvutX8',
                    plan: 'Basic Training', planColor: kOnSurfaceVariant,
                    date: 'Nov 22, 2023',
                    progress: 0.92,
                    status: 'Active', statusColor: kPrimary, isPulsing: true,
                    actions: [Icons.edit, Icons.ac_unit]
                  ),
                  Container(height: 1, color: Colors.white.withOpacity(0.05)),
                  _MemberRow(
                    name: 'Elena Rodriguez', id: 'VEL-5561',
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBUGM7DWs-vtD77lFx73fbct3rL4PeBcaPSTkJVIbKS98nbW8Ter4FEwwRtDShlgqnFs4cYpKrWVzpnv_SQx9joQ_EQbUVhcHroyjid1Mtn8VL79v8k2KDQk1sfr0QIHvOwDZ8uxncijyL4t9L9ZA4sc-LNu_o1NoaB4IwhlKyW5wpEg_ijj0eqkicpdleDWrzEz7S5IHay1JF0NvAsAI6FYKBfa-NuebPGLEIXL3RqzDG5YEhueNMsltJUTtxbJK9smF5k1pz11SI',
                    plan: 'Elite Performance', planColor: kSecondaryContainer,
                    date: 'Feb 14, 2024',
                    progress: 0.15,
                    status: 'Expiring', statusColor: kError, isPulsing: false,
                    actions: [Icons.edit, Icons.payment]
                  ),
                ],
              ),
            ),
          ),
          
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          
          // Pagination
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Showing 1 to 10 of 1,284 members', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                Row(
                  children: [
                    _PageBtn(icon: Icons.chevron_left),
                    const SizedBox(width: 8),
                    _PageBtn(text: '1', isActive: true),
                    const SizedBox(width: 4),
                    _PageBtn(text: '2'),
                    const SizedBox(width: 4),
                    _PageBtn(text: '3'),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('...', style: TextStyle(color: kOnSurfaceVariant))),
                    _PageBtn(text: '129'),
                    const SizedBox(width: 8),
                    _PageBtn(icon: Icons.chevron_right),
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

class _FilterDropdown extends StatelessWidget {
  final List<String> items;
  const _FilterDropdown({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kSurfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.first,
          icon: const Icon(Icons.arrow_drop_down, color: kOnSurfaceVariant),
          dropdownColor: kSurfaceHigh,
          style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final String name;
  final String id;
  final String imgUrl;
  final String plan;
  final Color planColor;
  final String date;
  final double progress;
  final String status;
  final Color statusColor;
  final bool isPulsing;
  final List<IconData> actions;

  const _MemberRow({
    required this.name, required this.id, required this.imgUrl, required this.plan, 
    required this.planColor, required this.date, required this.progress, 
    required this.status, required this.statusColor, required this.isPulsing, required this.actions
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      hoverColor: Colors.white.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(imgUrl)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('ID: $id', style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: planColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(plan, style: TextStyle(color: planColor, fontSize: 12)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(date, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: GradientProgressBar(percent: progress)),
                  const SizedBox(width: 8),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  if (isPulsing) const PulseDot() else Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions.map((icon) => Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: IconButton(
                    icon: Icon(icon, color: kOnSurfaceVariant, size: 20),
                    onPressed: () {},
                    hoverColor: Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool isActive;

  const _PageBtn({this.text, this.icon, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: isActive ? kPrimary.withOpacity(0.2) : Colors.transparent,
        border: Border.all(color: isActive ? kPrimary.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: text != null 
        ? Text(text!, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontWeight: FontWeight.bold))
        : Icon(icon, color: kOnSurfaceVariant, size: 20),
    );
  }
}

// --- UTILITY WIDGETS ---

class GradientProgressBar extends StatelessWidget {
  final double percent;
  const GradientProgressBar({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(3)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kSecondaryContainer, kPrimary]),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
    );
  }
}

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
                    Text(
                      'VELOCITY AI',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: kPrimary, letterSpacing: -1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const Text('Dashboard', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 32),
                      const Text('Members', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 32),
                      const Text('Analytics', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 32),
                    ],
                    IconButton(icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant), onPressed: () {}),
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
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDlF00XVno4txjezELkuN1-o37TKp7W8PA3MF4U42nfm8fXXCjNsMCPokb1avkOYBMqMWhgp8SowYjOtGSyAREXicvqHSipLErvYloiJiBJIQFRC6jpVX_C9Jvu--imvrNfVctHdZgiT-SSqjpRhA75KkXQ3BFOo5czuWTFsuh6ZaU_g6Uv7kCO9IHV53MoixCArhxv2vwDhvZIZnrwMwKeT448eJpyMJRqfjKR7No75K0TmxdwcQA1beMlwruGDYlNg1TbrkFzYbk'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • Level 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, letterSpacing: 1)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.group, title: 'Members', isActive: true),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                _NavTile(icon: Icons.military_tech, title: 'Rewards'),
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