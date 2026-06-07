class Gym {
  final String id;
  final String gymName;
  final String owner;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String contactNumber;
  final String email;
  final String? logo;
  final String? description;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Gym({
    required this.id,
    required this.gymName,
    required this.owner,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactNumber,
    required this.email,
    this.logo,
    this.description,
    required this.isActive,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'] ?? '',
      gymName: json['gym_name'] ?? '',
      owner: json['owner']?.toString() ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      logo: json['logo'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gym_name': gymName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contact_number': contactNumber,
      'email': email,
      'description': description,
    };
  }
}
