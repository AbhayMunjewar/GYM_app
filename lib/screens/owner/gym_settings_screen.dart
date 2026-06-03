import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../theme/app_theme.dart';

class GymSettingsScreen extends StatefulWidget {
  const GymSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GymSettingsScreen> createState() => _GymSettingsScreenState();
}

class _GymSettingsScreenState extends State<GymSettingsScreen> {
  bool _autoCheckIn = true;
  bool _emailReceipts = true;
  bool _pushNotifications = true;
  bool _smsReminders = false;
  bool _maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('GYM SETTINGS', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Gym Identity
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('K', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.background)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kinetic Fitness Club', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text('123 Fitness Blvd, San Francisco, CA', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Open', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Operating Hours
          Text('OPERATING HOURS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _hoursRow(context, 'Monday – Friday', '5:00 AM – 11:00 PM'),
                const Divider(color: Colors.white10, height: 20),
                _hoursRow(context, 'Saturday', '6:00 AM – 10:00 PM'),
                const Divider(color: Colors.white10, height: 20),
                _hoursRow(context, 'Sunday', '7:00 AM – 8:00 PM'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Membership & Billing
          Text('MEMBERSHIP & BILLING', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _menuTile(context, Icons.credit_card, 'Payment Gateway', 'Stripe Connected', const Color(0xFF4CAF50)),
                const Divider(color: Colors.white10, height: 1),
                _menuTile(context, Icons.receipt_long, 'Tax Settings', 'US – 8.25% Sales Tax', null),
                const Divider(color: Colors.white10, height: 1),
                _menuTile(context, Icons.currency_exchange, 'Currency', 'USD (\$)', null),
                const Divider(color: Colors.white10, height: 1),
                _menuTile(context, Icons.card_membership, 'Plan Templates', '4 Active Plans', null),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Notifications & Automation
          Text('NOTIFICATIONS & AUTOMATION', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                _toggleTile(context, Icons.qr_code_scanner, 'Auto Check-in via QR', _autoCheckIn, (v) => setState(() => _autoCheckIn = v)),
                const Divider(color: Colors.white10, height: 1),
                _toggleTile(context, Icons.email_outlined, 'Email Receipts', _emailReceipts, (v) => setState(() => _emailReceipts = v)),
                const Divider(color: Colors.white10, height: 1),
                _toggleTile(context, Icons.notifications_active_outlined, 'Push Notifications', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
                const Divider(color: Colors.white10, height: 1),
                _toggleTile(context, Icons.sms_outlined, 'SMS Reminders', _smsReminders, (v) => setState(() => _smsReminders = v)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Integrations
          Text('INTEGRATIONS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                _integrationRow(context, 'Apple Health', true),
                const Divider(color: Colors.white10, height: 1),
                _integrationRow(context, 'Google Fit', true),
                const Divider(color: Colors.white10, height: 1),
                _integrationRow(context, 'Whoop', false),
                const Divider(color: Colors.white10, height: 1),
                _integrationRow(context, 'Garmin', false),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Danger Zone
          Text('DANGER ZONE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent)),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                _toggleTile(context, Icons.construction, 'Maintenance Mode', _maintenanceMode, (v) => setState(() => _maintenanceMode = v), accentColor: Colors.orange),
                const Divider(color: Colors.white10, height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 22),
                  title: const Text('Delete Gym Account', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _hoursRow(BuildContext context, String day, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(time, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, String subtitle, Color? statusColor) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurface, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: statusColor ?? AppColors.onSurfaceVariant, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      onTap: () {},
    );
  }

  Widget _toggleTile(BuildContext context, IconData icon, String title, bool value, ValueChanged<bool> onChanged, {Color? accentColor}) {
    return SwitchListTile(
      secondary: Icon(icon, color: accentColor ?? AppColors.onSurface, size: 22),
      title: Text(title, style: TextStyle(color: accentColor ?? AppColors.onSurface, fontSize: 15)),
      value: value,
      onChanged: onChanged,
      activeTrackColor: accentColor ?? AppColors.primary,
    );
  }

  Widget _integrationRow(BuildContext context, String name, bool isConnected) {
    return ListTile(
      leading: Icon(Icons.extension, color: isConnected ? AppColors.primary : AppColors.onSurfaceVariant, size: 22),
      title: Text(name, style: const TextStyle(fontSize: 15)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isConnected ? const Color(0xFF4CAF50).withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isConnected ? const Color(0xFF4CAF50).withOpacity(0.3) : Colors.white12),
        ),
        child: Text(
          isConnected ? 'Connected' : 'Connect',
          style: TextStyle(
            color: isConnected ? const Color(0xFF4CAF50) : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
