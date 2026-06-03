// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class AttendanceManagementScreen extends StatefulWidget {
//   const AttendanceManagementScreen({Key? key}) : super(key: key);

//   @override
//   State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
// }

// class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
//   String _selectedFilter = 'Today';
//   final List<String> _filters = ['Today', 'This Week', 'This Month'];

//   final List<Map<String, dynamic>> _attendanceLog = [
//     {'name': 'Alex Walker', 'time': '6:02 AM', 'type': 'Check-in', 'zone': 'Free Weights'},
//     {'name': 'Sarah Chen', 'time': '6:15 AM', 'type': 'Check-in', 'zone': 'Cardio'},
//     {'name': 'Mike Johnson', 'time': '7:00 AM', 'type': 'Check-in', 'zone': 'Group Class'},
//     {'name': 'Priya Sharma', 'time': '7:30 AM', 'type': 'Check-out', 'zone': 'Free Weights'},
//     {'name': 'Tom Richards', 'time': '8:00 AM', 'type': 'Check-in', 'zone': 'Machines'},
//     {'name': 'Lisa Park', 'time': '8:12 AM', 'type': 'No-show', 'zone': 'PT Session'},
//     {'name': 'David Kim', 'time': '8:45 AM', 'type': 'Check-in', 'zone': 'CrossFit'},
//     {'name': 'Emma Wilson', 'time': '9:10 AM', 'type': 'Check-in', 'zone': 'Yoga Studio'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('ATTENDANCE', style: Theme.of(context).textTheme.labelLarge),
//         actions: [
//           IconButton(icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary), onPressed: () {}),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(24),
//         children: [
//           // Quick stats row
//           Row(
//             children: [
//               Expanded(child: _statTile(context, '147', 'Checked In', const Color(0xFF4CAF50))),
//               const SizedBox(width: 12),
//               Expanded(child: _statTile(context, '12', 'No-shows', Colors.redAccent)),
//               const SizedBox(width: 12),
//               Expanded(child: _statTile(context, '83%', 'Rate', AppColors.primary)),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Peak Hours Visualization
//           GlassCard(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('PEAK HOURS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   height: 80,
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       _barSegment(context, '6a', 0.4),
//                       _barSegment(context, '7a', 0.7),
//                       _barSegment(context, '8a', 0.9),
//                       _barSegment(context, '9a', 0.6),
//                       _barSegment(context, '10a', 0.3),
//                       _barSegment(context, '11a', 0.25),
//                       _barSegment(context, '12p', 0.55),
//                       _barSegment(context, '1p', 0.45),
//                       _barSegment(context, '5p', 0.85),
//                       _barSegment(context, '6p', 1.0),
//                       _barSegment(context, '7p', 0.75),
//                       _barSegment(context, '8p', 0.5),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Filter chips
//           Row(
//             children: [
//               Text('ACTIVITY LOG', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
//               const Spacer(),
//               ..._filters.map((f) => Padding(
//                 padding: const EdgeInsets.only(left: 6),
//                 child: GestureDetector(
//                   onTap: () => setState(() => _selectedFilter = f),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: _selectedFilter == f ? AppColors.primary : Colors.transparent,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: _selectedFilter == f ? AppColors.primary : Colors.white12),
//                     ),
//                     child: Text(
//                       f,
//                       style: TextStyle(
//                         color: _selectedFilter == f ? AppColors.background : AppColors.onSurfaceVariant,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               )),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Activity log entries
//           ...List.generate(_attendanceLog.length, (index) {
//             final entry = _attendanceLog[index];
//             final isNoShow = entry['type'] == 'No-show';
//             final isCheckOut = entry['type'] == 'Check-out';
//             Color statusColor = isNoShow ? Colors.redAccent : (isCheckOut ? Colors.orange : const Color(0xFF4CAF50));
//             IconData statusIcon = isNoShow ? Icons.cancel_outlined : (isCheckOut ? Icons.logout : Icons.login);

//             return Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: GlassCard(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 38,
//                       height: 38,
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(statusIcon, color: statusColor, size: 20),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(entry['name'] as String, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
//                           Row(
//                             children: [
//                               Text(entry['zone'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
//                               const SizedBox(width: 8),
//                               Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
//                               const SizedBox(width: 8),
//                               Text(entry['time'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(entry['type'] as String, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11)),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _statTile(BuildContext context, String value, String label, Color accentColor) {
//     return GlassCard(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//       child: Column(
//         children: [
//           Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: accentColor, fontSize: 28)),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }

//   Widget _barSegment(BuildContext context, String label, double fillPercent) {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 2),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Container(
//               height: 60 * fillPercent,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     AppColors.primary.withOpacity(0.8),
//                     AppColors.primary.withOpacity(fillPercent > 0.8 ? 1.0 : 0.4),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9)),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIAttendanceApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF131313);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceLow = Color(0xFF131313);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAIAttendanceApp extends StatelessWidget {
  const VelocityAIAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Attendance Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AttendanceScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

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
                          _buildMainGrid(isDesktop),
                          const SizedBox(height: 32),
                          const AnalyticsSection(),
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
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 
          ? const MobileBottomNav() 
          : null,
    );
  }

  Widget _buildMainGrid(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 7, child: ScannerCard()),
          const SizedBox(width: 24),
          Expanded(
            flex: 5,
            child: Column(
              children: const [
                OccupancyCard(),
                SizedBox(height: 24),
                LiveFeedCard(),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: const [
        ScannerCard(),
        SizedBox(height: 24),
        OccupancyCard(),
        SizedBox(height: 24),
        LiveFeedCard(),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'Inter', fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.1),
            children: [
              TextSpan(text: 'Check-In ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Portal', style: TextStyle(color: kPrimary)),
            ]
          )
        ),
        const SizedBox(height: 8),
        const Text(
          'Real-time attendance tracking and high-performance gym capacity management.', 
          style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)
        ),
      ],
    );
  }
}

