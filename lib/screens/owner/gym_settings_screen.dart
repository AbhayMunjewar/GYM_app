// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class GymSettingsScreen extends StatefulWidget {
//   const GymSettingsScreen({Key? key}) : super(key: key);

//   @override
//   State<GymSettingsScreen> createState() => _GymSettingsScreenState();
// }

// class _GymSettingsScreenState extends State<GymSettingsScreen> {
//   bool _autoCheckIn = true;
//   bool _emailReceipts = true;
//   bool _pushNotifications = true;
//   bool _smsReminders = false;
//   bool _maintenanceMode = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('GYM SETTINGS', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(24),
//         children: [
//           // Gym Identity
//           GlassCard(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [AppColors.primary, AppColors.secondary],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: const Center(
//                     child: Text('K', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.background)),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Kinetic Fitness Club', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
//                       const SizedBox(height: 2),
//                       Text('123 Fitness Blvd, San Francisco, CA', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
//                       const SizedBox(height: 4),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF4CAF50).withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Text('Open', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.w700)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20), onPressed: () {}),
//               ],
//             ),
//           ),
//           const SizedBox(height: 28),

//           // Operating Hours
//           Text('OPERATING HOURS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
//           const SizedBox(height: 14),
//           GlassCard(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _hoursRow(context, 'Monday – Friday', '5:00 AM – 11:00 PM'),
//                 const Divider(color: Colors.white10, height: 20),
//                 _hoursRow(context, 'Saturday', '6:00 AM – 10:00 PM'),
//                 const Divider(color: Colors.white10, height: 20),
//                 _hoursRow(context, 'Sunday', '7:00 AM – 8:00 PM'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 28),

//           // Membership & Billing
//           Text('MEMBERSHIP & BILLING', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
//           const SizedBox(height: 14),
//           GlassCard(
//             padding: const EdgeInsets.all(4),
//             child: Column(
//               children: [
//                 _menuTile(context, Icons.credit_card, 'Payment Gateway', 'Stripe Connected', const Color(0xFF4CAF50)),
//                 const Divider(color: Colors.white10, height: 1),
//                 _menuTile(context, Icons.receipt_long, 'Tax Settings', 'US – 8.25% Sales Tax', null),
//                 const Divider(color: Colors.white10, height: 1),
//                 _menuTile(context, Icons.currency_exchange, 'Currency', 'USD (\$)', null),
//                 const Divider(color: Colors.white10, height: 1),
//                 _menuTile(context, Icons.card_membership, 'Plan Templates', '4 Active Plans', null),
//               ],
//             ),
//           ),
//           const SizedBox(height: 28),

//           // Notifications & Automation
//           Text('NOTIFICATIONS & AUTOMATION', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
//           const SizedBox(height: 14),
//           GlassCard(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Column(
//               children: [
//                 _toggleTile(context, Icons.qr_code_scanner, 'Auto Check-in via QR', _autoCheckIn, (v) => setState(() => _autoCheckIn = v)),
//                 const Divider(color: Colors.white10, height: 1),
//                 _toggleTile(context, Icons.email_outlined, 'Email Receipts', _emailReceipts, (v) => setState(() => _emailReceipts = v)),
//                 const Divider(color: Colors.white10, height: 1),
//                 _toggleTile(context, Icons.notifications_active_outlined, 'Push Notifications', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
//                 const Divider(color: Colors.white10, height: 1),
//                 _toggleTile(context, Icons.sms_outlined, 'SMS Reminders', _smsReminders, (v) => setState(() => _smsReminders = v)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 28),

//           // Integrations
//           Text('INTEGRATIONS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
//           const SizedBox(height: 14),
//           GlassCard(
//             padding: const EdgeInsets.all(4),
//             child: Column(
//               children: [
//                 _integrationRow(context, 'Apple Health', true),
//                 const Divider(color: Colors.white10, height: 1),
//                 _integrationRow(context, 'Google Fit', true),
//                 const Divider(color: Colors.white10, height: 1),
//                 _integrationRow(context, 'Whoop', false),
//                 const Divider(color: Colors.white10, height: 1),
//                 _integrationRow(context, 'Garmin', false),
//               ],
//             ),
//           ),
//           const SizedBox(height: 28),

