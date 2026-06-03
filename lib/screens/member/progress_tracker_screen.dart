// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class ProgressTrackerScreen extends StatelessWidget {
//   const ProgressTrackerScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('PROGRESS TRACKER', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text('Weight Journey', style: Theme.of(context).textTheme.headlineLarge),
//             const SizedBox(height: 24),
//             GlassCard(
//               height: 200,
//               child: Center(
//                 child: Text(
//                   'Chart Placeholder\n(Weight vs Time)',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: AppColors.onSurfaceVariant),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text('1RM Records', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
//             const SizedBox(height: 16),
//             GlassCard(
//               child: Column(
//                 children: [
//                   _buildRecordRow(context, 'Bench Press', '100 kg', '+5 kg this month'),
//                   const Divider(color: Colors.white24),
//                   _buildRecordRow(context, 'Squat', '140 kg', '+10 kg this month'),
//                   const Divider(color: Colors.white24),
//                   _buildRecordRow(context, 'Deadlift', '180 kg', '+0 kg this month'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecordRow(BuildContext context, String lift, String weight, String change) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(lift, style: Theme.of(context).textTheme.bodyLarge),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(weight, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
//               Text(change, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIProgressApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIProgressApp extends StatelessWidget {
  const VelocityAIProgressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Progress Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const ProgressTrackerScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopAppBar(),
      ),
      body: Stack(
        children: [
          // Ambient Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: kSecondary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          // Main Content Layout
          Row(
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
                          const HeaderSection(),
                          const SizedBox(height: 40),
                          const KpiBentoGrid(),
                          const SizedBox(height: 40),
                          const ChartSection(),
                          const SizedBox(height: 40),
                          const ProgressPhotosSection(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop ? const MobileBottomNav() : null,
    );
  }
}

// --- WIDGETS: SECTIONS ---

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Progress Tracker', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
        SizedBox(height: 8),
        Text('Visualizing your path to peak performance.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 18)),
      ],
    );
  }
}

class KpiBentoGrid extends StatelessWidget {
  const KpiBentoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    if (isDesktop) {
      return Row(
        children: const [
          Expanded(flex: 2, child: WeightCard()),
          SizedBox(width: 24),
          Expanded(flex: 1, child: MilestoneCard()),
          SizedBox(width: 24),
          Expanded(flex: 1, child: BodyFatCard()),
        ],
      );
    }
    
    return Column(
      children: const [
        WeightCard(),
        SizedBox(height: 24),
        MilestoneCard(),
        SizedBox(height: 24),
        BodyFatCard(),
      ],
    );
  }
}

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Sparkline Graphic
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(painter: SparklinePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT WEIGHT', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(text: '82.4', style: TextStyle(color: kPrimary, fontSize: 56, fontWeight: FontWeight.w800, height: 1)),
                      TextSpan(text: ' kg', style: TextStyle(color: kPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.trending_down, color: kPrimary, size: 16),
                    SizedBox(width: 4),
                    Text('-1.2 kg this month', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
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

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = kPrimary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kPrimary.withOpacity(0.4), kPrimary.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.6, size.width * 0.2, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.6, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.4, size.width, size.height * 0.3);

    final Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      border: const Border(left: BorderSide(color: kPrimary, width: 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LATEST MILESTONE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.fitness_center, color: kPrimary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('100kg', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Bench Press PB', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: const Text(
              '"Consistent training on hypertrophy cycles led to this breakthrough."',
              style: TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }
}

class BodyFatCard extends StatelessWidget {
  const BodyFatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  color: Colors.white.withOpacity(0.05),
                ),
                const CircularProgressIndicator(
                  value: 0.15,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(kSecondary),
                  strokeCap: StrokeCap.round,
                ),
                const Center(
                  child: Text('15%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('BODY FAT', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('Goal: 12%', style: TextStyle(color: kSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class ChartSection extends StatelessWidget {
  const ChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(flex: 2, child: WeightTrendChart()),
          SizedBox(width: 24),
          Expanded(flex: 1, child: MeasurementsCard()),
        ],
      );
    }

    return Column(
      children: const [
        WeightTrendChart(),
        SizedBox(height: 24),
        MeasurementsCard(),
      ],
    );
  }
}

