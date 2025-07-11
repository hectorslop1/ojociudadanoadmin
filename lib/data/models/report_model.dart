import 'package:ojo_ciudadano_admin/data/models/citizen_model.dart';
import 'package:ojo_ciudadano_admin/data/models/technician_model.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.title,
    required super.category,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.evidenceUrls,
    required super.createdAt,
    required CitizenModel super.citizen,
    required super.status,
    TechnicianModel? super.assignedTechnician,
    super.assignedAt,
    super.resolvedAt,
    super.resolutionNotes,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      category: _categoryFromString(json['category']),
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      evidenceUrls: List<String>.from(json['evidence_urls']),
      createdAt: DateTime.parse(json['created_at']),
      citizen: CitizenModel.fromJson(json['citizen']),
      status: _statusFromString(json['status']),
      assignedTechnician: json['assigned_technician'] != null
          ? TechnicianModel.fromJson(json['assigned_technician'])
          : null,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      resolutionNotes: json['resolution_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': _categoryToString(category),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'evidence_urls': evidenceUrls,
      'created_at': createdAt.toIso8601String(),
      'citizen': (citizen as CitizenModel).toJson(),
      'status': _statusToString(status),
      'assigned_technician': assignedTechnician != null
          ? (assignedTechnician as TechnicianModel).toJson()
          : null,
      'assigned_at': assignedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolution_notes': resolutionNotes,
    };
  }

  static ReportStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'assigned':
        return ReportStatus.assigned;
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  static String _statusToString(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.assigned:
        return 'assigned';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  static ReportCategory _categoryFromString(String category) {
    switch (category) {
      case 'lighting':
        return ReportCategory.lighting;
      case 'road_repair':
        return ReportCategory.roadRepair;
      case 'garbage_collection':
        return ReportCategory.garbageCollection;
      case 'water_leaks':
        return ReportCategory.waterLeaks;
      case 'abandoned_vehicles':
        return ReportCategory.abandonedVehicles;
      case 'noise':
        return ReportCategory.noise;
      case 'animal_abuse':
        return ReportCategory.animalAbuse;
      case 'insecurity':
        return ReportCategory.insecurity;
      case 'stop_signs_damaged':
        return ReportCategory.stopSignsDamaged;
      case 'traffic_lights_damaged':
        return ReportCategory.trafficLightsDamaged;
      case 'poor_signage':
        return ReportCategory.poorSignage;
      case 'gender_equity':
        return ReportCategory.genderEquity;
      case 'disability_ramps':
        return ReportCategory.disabilityRamps;
      case 'service_complaints':
        return ReportCategory.serviceComplaints;
      case 'other':
        return ReportCategory.other;
      default:
        return ReportCategory.other;
    }
  }

  static String _categoryToString(ReportCategory category) {
    switch (category) {
      case ReportCategory.lighting:
        return 'lighting';
      case ReportCategory.roadRepair:
        return 'road_repair';
      case ReportCategory.garbageCollection:
        return 'garbage_collection';
      case ReportCategory.waterLeaks:
        return 'water_leaks';
      case ReportCategory.abandonedVehicles:
        return 'abandoned_vehicles';
      case ReportCategory.noise:
        return 'noise';
      case ReportCategory.animalAbuse:
        return 'animal_abuse';
      case ReportCategory.insecurity:
        return 'insecurity';
      case ReportCategory.stopSignsDamaged:
        return 'stop_signs_damaged';
      case ReportCategory.trafficLightsDamaged:
        return 'traffic_lights_damaged';
      case ReportCategory.poorSignage:
        return 'poor_signage';
      case ReportCategory.genderEquity:
        return 'gender_equity';
      case ReportCategory.disabilityRamps:
        return 'disability_ramps';
      case ReportCategory.serviceComplaints:
        return 'service_complaints';
      case ReportCategory.other:
        return 'other';
    }
  }
}
