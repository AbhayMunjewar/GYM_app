class Member {
  final String id;
  final String? gymName;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? emergencyContact;
  final String? gender;
  final String? dateOfBirth;
  final double? heightCm;
  final double? weightKg;
  final String? address;
  final String? joinDate;
  final String status;
  final String? profileImage;
  final String? notes;
  final bool isActive;
  final bool isDeleted;
  final String? activePlanName;

  Member({
    required this.id,
    this.gymName,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.emergencyContact,
    this.gender,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.address,
    this.joinDate,
    required this.status,
    this.profileImage,
    this.notes,
    this.isActive = true,
    this.isDeleted = false,
    this.activePlanName,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id']?.toString() ?? '',
      gymName: json['gym_name'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      emergencyContact: json['emergency_contact'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      heightCm: json['height_cm'] != null ? double.tryParse(json['height_cm'].toString()) : null,
      weightKg: json['weight_kg'] != null ? double.tryParse(json['weight_kg'].toString()) : null,
      address: json['address'],
      joinDate: json['join_date'],
      status: json['status'] ?? 'ACTIVE',
      profileImage: json['profile_image'],
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      activePlanName: json['active_plan_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (address != null) 'address': address,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }
}
