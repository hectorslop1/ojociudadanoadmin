import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';

class TechnicianModel extends Technician {
  const TechnicianModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.profileImageUrl,
    required super.specialties,
    required super.isActive,
    required super.currentWorkload,
    required super.averageResolutionTime,
    required super.rating,
    super.assignedReports,
    super.lastKnownLatitude,
    super.lastKnownLongitude,
    super.isAvailable = true,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      specialties: _specialtiesFromJson(json['specialties']),
      isActive: json['is_active'],
      currentWorkload: json['current_workload'],
      averageResolutionTime: json['average_resolution_time'].toDouble(),
      rating: json['rating']?.toDouble() ?? 0.0,
      lastKnownLatitude: json['last_known_latitude']?.toDouble(),
      lastKnownLongitude: json['last_known_longitude']?.toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'specialties': specialties,
      'is_active': isActive,
      'current_workload': currentWorkload,
      'average_resolution_time': averageResolutionTime,
      'rating': rating,
      'last_known_latitude': lastKnownLatitude,
      'last_known_longitude': lastKnownLongitude,
      'is_available': isAvailable,
    };
  }

  static List<String> _specialtiesFromJson(List<dynamic> specialties) {
    return specialties.map((specialty) => specialty.toString()).toList();
  }

  // Ya no necesitamos este método porque ahora specialties es List<String>
}
