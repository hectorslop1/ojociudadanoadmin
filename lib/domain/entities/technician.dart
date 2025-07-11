import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class Technician extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final List<ReportCategory> specialties;
  final bool isActive;
  final int currentWorkload;
  final double averageResolutionTime; // en horas
  final double satisfactionRating; // 0-5

  const Technician({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.specialties,
    required this.isActive,
    required this.currentWorkload,
    required this.averageResolutionTime,
    required this.satisfactionRating,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    profileImageUrl,
    specialties,
    isActive,
    currentWorkload,
    averageResolutionTime,
    satisfactionRating,
  ];

  Technician copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    List<ReportCategory>? specialties,
    bool? isActive,
    int? currentWorkload,
    double? averageResolutionTime,
    double? satisfactionRating,
  }) {
    return Technician(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specialties: specialties ?? this.specialties,
      isActive: isActive ?? this.isActive,
      currentWorkload: currentWorkload ?? this.currentWorkload,
      averageResolutionTime: averageResolutionTime ?? this.averageResolutionTime,
      satisfactionRating: satisfactionRating ?? this.satisfactionRating,
    );
  }
}
