import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

/// Utility class to provide consistent category icons, colors and names across the app
class CategoryUtils {
  /// Get the icon for a specific report category
  static IconData getIconForCategory(ReportCategory category) {
    switch (category) {
      case ReportCategory.garbageCollection:
        return Icons.delete_outline;
      case ReportCategory.streetImprovement:
        return Icons.home_repair_service;
      case ReportCategory.roadRepair:
        return Icons.construction;
    }
  }

  /// Get the color for a specific report category
  static Color getColorForCategory(ReportCategory category, {BuildContext? context}) {
    switch (category) {
      case ReportCategory.garbageCollection:
        // Verde para Recolección de basura
        return context != null && Theme.of(context).brightness == Brightness.dark
            ? AppColors.successDark
            : AppColors.success;
      case ReportCategory.streetImprovement:
        // Azul para Mejoramiento de la Imagen Urbana
        return context != null && Theme.of(context).brightness == Brightness.dark
            ? AppColors.infoDark
            : AppColors.info;
      case ReportCategory.roadRepair:
        // Naranja para Bacheo
        return context != null && Theme.of(context).brightness == Brightness.dark
            ? AppColors.warningDark
            : AppColors.warning;
    }
  }

  /// Get the name for a specific report category
  static String getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.garbageCollection:
        return 'Recolección de Basura';
      case ReportCategory.streetImprovement:
        return 'Mejoramiento de la Imagen Urbana';
      case ReportCategory.roadRepair:
        return 'Bacheo';
    }
  }
}
