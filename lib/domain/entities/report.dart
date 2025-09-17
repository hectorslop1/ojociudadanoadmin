import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/domain/entities/citizen.dart';
import 'package:ojo_ciudadano_admin/domain/entities/delegation.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';

enum ReportStatus {
  pending,
  assigned,
  inProgress,
  resolved,
  rejected
}

enum ReportCategory {
  garbageCollection, // Recolección de basura
  streetImprovement, // Mejoramiento de calles
  roadRepair        // Bacheo
}

class Report extends Equatable {
  final String id;
  final String title;
  final ReportCategory category;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> evidenceUrls;
  final DateTime createdAt;
  final Citizen citizen;
  final ReportStatus status;
  final Technician? assignedTechnician;
  final DateTime? assignedAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final Delegation? delegation;
  final int? priority; // 1-5, donde 5 es la prioridad más alta

  const Report({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.evidenceUrls,
    required this.createdAt,
    required this.citizen,
    required this.status,
    this.assignedTechnician,
    this.assignedAt,
    this.resolvedAt,
    this.resolutionNotes,
    this.delegation,
    this.priority,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    description,
    latitude,
    longitude,
    address,
    evidenceUrls,
    createdAt,
    citizen,
    status,
    assignedTechnician,
    assignedAt,
    resolvedAt,
    resolutionNotes,
    delegation,
    priority,
  ];

  Report copyWith({
    String? id,
    String? title,
    ReportCategory? category,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? evidenceUrls,
    DateTime? createdAt,
    Citizen? citizen,
    ReportStatus? status,
    Technician? assignedTechnician,
    DateTime? assignedAt,
    DateTime? resolvedAt,
    String? resolutionNotes,
    Delegation? delegation,
    int? priority,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      createdAt: createdAt ?? this.createdAt,
      citizen: citizen ?? this.citizen,
      status: status ?? this.status,
      assignedTechnician: assignedTechnician ?? this.assignedTechnician,
      assignedAt: assignedAt ?? this.assignedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      delegation: delegation ?? this.delegation,
      priority: priority ?? this.priority,
    );
  }
}
