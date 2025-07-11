import 'package:ojo_ciudadano_admin/domain/entities/citizen.dart';

class CitizenModel extends Citizen {
  const CitizenModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.profileImageUrl,
    required super.registeredAt,
  });

  factory CitizenModel.fromJson(Map<String, dynamic> json) {
    return CitizenModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      registeredAt: DateTime.parse(json['registered_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'registered_at': registeredAt.toIso8601String(),
    };
  }
}
