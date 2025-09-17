import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

/// Clase utilitaria para estandarizar la presentación de los estados de reportes
/// en toda la aplicación.
class StatusUtils {
  /// Obtiene el nombre estandarizado para un estado de reporte
  static String getStatusName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.assigned:
        return 'Asignado';
      case ReportStatus.inProgress:
        return 'En Proceso';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.rejected:
        return 'Rechazado';
    }
  }

  /// Obtiene el icono estandarizado para un estado de reporte
  static IconData getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.hourglass_empty;
      case ReportStatus.assigned:
        return Icons.assignment_ind_outlined;
      case ReportStatus.inProgress:
        return Icons.engineering;
      case ReportStatus.resolved:
        return Icons.check_circle;
      case ReportStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  /// Obtiene el color principal estandarizado para un estado de reporte
  static Color getStatusColor(ReportStatus status, {BuildContext? context}) {
    switch (status) {
      case ReportStatus.pending:
        return const Color(0xFFFFC107); // Amarillo
      case ReportStatus.assigned:
        return const Color(0xFFFFA000); // Ámbar
      case ReportStatus.inProgress:
        return const Color(0xFF2196F3); // Azul
      case ReportStatus.resolved:
        return const Color(0xFF4CAF50); // Verde
      case ReportStatus.rejected:
        return const Color(0xFFE53935); // Rojo
    }
  }

  /// Obtiene el color de fondo estandarizado para un estado de reporte
  static Color getStatusBackgroundColor(ReportStatus status) {
    return getStatusColor(status).withOpacity(0.15);
  }

  /// Obtiene el color de texto estandarizado para un estado de reporte
  static Color getStatusTextColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return const Color(0xFF8F6400); // Amarillo oscuro para mejor contraste
      case ReportStatus.assigned:
        return const Color(0xFFF57C00); // Naranja oscuro
      case ReportStatus.inProgress:
        return const Color(0xFF1976D2); // Azul oscuro
      case ReportStatus.resolved:
        return const Color(0xFF388E3C); // Verde oscuro
      case ReportStatus.rejected:
        return const Color(0xFFD32F2F); // Rojo oscuro
    }
  }
}
