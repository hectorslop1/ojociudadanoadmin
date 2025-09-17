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
      case 'road_repair':
        return ReportCategory.roadRepair;
      case 'garbage_collection':
        return ReportCategory.garbageCollection;
      case 'street_improvement':
        return ReportCategory.streetImprovement;
      // Handle legacy categories by mapping them to the new ones
      case 'lighting':
      case 'poor_signage':
      case 'traffic_lights_damaged':
      case 'stop_signs_damaged':
        return ReportCategory.streetImprovement;
      case 'water_leaks':
      case 'abandoned_vehicles':
      case 'noise':
      case 'animal_abuse':
      case 'insecurity':
      case 'gender_equity':
      case 'disability_ramps':
      case 'service_complaints':
      case 'other':
      default:
        return ReportCategory.garbageCollection;
    }
  }

  static String _categoryToString(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return 'road_repair';
      case ReportCategory.garbageCollection:
        return 'garbage_collection';
      case ReportCategory.streetImprovement:
        return 'street_improvement';
    }
  }
}
