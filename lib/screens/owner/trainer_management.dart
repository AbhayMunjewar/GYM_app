import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAITrainerManagementApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSecondary = Color(0xFFADC6FF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceLow = Color(0xFF131313);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAITrainerManagementApp extends StatelessWidget {
  const VelocityAITrainerManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Trainer Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const TrainerManagementScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class TrainerManagementScreen extends StatefulWidget {
  const TrainerManagementScreen({super.key});

  @override
  State<TrainerManagementScreen> createState() => _TrainerManagementScreenState();
}

class _TrainerManagementScreenState extends State<TrainerManagementScreen> {
  void _showAddTrainerModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddTrainerModal();
      },
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
                        isDesktop ? 48.0 : 120.0
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          HeaderSection(onAddTrainer: () => _showAddTrainerModal(context)),
                          const SizedBox(height: 32),
                          const PerformanceKpiGrid(),
                          const SizedBox(height: 32),
                          const TrainerRosterSection(),
                          const SizedBox(height: 32),
                          const QuickAssignSection(),
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

class HeaderSection extends StatelessWidget {
  final VoidCallback onAddTrainer;
  const HeaderSection({super.key, required this.onAddTrainer});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trainer Management', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, letterSpacing: -1, height: 1.1)),
              const SizedBox(height: 8),
              const Text('Monitor staff performance, optimize client retention metrics, and expand your elite coaching roster.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
            ],
          ),
        ),
        if (isMobile) const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 8,
            shadowColor: kPrimary.withOpacity(0.4),
          ),
          icon: const Icon(Icons.person_add),
          label: const Text('ADD NEW TRAINER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          onPressed: onAddTrainer,
        )
      ],
    );
  }
}

class PerformanceKpiGrid extends StatelessWidget {
  const PerformanceKpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 1 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 2.5 : 1.8,
          children: const [
            _RetentionKpiCard(),
            _RatingKpiCard(),
            _CapacityKpiCard(),
          ],
        );
      },
    );
  }
}