//           // Danger Zone
//           Text('DANGER ZONE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent)),
//           const SizedBox(height: 14),
//           GlassCard(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Column(
//               children: [
//                 _toggleTile(context, Icons.construction, 'Maintenance Mode', _maintenanceMode, (v) => setState(() => _maintenanceMode = v), accentColor: Colors.orange),
//                 const Divider(color: Colors.white10, height: 1),
//                 ListTile(
//                   leading: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 22),
//                   title: const Text('Delete Gym Account', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
//                   trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _hoursRow(BuildContext context, String day, String time) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(day, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
//         Text(time, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
//       ],
//     );
//   }

//   Widget _menuTile(BuildContext context, IconData icon, String title, String subtitle, Color? statusColor) {
//     return ListTile(
//       leading: Icon(icon, color: AppColors.onSurface, size: 22),
//       title: Text(title, style: const TextStyle(fontSize: 15)),
//       subtitle: Text(subtitle, style: TextStyle(color: statusColor ?? AppColors.onSurfaceVariant, fontSize: 12)),
//       trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
//       onTap: () {},
//     );
//   }

//   Widget _toggleTile(BuildContext context, IconData icon, String title, bool value, ValueChanged<bool> onChanged, {Color? accentColor}) {
//     return SwitchListTile(
//       secondary: Icon(icon, color: accentColor ?? AppColors.onSurface, size: 22),
//       title: Text(title, style: TextStyle(color: accentColor ?? AppColors.onSurface, fontSize: 15)),
//       value: value,
//       onChanged: onChanged,
//       activeTrackColor: accentColor ?? AppColors.primary,
//     );
//   }

//   Widget _integrationRow(BuildContext context, String name, bool isConnected) {
//     return ListTile(
//       leading: Icon(Icons.extension, color: isConnected ? AppColors.primary : AppColors.onSurfaceVariant, size: 22),
//       title: Text(name, style: const TextStyle(fontSize: 15)),
//       trailing: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//         decoration: BoxDecoration(
//           color: isConnected ? const Color(0xFF4CAF50).withOpacity(0.12) : AppColors.surface,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: isConnected ? const Color(0xFF4CAF50).withOpacity(0.3) : Colors.white12),
//         ),
//         child: Text(
//           isConnected ? 'Connected' : 'Connect',
//           style: TextStyle(
//             color: isConnected ? const Color(0xFF4CAF50) : AppColors.onSurfaceVariant,
//             fontWeight: FontWeight.w600,
//             fontSize: 12,
//           ),
//         ),
//       ),
//       onTap: () {},
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kSurface = Color(0xFF131313);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kPrimary = Color(0xFFCAF300);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIApp extends StatelessWidget {
  const VelocityAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Gym Settings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const SettingsDashboard(),
    );
  }
}

class SettingsDashboard extends StatefulWidget {
  const SettingsDashboard({super.key});

  @override
  State<SettingsDashboard> createState() => _SettingsDashboardState();
}

class _SettingsDashboardState extends State<SettingsDashboard> {
  bool pushNotifs = true;
  bool darkMode = true;
  bool haptic = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 900;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const PreferredSize(preferredSize: Size.fromHeight(64), child: TopAppBar()),
        body: Row(
          children: [
            if (isDesktop) const DesktopSideNav(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24, 100, 24, isDesktop ? 48 : 120),
                children: [
                  const Text('Gym Settings', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Configure your brand identity and operational rules.', style: TextStyle(color: kOnSurfaceVariant)),
                  const SizedBox(height: 32),
                  _buildContent(isDesktop),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: !isDesktop ? const MobileBottomNav() : null,
      );
    });
  }

  Widget _buildContent(bool isDesktop) {
    final body = Column(
      children: [
        const VisualIdentityCard(),
        const SizedBox(height: 24),
        const StaffManagementCard(),
        const SizedBox(height: 24),
        AppPreferencesCard(
          push: pushNotifs, dark: darkMode, haptic: haptic,
          onPush: (v) => setState(() => pushNotifs = v),
          onDark: (v) => setState(() => darkMode = v),
          onHaptic: (v) => setState(() => haptic = v),
        ),
      ],
    );
    return isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: body), const SizedBox(width: 24), const Expanded(child: PaymentGatewaysCard())]) : body;
  }
}

