class WorkoutSession {
  final String id;
  final String gymId;
  final String trainerId;
  final String trainerName;
  final String title;
  final String? description;
  final String sessionDate;
  final String startTime;
  final String endTime;
  final int maxCapacity;
  final int bookedCount;
  final bool isDeleted;

  WorkoutSession({
    required this.id,
    required this.gymId,
    required this.trainerId,
    required this.trainerName,
    required this.title,
    this.description,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.bookedCount,
    required this.isDeleted,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id']?.toString() ?? '',
      gymId: json['gym']?.toString() ?? '',
      trainerId: json['trainer']?.toString() ?? '',
      trainerName: json['trainer_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      sessionDate: json['session_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      maxCapacity: json['max_capacity'] ?? 10,
      bookedCount: json['booked_count'] ?? 0,
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym': gymId,
      'trainer': trainerId,
      'title': title,
      if (description != null) 'description': description,
      'session_date': sessionDate,
      'start_time': startTime,
      'end_time': endTime,
      'max_capacity': maxCapacity,
      'is_deleted': isDeleted,
    };
  }
}

class SessionBooking {
  final String id;
  final String sessionId;
  final String? sessionTitle;
  final String? sessionDate;
  final String? sessionStartTime;
  final String? sessionEndTime;
  final String? trainerName;
  final int memberId;
  final String? memberName;
  final String status;
  final String bookedAt;

  SessionBooking({
    required this.id,
    required this.sessionId,
    this.sessionTitle,
    this.sessionDate,
    this.sessionStartTime,
    this.sessionEndTime,
    this.trainerName,
    required this.memberId,
    this.memberName,
    required this.status,
    required this.bookedAt,
  });

  factory SessionBooking.fromJson(Map<String, dynamic> json) {
    return SessionBooking(
      id: json['id']?.toString() ?? '',
      sessionId: json['session']?.toString() ?? '',
      sessionTitle: json['session_title'],
      sessionDate: json['session_date'],
      sessionStartTime: json['session_start_time'],
      sessionEndTime: json['session_end_time'],
      trainerName: json['trainer_name'],
      memberId: json['member'] is int ? json['member'] : int.tryParse(json['member']?.toString() ?? '') ?? 0,
      memberName: json['member_name'],
      status: json['status'] ?? 'booked',
      bookedAt: json['booked_at'] ?? '',
    );
  }
}