class _RetentionKpiCard extends StatelessWidget {
  const _RetentionKpiCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            bottom: 0, right: 0, left: 0,
            height: 60,
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(painter: SparklinePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL RETENTION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const Text('94.2%', style: TextStyle(color: kPrimary, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1)),
                Row(
                  children: const [
                    Icon(Icons.trending_up, color: kSecondary, size: 16),
                    SizedBox(width: 4),
                    Text('+2.4% vs last month', style: TextStyle(color: kSecondary, fontSize: 12)),
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

class _RatingKpiCard extends StatelessWidget {
  const _RatingKpiCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            bottom: 0, right: 0, left: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [kPrimary.withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AVG. RATING', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const Text('4.92', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1)),
                Row(
                  children: List.generate(5, (index) => const Icon(Icons.star, color: kPrimary, size: 18)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityKpiCard extends StatelessWidget {
  const _CapacityKpiCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('CAPACITY LOAD', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Row(
            children: [
              const Text('78%', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.78,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kSecondaryContainer, kPrimary]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const Text('12/15 Trainers at full capacity', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPrimary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.2, size.width, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrainerRosterSection extends StatelessWidget {
  const TrainerRosterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header & Search
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Staff Roster', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                if (isMobile) const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: isMobile ? 200 : 256,
                      decoration: BoxDecoration(color: kSurfaceLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search staff...',
                          hintStyle: TextStyle(color: kOnSurfaceVariant.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.search, color: kOnSurfaceVariant, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(color: kSurfaceHigh, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: IconButton(icon: const Icon(Icons.filter_list, color: kOnSurfaceVariant), onPressed: () {}),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width > 900 ? 900 : MediaQuery.of(context).size.width),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
                dataRowMinHeight: 80,
                dataRowMaxHeight: 80,
                dividerThickness: 1,
                columns: const [
                  DataColumn(label: Text('TRAINER', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('SPECIALIZATION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('RETENTION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('RATING', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(_TrainerInfoCell(name: 'Elena Vance', joined: 'Member since Jan 2023', imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBfyc7URHfqnnQ4ISGNPd4eFeva0I75OXTGDtV1CnjN_FGHAKU6KTC-OpK_rlrB9JddBV-b-wxU83y8knIxOZ4dEISxc0wEHy5B6sdrdXyEVQFL7Z7Leanubbesf9KORepHXL86sEpydQhbohjqDdc0N7FWBKS0aHGoZbRHBo6ETG6jeixQb-cE4ovFFU7OyrunTT759jeSDAuNpKSowV_7n9iC17XsrYSZ2DDbKlYW0wA8cEzW9ulw2hje8cjv5xAwITZFxdYfOYk')),
                    DataCell(Text('Hypertrophy & Mobility', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14))),
                    DataCell(_RetentionBadge(value: '98%', isHigh: true)),
                    DataCell(_RatingCell(rating: '5.0')),
                    DataCell(_StatusCell(status: 'Online', color: kSecondary)),
                    DataCell(Icon(Icons.more_vert, color: Colors.white)),
                  ]),
                  DataRow(cells: [
                    DataCell(_TrainerInfoCell(name: 'Marcus Thorne', joined: 'Member since Mar 2022', imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBBAk6CsUxYQJKRio25Iom4GtZ5Hi_t9RJoNMIvOMQGn9tAeMml-z2jNxz_6cdubFEAgsP07cPV0m1z2DAZlty23EfsnuigVWIFz_xAVMf6N3iBO9kQfZ8RPoiIBGmFDOTmssEM68S8zBneoHXkzHZunld3wsm-0WBxF0oJVkwhu4RhBRUSBjQE1-m6zXpiM1AeQ3doUKo_MPuanc4wJD7VTP12j1rfNGEV2RjqSKZxBW4xtKfpscfK-R7ctkHnETYCAdLTavu38rY')),
                    DataCell(Text('Powerlifting & Strength', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14))),
                    DataCell(_RetentionBadge(value: '89%', isHigh: false)),
                    DataCell(_RatingCell(rating: '4.8')),
                    DataCell(_StatusCell(status: 'In Session', color: kOnSurfaceVariant)),
                    DataCell(Icon(Icons.more_vert, color: Colors.white)),
                  ]),
                  DataRow(cells: [
                    DataCell(_TrainerInfoCell(name: 'Sarah Jenkins', joined: 'Member since Nov 2023', imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCSPJMgdXxgIjtiL6JMxp2jt28gFGtLfHh7wzCwqLFczjUeqOEXNz0w65CM-JCmTLWzz68GfJBt4Pkl4YEqY_eZ61PAGt73S5lkGQKxn9gPwuKXhS37P0BAQ1ENy2bY9TAC0tvH96GNPll8D6B_5ks9LxgnCmhivAJA9H6USH79lA9O1AOh5jlby5PLJ2WfnPy5JbP0Np9BVZH1hgtytTH72Mz4WJgkYZFYnwbaV79e8QtiLsN6gWahKhKug5Sb62TYxqhakVMjgA4')),
                    DataCell(Text('HIIT & Metabolic Condition', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14))),
                    DataCell(_RetentionBadge(value: '95%', isHigh: true)),
                    DataCell(_RatingCell(rating: '4.9')),
                    DataCell(_StatusCell(status: 'Online', color: kSecondary)),
                    DataCell(Icon(Icons.more_vert, color: Colors.white)),
                  ]),
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
                const Text('Showing 1-12 of 24 staff members', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left, color: kOnSurfaceVariant), onPressed: null),
                    IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () {}),
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

class _TrainerInfoCell extends StatelessWidget {
  final String name;
  final String joined;
  final String imgUrl;

  const _TrainerInfoCell({required this.name, required this.joined, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(joined, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
          ],
        )
      ],
    );
  }
}

class _RetentionBadge extends StatelessWidget {
  final String value;
  final bool isHigh;

  const _RetentionBadge({required this.value, required this.isHigh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isHigh ? kPrimary.withOpacity(0.1) : Colors.white.withOpacity(0.1),
        border: Border.all(color: isHigh ? kPrimary.withOpacity(0.2) : Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(value, style: TextStyle(color: isHigh ? kPrimary : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _RatingCell extends StatelessWidget {
  final String rating;

  const _RatingCell({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: kPrimary, size: 16),
        const SizedBox(width: 4),
        Text(rating, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusCell({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(status, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class QuickAssignSection extends StatefulWidget {
  const QuickAssignSection({super.key});

  @override
  State<QuickAssignSection> createState() => _QuickAssignSectionState();
}

class _QuickAssignSectionState extends State<QuickAssignSection> {
  String _selectedClient = 'Search Client...';
  String _selectedTrainer = 'Assign to...';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Assign Client', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _DropdownCard(
                      label: '1. SELECT CLIENT', 
                      value: _selectedClient,
                      items: const ['Search Client...', 'Jordan Smith', 'Casey Adams', 'Riley Evans'],
                      onChanged: (val) => setState(() => _selectedClient = val!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _DropdownCard(
                      label: '2. SELECT TRAINER', 
                      value: _selectedTrainer,
                      items: const ['Assign to...', 'Elena Vance', 'Marcus Thorne', 'Sarah Jenkins'],
                      onChanged: (val) => setState(() => _selectedTrainer = val!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Container(
                      height: 64, // Match typical dropdown height roughly
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: Text('CONFIRM ASSIGNMENT', style: TextStyle(color: kBackground, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            return Column(
              children: [
                _DropdownCard(
                  label: '1. SELECT CLIENT', 
                  value: _selectedClient,
                  items: const ['Search Client...', 'Jordan Smith', 'Casey Adams', 'Riley Evans'],
                  onChanged: (val) => setState(() => _selectedClient = val!),
                ),
                const SizedBox(height: 16),
                _DropdownCard(
                  label: '2. SELECT TRAINER', 
                  value: _selectedTrainer,
                  items: const ['Assign to...', 'Elena Vance', 'Marcus Thorne', 'Sarah Jenkins'],
                  onChanged: (val) => setState(() => _selectedTrainer = val!),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text('CONFIRM ASSIGNMENT', style: TextStyle(color: kBackground, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        )
      ],
    );
  }
}

class _DropdownCard extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownCard({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kSurfaceLow,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: kSurfaceHigh,
                icon: const Icon(Icons.expand_more, color: kOnSurfaceVariant),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- MODALS ---
class AddTrainerModal extends StatelessWidget {
  const AddTrainerModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add New Staff', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: kOnSurfaceVariant),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 24),
              const _ModalInput(label: 'FULL NAME', hint: 'e.g. John Doe'),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SPECIALIZATION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kSurfaceLow,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'Strength & Conditioning',
                        isExpanded: true,
                        dropdownColor: kSurfaceHigh,
                        icon: const Icon(Icons.expand_more, color: kOnSurfaceVariant),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: const ['Strength & Conditioning', 'Yoga & Mindfulness', 'Nutrition Specialist', 'Rehab & Recovery']
                          .map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const _ModalInput(label: 'BASE COMMISSION (%)', hint: '25', isNumeric: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CREATE STAFF PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool isNumeric;

  const _ModalInput({required this.label, required this.hint, this.isNumeric = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kOnSurfaceVariant.withOpacity(0.5)),
            filled: true,
            fillColor: kSurfaceLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimary)),
            contentPadding: const EdgeInsets.all(16),
          ),
        )
      ],
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
                        color: kPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.shield, color: kPrimary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Owner/Admin', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
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
          style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
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
              _BottomNavIcon(icon: Icons.equalizer, title: 'Stats', isActive: true),
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
  final Border? border;

  const GlassCard({super.key, required this.child, this.padding, this.border});

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
            border: border ?? Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
