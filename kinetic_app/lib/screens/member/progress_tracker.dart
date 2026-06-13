import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/progress_models.dart';

class ProgressTracker extends StatefulWidget {
  final String? memberId;
  const ProgressTracker({super.key, this.memberId});

  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMsg = '';

  List<ProgressMeasurement> _measurements = [];
  List<FitnessGoal> _goals = [];
  List<ProgressPhoto> _photos = [];
  List<ProgressMilestone> _milestones = [];
  ProgressAnalytics? _analytics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      // 1. Fetch Measurements
      final measRes = await _apiClient.getMeasurements(memberId: widget.memberId);
      if (measRes.statusCode == 200) {
        final body = jsonDecode(measRes.body);
        if (body['success'] == true) {
          final data = body['data'];
          List<dynamic> results = [];
          if (data is Map && data.containsKey('results')) {
            results = data['results'] ?? [];
          } else if (data is List) {
            results = data;
          }
          _measurements = results.map((e) => ProgressMeasurement.fromJson(e)).toList();
        }
      }

      // 2. Fetch Goals
      final goalsRes = await _apiClient.getGoals(memberId: widget.memberId);
      if (goalsRes.statusCode == 200) {
        final body = jsonDecode(goalsRes.body);
        if (body['success'] == true) {
          final data = body['data'];
          List<dynamic> results = [];
          if (data is Map && data.containsKey('results')) {
            results = data['results'] ?? [];
          } else if (data is List) {
            results = data;
          }
          _goals = results.map((e) => FitnessGoal.fromJson(e)).toList();
        }
      }

      // 3. Fetch Photos
      final photosRes = await _apiClient.getProgressPhotos(memberId: widget.memberId);
      if (photosRes.statusCode == 200) {
        final body = jsonDecode(photosRes.body);
        if (body['success'] == true) {
          final data = body['data'];
          List<dynamic> results = [];
          if (data is Map && data.containsKey('results')) {
            results = data['results'] ?? [];
          } else if (data is List) {
            results = data;
          }
          _photos = results.map((e) => ProgressPhoto.fromJson(e)).toList();
        }
      }

