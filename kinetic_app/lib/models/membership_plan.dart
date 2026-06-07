class MembershipPlan {
  final String id;
  final String planName;
  final String? description;
  final int durationDays;
  final String price;
  final bool isActive;

  MembershipPlan({
    required this.id,
    required this.planName,
    this.description,
    required this.durationDays,
    required this.price,
    required this.isActive,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'],
      planName: json['plan_name'],
      description: json['description'],
      durationDays: json['duration_days'],
      price: json['price'].toString(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'description': description,
      'duration_days': durationDays,
      'price': price,
      'is_active': isActive,
    };
  }
}
