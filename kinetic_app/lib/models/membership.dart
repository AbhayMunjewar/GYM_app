import 'membership_plan.dart';

class Membership {
  final String id;
  final String? memberName;
  final String? memberEmail;
  final MembershipPlan? planDetails;
  final String startDate;
  final String endDate;
  final String status;
  final String? notes;

  Membership({
    required this.id,
    this.memberName,
    this.memberEmail,
    this.planDetails,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.notes,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'],
      memberName: json['member_name'],
      memberEmail: json['member_email'],
      planDetails: json['plan_details'] != null ? MembershipPlan.fromJson(json['plan_details']) : null,
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      notes: json['notes'],
    );
  }
}
