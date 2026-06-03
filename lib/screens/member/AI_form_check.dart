import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIFormCheckApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAIFormCheckApp extends StatelessWidget {
  const VelocityAIFormCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Form Check',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const FormCheckScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class FormCheckScreen extends StatelessWidget {
  const FormCheckScreen({super.key});

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
          
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  24.0, 
                  100.0, 
                  24.0, 
                  isDesktop ? 40.0 : 120.0
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(flex: 8, child: LeftViewportPanel()),
                          SizedBox(width: 32),
                          Expanded(flex: 4, child: RightStatsPanel()),
                        ],
                      )
                    else
                      Column(
                        children: const [
                          LeftViewportPanel(),
                          SizedBox(height: 32),
                          RightStatsPanel(),
                        ],
                      )
                  ]),
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

// --- LEFT PANEL: VIEWPORT & METRICS ---
class LeftViewportPanel extends StatelessWidget {
  const LeftViewportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        VideoAnalysisViewport(),
        SizedBox(height: 24),
        MetricsGrid(),
      ],
    );
  }
}

// --- VIDEO VIEWPORT WIDGET ---
class VideoAnalysisViewport extends StatefulWidget {
  const VideoAnalysisViewport({super.key});

  @override
  State<VideoAnalysisViewport> createState() => _VideoAnalysisViewportState();
}

