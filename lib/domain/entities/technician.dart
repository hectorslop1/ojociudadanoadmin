import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class Technician extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final List<String> specialties; // Cambiado a String para mayor flexibilidad
  final bool isActive;
  final int currentWorkload;
  final double averageResolutionTime; // en horas
  final double rating; // 0-5, satisfacción del cliente
  final List<Report>? assignedReports; // Reportes asignados actualmente
  final double? lastKnownLatitude; // Última ubicación conocida
  final double? lastKnownLongitude;
  final bool isAvailable; // Disponible para asignaciones

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
    required this.rating,
    this.assignedReports,
    this.lastKnownLatitude,
    this.lastKnownLongitude,
    this.isAvailable = true,
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
    rating,
    assignedReports,
    lastKnownLatitude,
    lastKnownLongitude,
    isAvailable,
  ];

  Technician copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    List<String>? specialties,
    bool? isActive,
    int? currentWorkload,
    double? averageResolutionTime,
    double? rating,
    List<Report>? assignedReports,
    double? lastKnownLatitude,
    double? lastKnownLongitude,
    bool? isAvailable,
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
      rating: rating ?? this.rating,
      assignedReports: assignedReports ?? this.assignedReports,
      lastKnownLatitude: lastKnownLatitude ?? this.lastKnownLatitude,
      lastKnownLongitude: lastKnownLongitude ?? this.lastKnownLongitude,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
