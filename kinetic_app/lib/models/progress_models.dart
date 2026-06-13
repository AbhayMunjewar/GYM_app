class ProgressMeasurement {
  final String id;
  final int memberId;
  final String memberName;
  final String? trainerId;
  final String? trainerName;
  final double weightKg;
  final double bodyFatPercentage;
  final double? bmi;
  final double heightCm;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? shouldersCm;
  final double? bicepsCm;
  final double? forearmsCm;
  final double? thighsCm;
  final double? calvesCm;
  final double? neckCm;
  final String? notes;
  final String recordedDate;

  ProgressMeasurement({
    required this.id,
    required this.memberId,
    required this.memberName,
    this.trainerId,
    this.trainerName,
    required this.weightKg,
    required this.bodyFatPercentage,
    this.bmi,
    required this.heightCm,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.shouldersCm,
    this.bicepsCm,
    this.forearmsCm,
    this.thighsCm,
    this.calvesCm,
    this.neckCm,
    this.notes,
    required this.recordedDate,
  });

  factory ProgressMeasurement.fromJson(Map<String, dynamic> json) {
    return ProgressMeasurement(
      id: json['id']?.toString() ?? '',
      memberId: json['member'] is int ? json['member'] : int.tryParse(json['member']?.toString() ?? '') ?? 0,
      memberName: json['member_name'] ?? '',
      trainerId: json['trainer']?.toString(),
      trainerName: json['trainer_name'],
      weightKg: double.tryParse(json['weight_kg']?.toString() ?? '') ?? 0.0,
      bodyFatPercentage: double.tryParse(json['body_fat_percentage']?.toString() ?? '') ?? 0.0,
      bmi: double.tryParse(json['bmi']?.toString() ?? ''),
      heightCm: double.tryParse(json['height_cm']?.toString() ?? '') ?? 0.0,
      chestCm: double.tryParse(json['chest_cm']?.toString() ?? ''),
      waistCm: double.tryParse(json['waist_cm']?.toString() ?? ''),
      hipsCm: double.tryParse(json['hips_cm']?.toString() ?? ''),
      shouldersCm: double.tryParse(json['shoulders_cm']?.toString() ?? ''),
      bicepsCm: double.tryParse(json['biceps_cm']?.toString() ?? ''),
      forearmsCm: double.tryParse(json['forearms_cm']?.toString() ?? ''),
      thighsCm: double.tryParse(json['thighs_cm']?.toString() ?? ''),
      calvesCm: double.tryParse(json['calves_cm']?.toString() ?? ''),
      neckCm: double.tryParse(json['neck_cm']?.toString() ?? ''),
      notes: json['notes'],
      recordedDate: json['recorded_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight_kg': weightKg,
      'body_fat_percentage': bodyFatPercentage,
      'height_cm': heightCm,
      if (chestCm != null) 'chest_cm': chestCm,
      if (waistCm != null) 'waist_cm': waistCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (shouldersCm != null) 'shoulders_cm': shouldersCm,
      if (bicepsCm != null) 'biceps_cm': bicepsCm,
      if (forearmsCm != null) 'forearms_cm': forearmsCm,
      if (thighsCm != null) 'thighs_cm': thighsCm,
      if (calvesCm != null) 'calves_cm': calvesCm,
      if (neckCm != null) 'neck_cm': neckCm,
      if (notes != null) 'notes': notes,
      'recorded_date': recordedDate,
    };
  }
}

class ProgressPhoto {
  final String id;
  final int memberId;
  final String memberName;
  final int? uploadedBy;
  final String photoType;
  final String image;
  final String? notes;
  final String uploadedAt;

  ProgressPhoto({
    required this.id,
    required this.memberId,
    required this.memberName,
    this.uploadedBy,
    required this.photoType,
    required this.image,
    this.notes,
    required this.uploadedAt,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id']?.toString() ?? '',
      memberId: json['member'] is int ? json['member'] : int.tryParse(json['member']?.toString() ?? '') ?? 0,
      memberName: json['member_name'] ?? '',
      uploadedBy: json['uploaded_by'] is int ? json['uploaded_by'] : int.tryParse(json['uploaded_by']?.toString() ?? ''),
      photoType: json['photo_type'] ?? 'FRONT',
      image: json['image'] ?? '',
      notes: json['notes'],
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}

class FitnessGoal {
  final String id;
  final int memberId;
  final String memberName;
  final String goalType;
  final double? startingWeight;
  final double? startingBodyFat;
  final double? targetWeight;
  final double? targetBodyFat;
  final String targetDate;
  final double currentProgressPercentage;
  final String status;
  final String createdAt;

  FitnessGoal({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.goalType,
    this.startingWeight,
    this.startingBodyFat,
    this.targetWeight,
    this.targetBodyFat,
    required this.targetDate,
    required this.currentProgressPercentage,
    required this.status,
    required this.createdAt,
  });

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      id: json['id']?.toString() ?? '',
      memberId: json['member'] is int ? json['member'] : int.tryParse(json['member']?.toString() ?? '') ?? 0,
      memberName: json['member_name'] ?? '',
      goalType: json['goal_type'] ?? 'FAT_LOSS',
      startingWeight: double.tryParse(json['starting_weight']?.toString() ?? ''),
      startingBodyFat: double.tryParse(json['starting_body_fat']?.toString() ?? ''),
      targetWeight: double.tryParse(json['target_weight']?.toString() ?? ''),
      targetBodyFat: double.tryParse(json['target_body_fat']?.toString() ?? ''),
      targetDate: json['target_date'] ?? '',
      currentProgressPercentage: double.tryParse(json['current_progress_percentage']?.toString() ?? '') ?? 0.0,
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ProgressMilestone {
  final String id;
  final int memberId;
  final String memberName;
  final String milestoneName;
  final String achievedDate;
  final String achievementValue;

  ProgressMilestone({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.milestoneName,
    required this.achievedDate,
    required this.achievementValue,
  });

  factory ProgressMilestone.fromJson(Map<String, dynamic> json) {
    return ProgressMilestone(
      id: json['id']?.toString() ?? '',
      memberId: json['member'] is int ? json['member'] : int.tryParse(json['member']?.toString() ?? '') ?? 0,
      memberName: json['member_name'] ?? '',
      milestoneName: json['milestone_name'] ?? '',
      achievedDate: json['achieved_date'] ?? '',
      achievementValue: json['achievement_value'] ?? '',
    );
  }
}

class TrendPoint {
  final String date;
  final double value;

  TrendPoint({required this.date, required this.value});

  factory TrendPoint.fromJson(Map<String, dynamic> json, String key) {
    return TrendPoint(
      date: json['date'] ?? '',
      value: double.tryParse(json[key]?.toString() ?? '') ?? 0.0,
    );
  }
}

class TimelineEvent {
  final String date;
  final String type;
  final String title;
  final String description;

  TimelineEvent({
    required this.date,
    required this.type,
    required this.title,
    required this.description,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      date: json['date'] ?? '',
      type: json['type'] ?? 'MEASUREMENT',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class ProgressAnalytics {
  final List<TrendPoint> weightTrend;
  final List<TrendPoint> bodyFatTrend;
  final List<TrendPoint> bmiTrend;
  final Map<String, List<TrendPoint>> measurementTrends;
  final Map<String, dynamic> transformationSummary;
  final Map<String, dynamic> monthOverMonth;
  final List<TimelineEvent> timeline;
  final int activeGoalsCount;
  final int achievedGoalsCount;

  ProgressAnalytics({
    required this.weightTrend,
    required this.bodyFatTrend,
    required this.bmiTrend,
    required this.measurementTrends,
    required this.transformationSummary,
    required this.monthOverMonth,
    required this.timeline,
    required this.activeGoalsCount,
    required this.achievedGoalsCount,
  });

  factory ProgressAnalytics.fromJson(Map<String, dynamic> json) {
    var wt = json['weight_trend'] as List? ?? [];
    var bft = json['body_fat_trend'] as List? ?? [];
    var bmit = json['bmi_trend'] as List? ?? [];
    var tl = json['timeline'] as List? ?? [];
    
    var mTrendsRaw = json['measurement_trends'] as Map<String, dynamic>? ?? {};
    Map<String, List<TrendPoint>> mt = {};
    mTrendsRaw.forEach((k, v) {
      if (v is List) {
        mt[k] = v.map((item) => TrendPoint(
          date: item['date'] ?? '',
          value: double.tryParse(item['value']?.toString() ?? '') ?? 0.0,
        )).toList();
      }
    });

    return ProgressAnalytics(
      weightTrend: wt.map((item) => TrendPoint.fromJson(item, 'weight_kg')).toList(),
      bodyFatTrend: bft.map((item) => TrendPoint.fromJson(item, 'body_fat_percentage')).toList(),
      bmiTrend: bmit.map((item) => TrendPoint.fromJson(item, 'bmi')).toList(),
      measurementTrends: mt,
      transformationSummary: json['transformation_summary'] ?? {},
      monthOverMonth: json['month_over_month'] ?? {},
      timeline: tl.map((item) => TimelineEvent.fromJson(item)).toList(),
      activeGoalsCount: json['active_goals_count'] ?? 0,
      achievedGoalsCount: json['achieved_goals_count'] ?? 0,
    );
  }
}

class CompareDifferences {
  final double weightDiff;
  final double bodyFatDiff;
  final double bmiDiff;
  final double chestDiff;
  final double waistDiff;
  final double hipsDiff;
  final double shouldersDiff;
  final double bicepsDiff;
  final double thighsDiff;
  final double calvesDiff;

  CompareDifferences({
    required this.weightDiff,
    required this.bodyFatDiff,
    required this.bmiDiff,
    required this.chestDiff,
    required this.waistDiff,
    required this.hipsDiff,
    required this.shouldersDiff,
    required this.bicepsDiff,
    required this.thighsDiff,
    required this.calvesDiff,
  });

  factory CompareDifferences.fromJson(Map<String, dynamic> json) {
    return CompareDifferences(
      weightDiff: double.tryParse(json['weight_diff']?.toString() ?? '') ?? 0.0,
      bodyFatDiff: double.tryParse(json['body_fat_diff']?.toString() ?? '') ?? 0.0,
      bmiDiff: double.tryParse(json['bmi_diff']?.toString() ?? '') ?? 0.0,
      chestDiff: double.tryParse(json['chest_diff']?.toString() ?? '') ?? 0.0,
      waistDiff: double.tryParse(json['waist_diff']?.toString() ?? '') ?? 0.0,
      hipsDiff: double.tryParse(json['hips_diff']?.toString() ?? '') ?? 0.0,
      shouldersDiff: double.tryParse(json['shoulders_diff']?.toString() ?? '') ?? 0.0,
      bicepsDiff: double.tryParse(json['biceps_diff']?.toString() ?? '') ?? 0.0,
      thighsDiff: double.tryParse(json['thighs_diff']?.toString() ?? '') ?? 0.0,
      calvesDiff: double.tryParse(json['calves_diff']?.toString() ?? '') ?? 0.0,
    );
  }
}

class CompareResults {
  final String beforeDate;
  final String afterDate;
  final double beforeWeight;
  final double afterWeight;
  final double beforeBodyFat;
  final double afterBodyFat;
  final CompareDifferences differences;

  CompareResults({
    required this.beforeDate,
    required this.afterDate,
    required this.beforeWeight,
    required this.afterWeight,
    required this.beforeBodyFat,
    required this.afterBodyFat,
    required this.differences,
  });

  factory CompareResults.fromJson(Map<String, dynamic> json) {
    return CompareResults(
      beforeDate: json['before_date'] ?? '',
      afterDate: json['after_date'] ?? '',
      beforeWeight: double.tryParse(json['before_weight']?.toString() ?? '') ?? 0.0,
      afterWeight: double.tryParse(json['after_weight']?.toString() ?? '') ?? 0.0,
      beforeBodyFat: double.tryParse(json['before_body_fat']?.toString() ?? '') ?? 0.0,
      afterBodyFat: double.tryParse(json['after_body_fat']?.toString() ?? '') ?? 0.0,
      differences: CompareDifferences.fromJson(json['differences'] ?? {}),
    );
  }
}