class WeightTrendChart extends StatelessWidget {
  const WeightTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weight Trend', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(30)),
                      child: const Text('WEEK', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text('MONTH', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 256,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ChartBar(day: 'MON', heightPercent: 0.60, value: '83.5', isActive: false),
                _ChartBar(day: 'TUE', heightPercent: 0.55, value: '83.2', isActive: false),
                _ChartBar(day: 'WED', heightPercent: 0.50, value: '82.9', isActive: false),
                _ChartBar(day: 'THU', heightPercent: 0.45, value: '82.6', isActive: true),
                _ChartBar(day: 'FRI', heightPercent: 0.42, value: '82.4', isActive: false),
                _ChartBar(day: 'SAT', heightPercent: 0.42, value: '82.4', isActive: false),
                _ChartBar(day: 'SUN', heightPercent: 0.41, value: '82.3', isActive: false),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String day;
  final double heightPercent;
  final String value;
  final bool isActive;

  const _ChartBar({required this.day, required this.heightPercent, required this.value, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Tooltip (only showing if active for layout simplicity, CSS used hover)
            Opacity(
              opacity: isActive ? 1.0 : 0.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF353534), borderRadius: BorderRadius.circular(4)),
                child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                height: 200 * heightPercent,
                decoration: BoxDecoration(
                  color: isActive ? kPrimary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  border: isActive ? const Border(top: BorderSide(color: kPrimary, width: 2)) : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(day, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class MeasurementsCard extends StatelessWidget {
  const MeasurementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Measurements', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _MeasurementRow(label: 'Chest', value: '112', unit: 'cm', change: '+1.5cm', changeColor: kPrimary),
          const SizedBox(height: 24),
          _MeasurementRow(label: 'Waist', value: '84', unit: 'cm', change: '-0.8cm', changeColor: kPrimary),
          const SizedBox(height: 24),
          _MeasurementRow(label: 'Arms', value: '42', unit: 'cm', change: '0.0cm', changeColor: kOnSurfaceVariant),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('UPDATE DATA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String change;
  final Color changeColor;

  const _MeasurementRow({required this.label, required this.value, required this.unit, required this.change, required this.changeColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' $unit', style: const TextStyle(color: Colors.white, fontSize: 14)),
                ]
              )
            )
          ],
        ),
        Text(change, style: TextStyle(color: changeColor, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ProgressPhotosSection extends StatelessWidget {
  const ProgressPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Visual Journey', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Monthly transformation snapshots.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: const Text('ADD NEW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              onPressed: () {},
            )
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 700;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3/4,
              children: const [
                PhotoCard(
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCO6CgvrMlYaPjDjnqjwfe1Lq5T2irDXvNCR3zJeXOOYEDmhvXZyt79RIknCfJRIQA5YtYAXkC6reJyBs_P-KBxMQZUMZEAns8-oA8dlzufWmrwBGItqPGGh4SsmGQ_3J94aivQJbGYS6Wr1rFSbeBnO3o3fYtmRcrv-FyGw2mcbIUlkoF9IOLk1y86eh4iRTp9VuR7FM4ELT4drMoIH5DAUt4bApMP5rO7r5BwO_M0EVvGA5rp-fmJA7Qx8EScmfM4wvJM1DqE5sk',
                  month: 'JAN 2024',
                  weight: '84.0 kg',
                  isGrayscale: true,
                ),
                PhotoCard(
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDFTD6pMkqQ5yurLa44MtCeIZ4VpPye1f8aDVhS6GzMyBbTXNcyqyI5kzR1HdgW4bKuxoXo7Uwah2xxoTAmBCxaZlubTtesB4t1SB1T0CKAvtWTkFkUdNWb2HHPgo2n1GaAFWF6hjFAynyFt-znNinS9q-z-RXsJHRx4Byq0EC2ELS0hqr4_stiQpM4NKeDT98AWOWycU0vzaqroavcyqJ-vOEEhWCloEV0en75iXQjYXrzrzoYI-U661YG8P1ZA8zwiOSa7Kn3UKg',
                  month: 'FEB 2024',
                  weight: '83.2 kg',
                  isGrayscale: true,
                ),
                PhotoCard(
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBRqXYupsjc6XQfyT3uHbncBgBVksknSA8OilCM3mTI_zkpuD58DUWmBqGkMjqBlNFsJyH-hLDVbDvuhlWZ5X29tvBm9S_jUplQzl-huzvTqg15CuVZshu_y8nNDKJJf9Ha48BnLTgAIt7Qr5ZLIHgSshDvFs7OBzQ3fxrEFDHABdVNmmOqCZYcqEaeWcKwD_2twr0CmGqXSPG-T4gcJ9Jl3qpWw_iQqVkTj_AWV-NTajCs3VsFmeQsLlT_dg2Ri2oe_fdAmOg_eMU',
                  month: 'MAR 2024',
                  weight: '82.4 kg',
                  isLatest: true,
                ),
                AddPhotoPlaceholder(),
              ],
            );
          }
        )
      ],
    );
  }
}

class PhotoCard extends StatelessWidget {
  final String imageUrl;
  final String month;
  final String weight;
  final bool isLatest;
  final bool isGrayscale;

  const PhotoCard({
    super.key, 
    required this.imageUrl, 
    required this.month, 
    required this.weight,
    this.isLatest = false,
    this.isGrayscale = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: isGrayscale 
                ? const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ])
                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
          if (isLatest)
            Container(
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                border: Border.all(color: kPrimary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: const Text('LATEST SNAPSHOT', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
                stops: [0.0, 0.5],
              )
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(weight, style: const TextStyle(color: kPrimary, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AddPhotoPlaceholder extends StatelessWidget {
  const AddPhotoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add, color: kOnSurfaceVariant, size: 40),
          SizedBox(height: 16),
          Text('UPLOAD APR', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
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
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary.withOpacity(0.3)),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBeM90x0S-0DhI7nG-p_lzDQddi5wS1GXwWAMbORdS6nyWdzmkOcSpUUfE2GgTT-hcoq0gN2uchOjKyCi1KLzPC64KSDX44BuVNPT4SaeX4_OdDcN0LFOou9kpXL9Wk4C2hEzo7Km7cJmBDBUugiCeb1qbPJ9596lNe7Id2toukLMPmHJ9jy3-6j2Om4JRGhv4hIC_l0SgIVqZVKyebjkf3hgYFerKNuIHxnEtvsYpma0P4hj4dC-hYa3BOiuMgQBz9sAES1EGr2Ts'),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                _NavTile(icon: Icons.monitoring, title: 'Analytics', isActive: true),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.group, title: 'Members'),
                _NavTile(icon: Icons.military_tech, title: 'Rewards'),
                _NavTile(icon: Icons.settings, title: 'Settings'),
                const Spacer(),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DAILY QUOTA', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation(kPrimary),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 4,
                      ),
                      const SizedBox(height: 8),
                      const Text('75% Complete', style: TextStyle(color: kPrimary, fontSize: 12)),
                    ],
                  ),
                )
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
        Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant, size: 24),
        const SizedBox(height: 4),
        Text(
          title, 
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant, 
            fontSize: 12, 
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )
        ),
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
  final Border? border;

  const GlassCard({super.key, required this.child, this.padding, this.border});

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
            border: border ?? Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}