      // 4. Fetch Analytics (which yields achievements, timelines and trends)
      final analRes = await _apiClient.getProgressAnalytics(memberId: widget.memberId);
      if (analRes.statusCode == 200) {
        final body = jsonDecode(analRes.body);
        if (body['success'] == true) {
          _analytics = ProgressAnalytics.fromJson(body['data']);
        }
      }

    } catch (e) {
      _errorMsg = 'Error loading progress data: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.memberId != null ? 'CLIENT PROGRESS' : 'MY PROGRESS',
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryFixed,
          labelColor: AppColors.primaryFixed,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'DASHBOARD'),
            Tab(text: 'MEASURES'),
            Tab(text: 'PHOTOS'),
            Tab(text: 'CHARTS'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : _errorMsg.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppColors.primaryFixed,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              _errorMsg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(),
                      _buildMeasurementsTab(),
                      _buildPhotosTab(),
                      _buildChartsTab(),
                    ],
                  ),
      ),
    );
  }

  // ==========================================
  // TAB 1: DASHBOARD
  // ==========================================
  Widget _buildDashboardTab() {
    final summary = _analytics?.transformationSummary ?? {};
    final weightChange = double.tryParse(summary['weight_change']?.toString() ?? '0.0') ?? 0.0;
    final bfChange = double.tryParse(summary['body_fat_change']?.toString() ?? '0.0') ?? 0.0;
    final currentWeight = double.tryParse(summary['current_weight']?.toString() ?? '0.0') ?? 0.0;
    final startWeight = double.tryParse(summary['start_weight']?.toString() ?? '0.0') ?? 0.0;
    final activeGoals = _goals.where((g) => g.status == 'ACTIVE').toList();

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryFixed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick transformation summary banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF201F1F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Weight Transformation', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                      Text(
                        weightChange == 0.0
                            ? 'Stable'
                            : '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          color: weightChange <= 0 ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStat('Baseline', '${startWeight.toStringAsFixed(1)} kg'),
                      Container(width: 1, height: 32, color: AppColors.white10),
                      _buildSummaryStat('Current', '${currentWeight.toStringAsFixed(1)} kg'),
                      Container(width: 1, height: 32, color: AppColors.white10),
                      _buildSummaryStat('Body Fat', '${bfChange > 0 ? '+' : ''}${bfChange.toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Goals Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACTIVE TARGET GOALS',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                TextButton.icon(
                  onPressed: _showAddGoalDialog,
                  icon: const Icon(Icons.add, color: AppColors.primaryFixed, size: 18),
                  label: const Text('Add Goal', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (activeGoals.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF201F1F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.white10),
                ),
                alignment: Alignment.center,
                child: const Text('No active fitness goals set yet.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              )
            else
              ...activeGoals.map((goal) => _buildGoalCard(goal)),

            const SizedBox(height: 24),

            // Achievements / Milestones Section
            const Text(
              'UNLOCKED MILESTONES',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 12),

            if (_analytics?.timeline.where((t) => t.type == 'MILESTONE').isEmpty ?? true)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF201F1F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.white10),
                ),
                alignment: Alignment.center,
                child: const Text('Record metrics and streaks to unlock badges.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              )
            else
              ...(_analytics?.timeline.where((t) => t.type == 'MILESTONE').map((ms) => _buildMilestoneTile(ms)) ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildGoalCard(FitnessGoal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.goalType.replaceAll('_', ' '),
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _handleDeleteGoal(goal.id),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.onSurfaceVariant, size: 12),
              const SizedBox(width: 6),
              Text(
                'Target Date: ${goal.targetDate}',
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target Weight', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('${goal.targetWeight?.toStringAsFixed(1) ?? "--"} kg', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Weight', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('${goal.startingWeight?.toStringAsFixed(1) ?? "--"} kg', style: const TextStyle(color: AppColors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Target Fat %', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('${goal.targetBodyFat?.toStringAsFixed(1) ?? "--"}%', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.currentProgressPercentage / 100.0,
                    minHeight: 6,
                    backgroundColor: AppColors.white10,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryFixed),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${goal.currentProgressPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMilestoneTile(TimelineEvent ms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: AppColors.primaryFixed, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ms.title.replaceAll('Unlocked Achievement: ', ''),
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(ms.description, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Text(ms.date, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: MEASUREMENTS (LIST & TIMELINE)
  // ==========================================
  Widget _buildMeasurementsTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryFixed,
        onPressed: _showAddMeasurementModal,
        child: const Icon(Icons.add, color: AppColors.onPrimaryFixed),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryFixed,
        child: _measurements.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Text(
                      'No body measurements logged yet.\nTap + to record your first metrics!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _measurements.length,
                itemBuilder: (context, index) {
                  final m = _measurements[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF201F1F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: AppColors.primaryFixed, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  m.recordedDate,
                                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => _handleDeleteMeasurement(m.id),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMeasStat('Weight', '${m.weightKg.toStringAsFixed(1)} kg'),
                            _buildMeasStat('Body Fat', '${m.bodyFatPercentage.toStringAsFixed(1)}%'),
                            _buildMeasStat('BMI', m.bmi != null ? m.bmi!.toStringAsFixed(1) : '--'),
                            _buildMeasStat('Height', '${m.heightCm.toStringAsFixed(0)} cm'),
                          ],
                        ),
                        if (_hasTapeMeasurements(m)) ...[
                          const SizedBox(height: 16),
                          Container(width: double.infinity, height: 1, color: AppColors.white10),
                          const SizedBox(height: 12),
                          const Text(
                            'TAPE MEASUREMENTS (cm)',
                            style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              if (m.chestCm != null) _buildTapeChip('Chest', m.chestCm!),
                              if (m.waistCm != null) _buildTapeChip('Waist', m.waistCm!),
                              if (m.hipsCm != null) _buildTapeChip('Hips', m.hipsCm!),
                              if (m.shouldersCm != null) _buildTapeChip('Shoulders', m.shouldersCm!),
                              if (m.bicepsCm != null) _buildTapeChip('Biceps', m.bicepsCm!),
                              if (m.forearmsCm != null) _buildTapeChip('Forearms', m.forearmsCm!),
                              if (m.thighsCm != null) _buildTapeChip('Thighs', m.thighsCm!),
                              if (m.calvesCm != null) _buildTapeChip('Calves', m.calvesCm!),
                              if (m.neckCm != null) _buildTapeChip('Neck', m.neckCm!),
                            ],
                          )
                        ],
                        if (m.notes != null && m.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Notes: ${m.notes}',
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildMeasStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildTapeChip(String part, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$part: ${value.toStringAsFixed(1)}',
        style: const TextStyle(color: AppColors.white, fontSize: 11),
      ),
    );
  }

  bool _hasTapeMeasurements(ProgressMeasurement m) {
    return m.chestCm != null ||
        m.waistCm != null ||
        m.hipsCm != null ||
        m.shouldersCm != null ||
        m.bicepsCm != null ||
        m.forearmsCm != null ||
        m.thighsCm != null ||
        m.calvesCm != null ||
        m.neckCm != null;
  }

  // ==========================================
  // TAB 3: PHOTOS (COMPARISON & GALLERY)
  // ==========================================
  Widget _buildPhotosTab() {
    final frontPhotos = _photos.where((p) => p.photoType == 'FRONT').toList();
    final sidePhotos = _photos.where((p) => p.photoType == 'SIDE').toList();
    final backPhotos = _photos.where((p) => p.photoType == 'BACK').toList();

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryFixed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Before / After Compare Card
            if (_photos.length >= 2) ...[
              const Text(
                'BEFORE vs AFTER TRANSFORMATION',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF201F1F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.white10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildPhotoWidget(_photos.last.image),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                color: Colors.black87,
                                child: Text('BEFORE (${_photos.last.uploadedAt.substring(0, 10)})', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(width: 2, color: AppColors.background),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildPhotoWidget(_photos.first.image),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                color: Colors.black87,
                                child: Text('AFTER (${_photos.first.uploadedAt.substring(0, 10)})', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PHOTO GALLERY',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                TextButton.icon(
                  onPressed: _showPhotoUploadDialog,
                  icon: const Icon(Icons.camera_alt, color: AppColors.primaryFixed, size: 18),
                  label: const Text('Upload Photo', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildPhotoSection('FRONT ANGLE', frontPhotos),
            const SizedBox(height: 20),
            _buildPhotoSection('SIDE ANGLE', sidePhotos),
            const SizedBox(height: 20),
            _buildPhotoSection('BACK ANGLE', backPhotos),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(String title, List<ProgressPhoto> sectionPhotos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (sectionPhotos.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.white10),
            ),
            alignment: Alignment.center,
            child: const Text('No photos added for this angle yet.', style: TextStyle(color: AppColors.onSurfaceVariant)),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sectionPhotos.length,
              itemBuilder: (context, index) {
                final photo = sectionPhotos[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.white10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildPhotoWidget(photo.image),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: InkWell(
                        onTap: () => _handleDeletePhoto(photo.id),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: Colors.black87,
                        child: Text(
                          photo.uploadedAt.substring(0, 10),
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoWidget(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover);
    }
    // Return standard fallback network image if media root is absolute path
    final baseUrl = ApiClient().baseUrl;
    return Image.network(
      imageUrl.startsWith('/') ? '$baseUrl$imageUrl' : '$baseUrl/$imageUrl',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[900],
          child: const Icon(Icons.image, color: Colors.white24),
        );
      },
    );
  }

  // Simulated transparent file upload
  Future<void> _handleSimulatedUpload(String photoType, String notes) async {
    setState(() => _isLoading = true);
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/simulated_progress_photo_${Random().nextInt(10000)}.gif');
      // Transparent GIF 1x1 bytes
      final gifBytes = [
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
        0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x21, 0xf9, 0x04, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
        0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b
      ];
      await tempFile.writeAsBytes(gifBytes);

      final res = await _apiClient.uploadProgressPhoto(
        photoType: photoType,
        filePath: tempFile.path,
        memberId: widget.memberId,
        notes: notes.isNotEmpty ? notes : 'Logged via dashboard',
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress photo uploaded successfully!', style: TextStyle(color: Colors.black)), backgroundColor: AppColors.primaryFixed),
        );
        _refreshData();
      } else {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Upload failed'), backgroundColor: Colors.redAccent),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating simulation: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // TAB 4: CHARTS
  // ==========================================
  Widget _buildChartsTab() {
    if (_analytics == null || _analytics!.weightTrend.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Record at least two body measurements to display historical progress charts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryFixed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TrendChartCard(
              title: 'WEIGHT HISTORY (kg)',
              points: _analytics!.weightTrend,
              lineColor: AppColors.primaryFixed,
              areaColor: AppColors.primaryFixed,
            ),
            const SizedBox(height: 24),
            TrendChartCard(
              title: 'BODY FAT TREND (%)',
              points: _analytics!.bodyFatTrend,
              lineColor: const Color(0xFF4B8EFF),
              areaColor: const Color(0xFF4B8EFF),
            ),
            const SizedBox(height: 24),
            TrendChartCard(
              title: 'BMI EVOLUTION',
              points: _analytics!.bmiTrend,
              lineColor: Colors.purpleAccent,
              areaColor: Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DIALOGS & ACTION HANDLERS
  // ==========================================
  void _showAddGoalDialog() {
    final formKey = GlobalKey<FormState>();
    String selectedType = 'FAT_LOSS';
    double? targetWeight;
    double? targetBodyFat;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF201F1F),
              title: const Text('CREATE NEW GOAL', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        dropdownColor: const Color(0xFF201F1F),
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Goal Type', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                        items: const [
                          DropdownMenuItem(value: 'FAT_LOSS', child: Text('Fat Loss')),
                          DropdownMenuItem(value: 'MUSCLE_GAIN', child: Text('Muscle Gain')),
                          DropdownMenuItem(value: 'WEIGHT_GAIN', child: Text('Weight Gain')),
                          DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Target Weight (kg)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                        validator: (v) {
                          if (selectedType != 'MAINTENANCE' && (v == null || v.isEmpty)) {
                            return 'Target weight is required';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          if (val != null && val.isNotEmpty) targetWeight = double.tryParse(val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Target Body Fat %', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                        onSaved: (val) {
                          if (val != null && val.isNotEmpty) targetBodyFat = double.tryParse(val);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Target Date:', style: TextStyle(color: AppColors.onSurfaceVariant)),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                            child: Text(DateFormat('yyyy-MM-dd').format(selectedDate), style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant))),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      Navigator.pop(context);
                      setState(() => _isLoading = true);

                      final data = {
                        'goal_type': selectedType,
                        if (targetWeight != null) 'target_weight': targetWeight,
                        if (targetBodyFat != null) 'target_body_fat': targetBodyFat,
                        'target_date': DateFormat('yyyy-MM-dd').format(selectedDate),
                        if (widget.memberId != null) 'member': widget.memberId,
                      };

                      final res = await _apiClient.createGoal(data);
                      if (res.statusCode == 201 || res.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitness Goal created successfully.')));
                        _refreshData();
                      } else {
                        final body = jsonDecode(res.body);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Failed to create goal.')));
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
                  child: const Text('CREATE', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMeasurementModal() {
    final formKey = GlobalKey<FormState>();
    double weight = 0;
    double bodyFat = 0;
    double height = 0;
    double? chest, waist, hips, shoulders, biceps, notesVal;
    String recordedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF201F1F),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'RECORD NEW MEASUREMENTS',
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(labelText: 'Weight (kg)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              onSaved: (val) => weight = double.parse(val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(labelText: 'Body Fat %', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              onSaved: (val) => bodyFat = double.parse(val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(labelText: 'Height (cm)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              onSaved: (val) => height = double.parse(val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Date:', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                TextButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setModalState(() => recordedDate = DateFormat('yyyy-MM-dd').format(picked));
                                    }
                                  },
                                  child: Text(recordedDate, style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('TAPE CIRCUMFERENCES (OPTIONAL)', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(labelText: 'Chest (cm)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                              onSaved: (val) => chest = (val != null && val.isNotEmpty) ? double.tryParse(val) : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(labelText: 'Waist (cm)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                              onSaved: (val) => waist = (val != null && val.isNotEmpty) ? double.tryParse(val) : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(labelText: 'Hips (cm)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                              onSaved: (val) => hips = (val != null && val.isNotEmpty) ? double.tryParse(val) : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(labelText: 'Biceps (cm)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                              onSaved: (val) => biceps = (val != null && val.isNotEmpty) ? double.tryParse(val) : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            Navigator.pop(context);
                            setState(() => _isLoading = true);

                            final data = {
                              'weight_kg': weight,
                              'body_fat_percentage': bodyFat,
                              'height_cm': height,
                              'recorded_date': recordedDate,
                              if (chest != null) 'chest_cm': chest,
                              if (waist != null) 'waist_cm': waist,
                              if (hips != null) 'hips_cm': hips,
                              if (biceps != null) 'biceps_cm': biceps,
                              if (widget.memberId != null) 'member': widget.memberId,
                            };

                            final res = await _apiClient.createMeasurement(data);
                            if (res.statusCode == 201 || res.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Measurements recorded successfully!')));
                              _refreshData();
                            } else {
                              final body = jsonDecode(res.body);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Failed to save measurements.')));
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryFixed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('SAVE LOGS', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPhotoUploadDialog() {
    final formKey = GlobalKey<FormState>();
    String selectedAngle = 'FRONT';
    String notes = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF201F1F),
              title: const Text('UPLOAD PROGRESS PHOTO', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedAngle,
                      dropdownColor: const Color(0xFF201F1F),
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Angle Mode', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      items: const [
                        DropdownMenuItem(value: 'FRONT', child: Text('Front Angle')),
                        DropdownMenuItem(value: 'SIDE', child: Text('Side Angle')),
                        DropdownMenuItem(value: 'BACK', child: Text('Back Angle')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedAngle = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      onSaved: (val) => notes = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Note: Simulating snapshot capture and uploading a high-resolution sample image.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant))),
                ElevatedButton(
                  onPressed: () {
                    formKey.currentState!.save();
                    Navigator.pop(context);
                    _handleSimulatedUpload(selectedAngle, notes);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
                  child: const Text('UPLOAD', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteMeasurement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        title: const Text('Delete Log?'),
        content: const Text('This will delete the logged measurements permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final res = await _apiClient.deleteMeasurement(id);
      if (res.statusCode == 200) {
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete measurement.')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteGoal(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        title: const Text('Delete Goal?'),
        content: const Text('Are you sure you want to delete this fitness goal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final res = await _apiClient.deleteGoal(id);
      if (res.statusCode == 200) {
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete goal.')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeletePhoto(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF201F1F),
        title: const Text('Delete Photo?'),
        content: const Text('This progress photo will be removed from your timeline.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final res = await _apiClient.deleteProgressPhoto(id);
      if (res.statusCode == 200) {
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete photo.')));
        setState(() => _isLoading = false);
      }
    }
  }
}

// ==========================================
// CUSTOM RENDERING CHART CARD
// ==========================================
class TrendChartCard extends StatelessWidget {
  final String title;
  final List<TrendPoint> points;
  final Color lineColor;
  final Color areaColor;

  const TrendChartCard({
    super.key,
    required this.title,
    required this.points,
    required this.lineColor,
    required this.areaColor,
  });

  @override
  Widget build(BuildContext context) {
    // Sort points chronologically for plotting
    final sortedPoints = List<TrendPoint>.from(points)..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: LineChartPainter(
                points: sortedPoints,
                lineColor: lineColor,
                areaColor: areaColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Draw bottom date legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sortedPoints.first.date.substring(5), style: const TextStyle(color: Colors.white38, fontSize: 10)),
              if (sortedPoints.length > 2)
                Text(sortedPoints[sortedPoints.length ~/ 2].date.substring(5), style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(sortedPoints.last.date.substring(5), style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<TrendPoint> points;
  final Color lineColor;
  final Color areaColor;

  LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.areaColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    // Find min/max values
    double minVal = points.map((p) => p.value).reduce(min);
    double maxVal = points.map((p) => p.value).reduce(max);
    // Give some padding at top and bottom
    if (maxVal == minVal) {
      maxVal += 10.0;
      minVal -= 10.0;
    } else {
      final range = maxVal - minVal;
      maxVal += range * 0.20;
      minVal -= range * 0.15;
    }
    if (minVal < 0) minVal = 0.0;

    final double xStep = points.length > 1 ? width / (points.length - 1) : width;

    final List<Offset> offsets = [];
    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double yRatio = (points[i].value - minVal) / (maxVal - minVal);
      final double y = height - (yRatio * height);
      offsets.add(Offset(x, y));
    }

    // Draw horizontal grid lines
    final Paint gridPaint = Paint()
      ..color = AppColors.white10
      ..strokeWidth = 1.0;
    for (int i = 1; i < 4; i++) {
      final double gridY = height * (i / 4.0);
      canvas.drawLine(Offset(0, gridY), Offset(width, gridY), gridPaint);
    }

    // Draw area path (gradient under the line)
    final Path areaPath = Path();
    areaPath.moveTo(0, height);
    for (int i = 0; i < offsets.length; i++) {
      areaPath.lineTo(offsets[i].dx, offsets[i].dy);
    }
    areaPath.lineTo(offsets.last.dx, height);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          areaColor.withOpacity(0.35),
          areaColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, width, height));
    canvas.drawPath(areaPath, areaPaint);

    // Draw trend line
    final Path linePath = Path();
    linePath.moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      linePath.lineTo(offsets[i].dx, offsets[i].dy);
    }

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw data points & values
    final Paint pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final Paint pointBorder = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < offsets.length; i++) {
      canvas.drawCircle(offsets[i], 5.0, pointPaint);
      canvas.drawCircle(offsets[i], 5.0, pointBorder);

      // Draw value label above point
      final textSpan = TextSpan(
        text: points[i].value.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offsets[i].dx - textPainter.width / 2,
          offsets[i].dy - 18,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => true;
}
