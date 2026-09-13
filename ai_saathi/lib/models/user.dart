class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String preferredLanguage;
  final String role;
  final String? shopName;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.preferredLanguage = 'en',
    this.role = 'artisan',
    this.shopName,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      preferredLanguage: json['preferred_language'] ?? 'en',
      role: json['role'] ?? 'artisan',
      shopName: json['shop_name'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'preferred_language': preferredLanguage,
      'role': role,
      'shop_name': shopName,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? preferredLanguage,
    String? role,
    String? shopName,
    String? location,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      role: role ?? this.role,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isBuyer => role == 'buyer';
  bool get isArtisan => !isBuyer;
}
