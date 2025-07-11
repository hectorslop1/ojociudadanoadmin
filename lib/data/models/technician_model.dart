import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
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
    required super.satisfactionRating,
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
      satisfactionRating: json['satisfaction_rating'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'specialties': _specialtiesToJson(specialties),
      'is_active': isActive,
      'current_workload': currentWorkload,
      'average_resolution_time': averageResolutionTime,
      'satisfaction_rating': satisfactionRating,
    };
  }

  static List<ReportCategory> _specialtiesFromJson(List<dynamic> specialties) {
    return specialties.map((specialty) {
      switch (specialty) {
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
        default:
          return ReportCategory.other;
      }
    }).toList();
  }

  static List<String> _specialtiesToJson(List<ReportCategory> specialties) {
    return specialties.map((specialty) {
      switch (specialty) {
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
    }).toList();
  }
}
