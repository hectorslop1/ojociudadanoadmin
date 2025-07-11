import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

/// Utility class to provide consistent category icons, colors and names across the app
class CategoryUtils {
  /// Get the icon for a specific report category
  static IconData getIconForCategory(ReportCategory category) {
    switch (category) {
      case ReportCategory.lighting:
        return Icons.lightbulb_outline;
      case ReportCategory.roadRepair:
        return Icons.construction;
      case ReportCategory.garbageCollection:
        return Icons.delete_outline;
      case ReportCategory.waterLeaks:
        return Icons.water_drop_outlined;
      case ReportCategory.abandonedVehicles:
        return Icons.directions_car_outlined;
      case ReportCategory.noise:
        return Icons.volume_up_outlined;
      case ReportCategory.animalAbuse:
        return Icons.pets_outlined;
      case ReportCategory.insecurity:
        return Icons.security_outlined;
      case ReportCategory.stopSignsDamaged:
        return Icons.do_not_disturb_on_outlined;
      case ReportCategory.trafficLightsDamaged:
        return Icons.traffic_outlined;
      case ReportCategory.poorSignage:
        return Icons.signpost_outlined;
      case ReportCategory.genderEquity:
        return Icons.people_outline;
      case ReportCategory.disabilityRamps:
        return Icons.accessible_outlined;
      case ReportCategory.serviceComplaints:
        return Icons.support_agent_outlined;
      case ReportCategory.other:
        return Icons.help_outline;
    }
  }

  /// Get the color for a specific report category
  static Color getColorForCategory(ReportCategory category, {BuildContext? context}) {
    switch (category) {
      case ReportCategory.lighting:
        if (context != null && Theme.of(context).brightness == Brightness.dark) {
          return AppColors.primaryDark;
        }
        return AppColors.primary;
      case ReportCategory.roadRepair:
        return Colors.grey[700]!; // Color gris más oscuro para mejor visibilidad
      case ReportCategory.garbageCollection:
        return AppColors.success;
      case ReportCategory.waterLeaks:
        return AppColors.info;
      case ReportCategory.abandonedVehicles:
        return Colors.blueGrey;
      case ReportCategory.noise:
        return Colors.purple;
      case ReportCategory.animalAbuse:
        return Colors.orange;
      case ReportCategory.insecurity:
        return AppColors.error;
      case ReportCategory.stopSignsDamaged:
        return Colors.redAccent;
      case ReportCategory.trafficLightsDamaged:
        return Colors.amber;
      case ReportCategory.poorSignage:
        return Colors.indigo;
      case ReportCategory.genderEquity:
        return Colors.pink;
      case ReportCategory.disabilityRamps:
        return Colors.teal;
      case ReportCategory.serviceComplaints:
        return Colors.deepOrange;
      case ReportCategory.other:
        return Colors.grey;
    }
  }

  /// Get the name for a specific report category
  static String getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.lighting:
        return 'Alumbrado';
      case ReportCategory.roadRepair:
        return 'Reparación de Calles';
      case ReportCategory.garbageCollection:
        return 'Recolección de Basura';
      case ReportCategory.waterLeaks:
        return 'Fugas de Agua';
      case ReportCategory.abandonedVehicles:
        return 'Vehículos Abandonados';
      case ReportCategory.noise:
        return 'Ruido';
      case ReportCategory.animalAbuse:
        return 'Maltrato Animal';
      case ReportCategory.insecurity:
        return 'Inseguridad';
      case ReportCategory.stopSignsDamaged:
        return 'Señales de Alto Dañadas';
      case ReportCategory.trafficLightsDamaged:
        return 'Semáforos Dañados';
      case ReportCategory.poorSignage:
        return 'Señalización Deficiente';
      case ReportCategory.genderEquity:
        return 'Equidad de Género';
      case ReportCategory.disabilityRamps:
        return 'Rampas para Discapacitados';
      case ReportCategory.serviceComplaints:
        return 'Quejas de Servicio';
      case ReportCategory.other:
        return 'Otros';
    }
  }
}