// --- WIDGETS ---

class VisualIdentityCard extends StatelessWidget {
  const VisualIdentityCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.palette, color: kPrimary), SizedBox(width: 8), Text('Visual Identity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 24),
      Container(
        height: 150,
        decoration: BoxDecoration(color: kSurfaceHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12, style: BorderStyle.dashed)),
        child: const Center(child: Icon(Icons.upload_file, color: kPrimary)),
      )
    ]),
  );
}

class StaffManagementCard extends StatelessWidget {
  const StaffManagementCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Staff Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton(onPressed: () {}, child: const Text('Add Member'))
      ]),
      const SizedBox(height: 16),
      const _StaffRow(name: 'Jordan Davids', role: 'Head Trainer', color: kPrimary),
      const _StaffRow(name: 'Sarah Miller', role: 'Yoga Instructor', color: kSecondaryContainer),
    ]),
  );
}

class _StaffRow extends StatelessWidget {
  final String name, role;
  final Color color;
  const _StaffRow({required this.name, required this.role, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(children: [
      CircleAvatar(backgroundColor: kSurfaceHigh, child: Text(name[0], style: TextStyle(color: color))),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(role, style: const TextStyle(fontSize: 12, color: kOnSurfaceVariant))])
    ]),
  );
}

class AppPreferencesCard extends StatelessWidget {
  final bool push, dark, haptic;
  final Function(bool) onPush, onDark, onHaptic;
  const AppPreferencesCard({super.key, required this.push, required this.dark, required this.haptic, required this.onPush, required this.onDark, required this.onHaptic});

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(children: [
      const Align(alignment: Alignment.topLeft, child: Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      SwitchListTile(title: const Text('Push Notifications'), value: push, onChanged: onPush, activeColor: kPrimary),
      SwitchListTile(title: const Text('Dark Mode'), value: dark, onChanged: onDark, activeColor: kPrimary),
      SwitchListTile(title: const Text('Haptic Feedback'), value: haptic, onChanged: onHaptic, activeColor: kPrimary),
    ]),
  );
}

class PaymentGatewaysCard extends StatelessWidget {
  const PaymentGatewaysCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(children: const [
      Text('Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 16),
      ListTile(leading: Icon(Icons.account_balance_wallet, color: kPrimary), title: Text('Stripe Integration')),
      ListTile(leading: Icon(Icons.apple, color: Colors.white), title: Text('Apple Pay')),
    ]),
  );
}

// --- UTILITY WIDGETS ---

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const GlassCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(color: kSurface.withOpacity(0.7), border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
        child: child,
      ),
    ),
  );
}

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: kBackground.withOpacity(0.8),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: const [Icon(Icons.bolt, color: kPrimary), SizedBox(width: 8), Text('VELOCITY AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimary, fontStyle: FontStyle.italic))]),
      const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
    ])),
  );
}

class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 288,
    color: kSurface,
    child: Column(children: [
      const SizedBox(height: 100),
      const ListTile(leading: CircleAvatar(backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAEq0BrnA2BXu-UZRenm7H2STzNj2sb9QlsesjhRt-0oBtUjULHCPFtqqPiplxEvW0inHV1oSCHKPaSXnqB6bDAlPHtvLbgSSpVgVmrKMCXfAa0npo1hEO744uEf8A03DQw0LgystfnQIikPiHW4Izpe_DBib1BjdI0zmuUzrlWfPU9t_VP5RbIQ-ouQMLHhBwZgP8mhlT2i1zY8HTk8k30ax8DjloRWHX1r9Hc_Bkv03gyC090aPmSWJQAT8s9eA7cmT7YzplJo_k')), title: Text('Alex Rivers'), subtitle: Text('Pro Athlete • Lvl 42')),
      ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard')),
      ListTile(leading: const Icon(Icons.fitness_center), title: const Text('Training')),
      ListTile(leading: const Icon(Icons.settings, color: kPrimary), title: const Text('Settings')),
    ]),
  );
}

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    backgroundColor: kBackground,
    selectedItemColor: kPrimary,
    unselectedItemColor: kOnSurfaceVariant,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ],
  );
}