class ScannerCard extends StatelessWidget {
  const ScannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.2),
                border: Border.all(color: kPrimary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('SCANNER ACTIVE', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 16),
          // Scanner Area
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 100, color: Colors.white10),
                const MockQrGrid(),
                const AnimatedScannerLine(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Ready to Check-in?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Position your member QR code within the frame to gain access.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
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
                child: const Text('MANUAL ENTRY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {},
                child: const Text('SUPPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              )
            ],
          )
        ],
      ),
    );
  }
}

class AnimatedScannerLine extends StatefulWidget {
  const AnimatedScannerLine({super.key});

  @override
  State<AnimatedScannerLine> createState() => _AnimatedScannerLineState();
}

class _AnimatedScannerLineState extends State<AnimatedScannerLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value * 280, // Approximate height within container
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: kPrimary,
              boxShadow: [BoxShadow(color: kPrimary, blurRadius: 15)],
            ),
          ),
        );
      },
    );
  }
}

class MockQrGrid extends StatelessWidget {
  const MockQrGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: SizedBox(
        width: 150,
        height: 150,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemCount: 36,
          itemBuilder: (context, index) {
            // Random-looking pattern
            bool isWhite = index % 2 == 0 || index % 3 == 0 || index % 7 == 0;
            return Container(
              decoration: BoxDecoration(
                color: isWhite ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OccupancyCard extends StatelessWidget {
  const OccupancyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CURRENT OCCUPANCY', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: '42 ', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
                    TextSpan(text: '/ 80', style: TextStyle(color: kPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]
                ),
              )
            ],
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  color: Colors.white.withOpacity(0.05),
                ),
                const CircularProgressIndicator(
                  value: 0.52,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(kPrimary),
                  strokeCap: StrokeCap.round,
                ),
                const Center(
                  child: Text('52%', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LiveFeedCard extends StatelessWidget {
  const LiveFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Activity', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: const [
                    PulseDot(),
                    SizedBox(width: 6),
                    Text('Live', style: TextStyle(color: kPrimary, fontSize: 12)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  _FeedItem(
                    name: 'Sarah Jenkins', 
                    action: 'Check-in • 08:42 AM', 
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAjk0hcWgdlJpbM2ZzmNGC9k6fP1KXifdnWhMysN3VE7P5PMaSpLQYnKVVJUCBaTygWDCdv38pK8B43azf7ovMC7XdA8uvDM0X4c6N-KbeM3M9buRqr_3WUd0llSQORsbRr_eAHnnixxgtxHHxQRBejp7SdMec2lzXE0fI4sAXd2ZHsVO0x--ZAT9r_cE0jIMzkZlDEbPVXbS2k5eTmfmAmmn0A533ONR6ajXM_V8g76uSHd374BBGIfLtISkCUn4fj1k9CZ7QPwxc',
                    icon: Icons.login,
                    iconColor: kPrimary,
                    isBordered: true,
                  ),
                  SizedBox(height: 12),
                  _FeedItem(
                    name: 'Mark Thompson', 
                    action: 'Check-out • 08:35 AM', 
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwsmL7fEBI2D_5alK-5F2hlipkWGJZi1FjDZmW7gUNXYsNZ8vP5edGx7VYmlMWc5-ijkovl1aqiTPnoAwVFkKQL1fT_2eFlBHHnT1I003t_CM_aHaR9X37X_8Tug48KhJcjal-D2uZsrDLP_8xaTooQg4GQ3hAj3KYwCtkAtNtVtb9qRDKXrwGPKCF7L0vgoROhdgv3mS0czHy9K0FbdoBwApDw-lXkeLBaENdZjgAJQEQI0-FH-EL3M6Hy4QNZJqsEgaubx8pJiw',
                    icon: Icons.logout,
                    iconColor: kOnSurfaceVariant,
                  ),
                  SizedBox(height: 12),
                  _FeedItem(
                    name: 'Elena Rodriguez', 
                    action: 'Check-in • 08:12 AM', 
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCeu-GHEYf7R595hiMO4NOFRyWxp4wKfhLTUf7ZX8Hm3VKG5AjVeOyieISF1CO2gYvjtt-7NWh0cKAn9wRRMki4AuqE0NERCan9VLqaohJwyokN7RubfzJnoUcdqWgK3myUtXtcGzH47tDjY8QZmrVUs7ai9ZEP94d5ihFV-LJ1PxYRKu-U7W7pViVplfyKvYKyfUAN6wLMBUC5v9H4xb5aoZD6Ooqq_Oa1QzRBq2THf7oNBz_wMrtH2HGH3SBqYFy5tAbw_DA9GMg',
                    icon: Icons.login,
                    iconColor: kPrimary,
                  ),
                  SizedBox(height: 12),
                  _FeedItem(
                    name: 'James Wilson', 
                    action: 'Check-in • 08:05 AM', 
                    imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoKzDVUttfZSlqb85PATZrnx7esmqU9pGwixIwBdOxc3Apxvc2dW25iW41OZwQKcdcHXMqfKwVrtRrPha5SFcLCXgoXsHf2Y7PI77QVpjimM0LHgkezbJZOQtPjC3frVqwiHosDWQlvlkFZUVtt-5wYpR0Omo8CXQe13y8y1VyzRni_AFoy26F6S9d9ZgsFGzhVthF-ibcZJ1bs7iawdD-9XeXGhe-vKZeKXr9MBYqENGui6Xhk31ioRhAvjB9ftdo8EqmvXj2H6U',
                    icon: Icons.login,
                    iconColor: kPrimary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('VIEW ALL ACTIVE MEMBERS', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        ),
      ),
    );
  }
}

class _FeedItem extends StatelessWidget {
  final String name;
  final String action;
  final String imgUrl;
  final IconData icon;
  final Color iconColor;
  final bool isBordered;

  const _FeedItem({
    required this.name, required this.action, required this.imgUrl, required this.icon, required this.iconColor, this.isBordered = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: isBordered ? kPrimary.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isBordered ? kPrimary.withOpacity(0.2) : Colors.white.withOpacity(0.2)),
                ),
                child: ClipOval(
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]), // Grayscale
                    child: Image.network(imgUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(action, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                ],
              )
            ],
          ),
          Icon(icon, color: iconColor, size: 20),
        ],
      ),
    );
  }
}

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Peak Performance Analytics', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Analyzing traffic density and average session duration.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                ],
              ),
              if (isMobile) const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Peak Hours', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Daily Recap', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Stats
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: Column(
                  children: const [
                    _StatBox(title: 'PEAK TIME', valueText: '05:30 PM', subText: '+12% vs last week', isPrimary: true),
                    SizedBox(height: 16),
                    _StatBox(title: 'AVG. SESSION', valueText: '74', unitText: 'mins', subText: '-4% vs last week'),
                  ],
                ),
              ),
              if (!isMobile) const SizedBox(width: 24),
              if (isMobile) const SizedBox(height: 24),
              // Chart Area
              const Expanded(child: BarChartVisualization()),
            ],
          )
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String valueText;
  final String? unitText;
  final String subText;
  final bool isPrimary;

  const _StatBox({required this.title, required this.valueText, this.unitText, required this.subText, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: valueText, style: TextStyle(color: isPrimary ? kPrimary : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                if (unitText != null) TextSpan(text: ' $unitText', style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
              ]
            )
          ),
          const SizedBox(height: 8),
          Text(subText, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}

class BarChartVisualization extends StatelessWidget {
  const BarChartVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    final heights = [0.2, 0.45, 0.3, 0.25, 0.15, 0.85, 0.95, 0.6, 0.4, 0.2, 0.1, 0.05];
    
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: heights.map((h) {
              final isPeak = h >= 0.85;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      if (h == 0.85) // Simulate the "PEAK" label on one bar
                        Positioned(
                          top: -24,
                          child: const Text('PEAK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      FractionallySizedBox(
                        heightFactor: h,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isPeak ? kPrimary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // X-Axis Labels (Hidden on very small screens in HTML, we'll just show them)
          Positioned(
            bottom: -20,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('06:00', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10)),
                Text('12:00', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10)),
                Text('18:00', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('00:00', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10)),
              ],
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
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBw3IpafImgzlaTpKJxz-pEzG8ljKqtjksjN_Z0IqHb9I8YXEiKO1TEkfqt3yVhTzNRbweYrsFiOik_1btMOWNDN7Phpbm5DXT4sz8SutB5Wr8T5dov3rWMlBHz8xk9A81C6aBg3kNbbC1LtYwmevhamPq8Qg0rt9tAjTjNgKKgfY1e391xPnRoBj-haON5hiiJbePlKNrgu-8BXyvCgkH8AunkZ6J84QnbCmMMMfgWyuTPEIMRyAmKq7BGEW6eXXT-146SrLg0OVE'),
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
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPrimary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.person, color: kPrimary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • LVL 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                _NavTile(icon: Icons.group, title: 'Members'),
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
              _BottomNavIcon(icon: Icons.qr_code_scanner, title: 'Check-In', isActive: true),
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

// --- UTILITY WIDGETS ---

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
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
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
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