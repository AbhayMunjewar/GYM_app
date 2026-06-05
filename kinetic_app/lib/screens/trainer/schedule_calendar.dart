import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ScheduleCalendar extends StatelessWidget {
  const ScheduleCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('SCHEDULE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              alignment: Alignment.center,
              child: const Text('Calendar Strip Placeholder', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    border: Border(left: BorderSide(color: AppColors.primaryFixed, width: 4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('10:00 AM - 11:00 AM', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 8),
                      Text('1-on-1 with John Doe', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