class _VideoAnalysisViewportState extends State<VideoAnalysisViewport> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Video/Image
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCVHGjPeAKtHeUbW7nAf-symjrsHUViphgL4L5UKqUemIYUmEhcK1SX51-aBi1WZ_vIGIOfFCcBWvB9PJ6onsyTgESGnmcccP0U9VOfPyJoOiSBJ2A-P7W2bXBRyx7KdUpLy4aSLIpspyAy9LwR9TOUnF6oTwT06X4gG2sXz_SKh3qVnyW9RS-jOVBcckU6b67pTaJbgkmvee4hIrgyTHnU78Ge_yV5K_3SOiMYnqZDqjDSj9nmDvmEBCEDzOdZe5e_GM3pnbPM_z0',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
            
            // Skeleton Overlay
            CustomPaint(
              painter: SkeletonPainter(),
            ),

            // Scanning Line Animation
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Positioned(
                  top: _scanController.value * MediaQuery.of(context).size.width * (9/16), // Approx height
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, kPrimary.withOpacity(0.8), Colors.transparent],
                      ),
                      boxShadow: [
                        BoxShadow(color: kPrimary.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                      ]
                    ),
                  ),
                );
              },
            ),

            // Top HUD
            Positioned(
              top: 24,
              left: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _PulseDot(),
                        const SizedBox(width: 8),
                        const Text('LIVE ANALYSIS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom HUD
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _GlassIconButton(icon: Icons.videocam),
                      const SizedBox(width: 16),
                      _GlassIconButton(icon: Icons.upload),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)],
                    ),
                    child: Row(
                      children: const [
                        Text('DEPTH', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                        SizedBox(width: 12),
                        Text('94%', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
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
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kError, shape: BoxShape.circle)),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  const _GlassIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

// --- SKELETON PAINTER ---
class SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base dimensions from the HTML SVG viewbox (1000x562)
    final double scaleX = size.width / 1000;
    final double scaleY = size.height / 562;

    final Paint normalLinePaint = Paint()
      ..color = kPrimary
      ..strokeWidth = 4 * scaleX
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    final Paint errorLinePaint = Paint()
      ..color = kError
      ..strokeWidth = 4 * scaleX
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6);

    final Paint jointFillPaint = Paint()..color = Colors.white;
    final Paint jointStrokePaint = Paint()..color = kPrimary..style = PaintingStyle.stroke..strokeWidth = 2;
    final Paint errorJointFillPaint = Paint()..color = kError;
    final Paint errorJointStrokePaint = Paint()..color = kError..style = PaintingStyle.stroke..strokeWidth = 2;

    void drawScaledLine(double x1, double y1, double x2, double y2, Paint paint) {
      canvas.drawLine(Offset(x1 * scaleX, y1 * scaleY), Offset(x2 * scaleX, y2 * scaleY), paint);
    }

    void drawScaledJoint(double x, double y, bool isError) {
      canvas.drawCircle(Offset(x * scaleX, y * scaleY), 6 * scaleX, isError ? errorJointFillPaint : jointFillPaint);
      canvas.drawCircle(Offset(x * scaleX, y * scaleY), 6 * scaleX, isError ? errorJointStrokePaint : jointStrokePaint);
    }

    // Lines
    drawScaledLine(500, 150, 500, 300, normalLinePaint); // Spine
    drawScaledLine(420, 170, 580, 170, normalLinePaint); // Shoulders
    drawScaledLine(420, 170, 380, 250, normalLinePaint); // Left Arm
    drawScaledLine(580, 170, 620, 250, normalLinePaint); // Right Arm
    drawScaledLine(450, 300, 550, 300, normalLinePaint); // Hips
    drawScaledLine(450, 300, 400, 400, normalLinePaint); // Left Thigh
    drawScaledLine(400, 400, 460, 520, errorLinePaint);  // Left Calf (Error)
    drawScaledLine(550, 300, 600, 400, normalLinePaint); // Right Thigh
    drawScaledLine(600, 400, 540, 520, normalLinePaint); // Right Calf

    // Joints
    drawScaledJoint(500, 150, false);
    drawScaledJoint(420, 170, false);
    drawScaledJoint(580, 170, false);
    drawScaledJoint(450, 300, false);
    drawScaledJoint(550, 300, false);
    drawScaledJoint(400, 400, false);
    drawScaledJoint(600, 400, false);
    drawScaledJoint(460, 520, true); // Error Joint
    drawScaledJoint(540, 520, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- METRICS GRID ---
class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.8 : 2.0,
          children: [
            _MetricCard(
              title: 'CURRENT EXERCISE',
              value: const Text('Back Squat', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              isHighlighted: true,
            ),
            _MetricCard(
              title: 'REP COUNTER',
              value: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: '08 ', style: TextStyle(color: kPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                    TextSpan(text: '/ 12', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
                  ]
                ),
              ),
            ),
            _MetricCard(
              title: 'TEMPO',
              value: const Text('3-1-1', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            _MetricCard(
              title: 'POWER OUTPUT',
              value: const Text('420W', style: TextStyle(color: kSecondary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final Widget value;
  final bool isHighlighted;

  const _MetricCard({required this.title, required this.value, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      border: isHighlighted ? const Border(left: BorderSide(color: kPrimary, width: 4)) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          value,
        ],
      ),
    );
  }
}

// --- RIGHT PANEL: STATS ---
class RightStatsPanel extends StatelessWidget {
  const RightStatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        FormScoreRing(),
        SizedBox(height: 24),
        ActiveAlertsCard(),
        SizedBox(height: 24),
        ImprovementTipsCard(),
      ],
    );
  }
}

class FormScoreRing extends StatelessWidget {
  const FormScoreRing({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(Icons.auto_graph, size: 80, color: kPrimary.withOpacity(0.1)),
          ),
          Column(
            children: [
              const Text('GLOBAL FORM SCORE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: 192,
                height: 192,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      color: Colors.white.withOpacity(0.05),
                    ),
                    ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [kSecondary, kPrimary],
                        ).createShader(rect);
                      },
                      child: const CircularProgressIndicator(
                        value: 0.88,
                        strokeWidth: 10,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(text: '88', style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w800, height: 1)),
                              TextSpan(text: '%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ]
                          ),
                        ),
                        const Text('OPTIMAL', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your overall mechanical efficiency is high. Stability has improved by 4% since your last set.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kOnSurfaceVariant, fontSize: 14, height: 1.5),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ActiveAlertsCard extends StatelessWidget {
  const ActiveAlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      border: const Border(left: BorderSide(color: kError, width: 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning, color: kError),
              SizedBox(width: 8),
              Text('Form Alert', style: TextStyle(color: kError, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Knees Past Toes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kError.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('CRITICAL', style: TextStyle(color: kError, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your knees are drifting too far forward during the descent. Shift weight slightly back toward your heels to protect joint integrity.',
            style: TextStyle(color: kOnSurfaceVariant, fontSize: 14, height: 1.5),
          )
        ],
      ),
    );
  }
}

class ImprovementTipsCard extends StatelessWidget {
  const ImprovementTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI INSIGHTS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          _InsightRow(
            icon: Icons.tips_and_updates, 
            color: kPrimary, 
            title: 'Drive from Heels', 
            desc: 'Focus on pressing the floor away with your mid-foot and heels to engage more posterior chain.'
          ),
          const SizedBox(height: 16),
          _InsightRow(
            icon: Icons.compress, 
            color: kSecondary, 
            title: 'Core Bracing', 
            desc: 'Maintain intra-abdominal pressure. Your lumbar is slightly rounding at the bottom of the squat.'
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _InsightRow({required this.icon, required this.color, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, height: 1.4)),
            ],
          ),
        )
      ],
    );
  }
}


// --- APP BAR & NAVIGATION ---

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
                      const Text('Dashboard', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 32),
                      const Text('Training', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Analytics', style: TextStyle(color: kOnSurfaceVariant)),
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
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts', isActive: true),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.bar_chart, title: 'Stats'),
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