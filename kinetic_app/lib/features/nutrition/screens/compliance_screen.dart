import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../providers/nutrition_providers.dart';

class ComplianceScreen extends ConsumerStatefulWidget {
  const ComplianceScreen({super.key});

  @override
  ConsumerState<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends ConsumerState<ComplianceScreen> {
  String _period = 'weekly'; // weekly or monthly
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchData());
  }

  void _fetchData() {
    ref.read(dietComplianceProvider.notifier).fetchCompliance(_period);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.yellow;
    return Colors.redAccent;
  }

  Color _getCalendarCellColor(int pct) {
    if (pct == 0) return AppColors.white10;
    if (pct >= 80) return Colors.green.withOpacity(0.8);
    if (pct >= 50) return Colors.green.withOpacity(0.4);
    return Colors.green.withOpacity(0.15);
  }

  @override
  Widget build(BuildContext context) {
    final compState = ref.watch(dietComplianceProvider);
    final profile = ref.watch(nutritionProfileProvider).profile;
    
    final data = compState.complianceData;
    final score = data?['compliance_score'] ?? 0;
    final avgCal = data?['avg_calories'] ?? 0;
    final avgProt = data?['avg_protein_g'] ?? 0;
    final rate = data?['meal_completion_rate'] ?? 0.0;
    final logsDetail = data?['logs_detail'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'DIET COMPLIANCE',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _fetchData,
          )
        ],
      ),
      body: SafeArea(
        child: compState.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    _buildComplianceRingCard(score, rate),
                    const SizedBox(height: 24),
                    _buildStatsRow(avgCal, avgProt, profile?['target_calories'] ?? 0, profile?['protein_g'] ?? 0),
                    const SizedBox(height: 28),
                    if (_period == 'weekly')
                      _buildWeeklyTimelineCard(logsDetail)
                    else
                      _buildMonthlyCalendarCard(logsDetail),
                    const SizedBox(height: 24),
                    _buildLogActionForm(profile, logsDetail),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodTab('weekly', 'Weekly View'),
          _buildPeriodTab('monthly', 'Monthly Calendar'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String mode, String label) {
    final isSelected = _period == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _period = mode);
          _fetchData();
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryFixed : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceRingCard(int score, double rate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 12,
                  backgroundColor: AppColors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score%',
                    style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'COMPLIANCE',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            score >= 80 
                ? 'Excellent consistency! Keep hitting your targets. 🔥' 
                : (score >= 60 ? 'On track! Try to hit more meal marks.' : 'Consistency is low. Reach out to AI Diet Coach!'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget _buildStatsRow(int avgCal, int avgProt, int targetCal, int targetProt) {
    return Row(
      children: [
        Expanded(
          child: _buildStatMiniCard(
            'Calorie Intake',
            '$avgCal kcal',
            'Target: $targetCal kcal',
            Icons.restaurant,
            const Color(0xFFCAF300),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatMiniCard(
            'Avg Protein',
            '${avgProt}g',
            'Target: ${targetProt}g',
            Icons.fitness_center,
            const Color(0xFF4B8EFF),
          ),
        ),
      ],
    );
  }

  Widget _buildStatMiniCard(String label, String value, String target, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              Icon(icon, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(target, style: const TextStyle(color: Colors.white30, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWeeklyTimelineCard(Map<String, dynamic> logsDetail) {
    // Generate last 7 days starting from today backwards
    final today = DateTime.now();
    final List<DateTime> weekDays = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '7-DAY COMPLETION MATRIX',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((date) {
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final logged = logsDetail.containsKey(dateStr);
              final pct = logged ? (logsDetail[dateStr]['compliance_pct'] ?? 0) : 0;
              final color = logged ? _getScoreColor(pct) : Colors.grey;

              return Column(
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: logged ? color.withOpacity(0.15) : AppColors.white10,
                      shape: BoxShape.circle,
                      border: Border.all(color: logged ? color : AppColors.white10),
                    ),
                    child: Text(
                      logged ? '$pct%' : '-',
                      style: TextStyle(
                        color: logged ? color : AppColors.onSurfaceVariant,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendarCard(Map<String, dynamic> logsDetail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'COMPLIANCE HEATMAP',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
              iconColor: AppColors.primaryFixed,
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
              weekendStyle: TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final dateStr = DateFormat('yyyy-MM-dd').format(day);
                final logged = logsDetail.containsKey(dateStr);
                final pct = logged ? (logsDetail[dateStr]['compliance_pct'] ?? 0) : 0;
                final color = _getCalendarCellColor(pct);

                return Container(
                  margin: const EdgeInsets.all(3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final dateStr = DateFormat('yyyy-MM-dd').format(day);
                final logged = logsDetail.containsKey(dateStr);
                final pct = logged ? (logsDetail[dateStr]['compliance_pct'] ?? 0) : 0;
                final color = _getCalendarCellColor(pct);

                return Container(
                  margin: const EdgeInsets.all(3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryFixed, width: 1.5),
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogActionForm(Map<String, dynamic>? profile, Map<String, dynamic> logsDetail) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasTodayLog = logsDetail.containsKey(todayStr);
    final todayLog = hasTodayLog ? logsDetail[todayStr] : null;

    // Check states
    bool bDone = todayLog?['breakfast'] ?? false;
    bool lDone = todayLog?['lunch'] ?? false;
    bool dDone = todayLog?['dinner'] ?? false;
    bool sDone = todayLog?['snacks'] ?? false;
    bool preDone = todayLog?['pre_workout'] ?? false;
    bool postDone = todayLog?['post_workout'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "LOG TODAY'S COMPLETED MEALS",
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          _buildMealCheckbox('Breakfast', bDone, (val) => _updateLog('breakfast_done', val, bDone, lDone, dDone, sDone, preDone, postDone, profile)),
          _buildMealCheckbox('Lunch', lDone, (val) => _updateLog('lunch_done', val, bDone, lDone, dDone, sDone, preDone, postDone, profile)),
          _buildMealCheckbox('Dinner', dDone, (val) => _updateLog('dinner_done', val, bDone, lDone, dDone, sDone, preDone, postDone, profile)),
          _buildMealCheckbox('Snacks', sDone, (val) => _updateLog('snacks_done', val, bDone, lDone, dDone, sDone, preDone, postDone, profile)),
          _buildMealCheckbox('Pre-Workout', preDone, (val) => _updateLog('pre_workout_done', val, bDone, lDone, dDone, sDone, preDone, postDone, profile)),
          _buildMealCheckbox('Post-Workout', postDone, (val) => _updateLog('post_workout_done', val, bDone, lDone, dDone, sDone, preDone, postDone, profile)),
        ],
      ),
    );
  }

  Widget _buildMealCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      activeColor: AppColors.primaryFixed,
      checkColor: AppColors.onPrimaryFixed,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 14)),
      onChanged: onChanged,
    );
  }

  void _updateLog(
    String key, bool? checked,
    bool b, bool l, bool d, bool s, bool pre, bool post,
    Map<String, dynamic>? profile,
  ) {
    // Map current checkbox values and toggle target field
    final Map<String, dynamic> logPayload = {
      'breakfast_done': key == 'breakfast_done' ? (checked ?? false) : b,
      'lunch_done': key == 'lunch_done' ? (checked ?? false) : l,
      'dinner_done': key == 'dinner_done' ? (checked ?? false) : d,
      'snacks_done': key == 'snacks_done' ? (checked ?? false) : s,
      'pre_workout_done': key == 'pre_workout_done' ? (checked ?? false) : pre,
      'post_workout_done': key == 'post_workout_done' ? (checked ?? false) : post,
      'log_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };

    // Calculate calories & protein consumed today
    int calories = 0;
    int protein = 0;
    if (profile != null) {
      final calTarget = profile['target_calories'] ?? 2000;
      final protTarget = profile['protein_g'] ?? 140;

      // Simple heuristic weights for calories / protein fractions
      final int mealCount = 6;
      final avgCal = calTarget ~/ mealCount;
      final avgProt = protTarget ~/ mealCount;

      int completed = 0;
      logPayload.forEach((k, v) {
        if (v == true && k != 'log_date') completed++;
      });

      calories = completed * avgCal;
      protein = completed * avgProt;
    }

    logPayload['calories_consumed'] = calories;
    logPayload['protein_consumed_g'] = protein;

    ref.read(dietComplianceProvider.notifier).logDietMeal(logPayload, _period).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diet tracked!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
        );
      }
    });
  }
}
