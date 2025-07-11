import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Definir color y texto según el estado
    Color color;
    String text;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case ReportStatus.pending:
        color = isDarkMode ? AppColors.warningDark : AppColors.warning;
        text = 'Pendiente';
        break;
      case ReportStatus.assigned:
        color = isDarkMode ? AppColors.infoDark : AppColors.info;
        text = 'Asignado';
        break;
      case ReportStatus.inProgress:
        color = isDarkMode ? AppColors.primaryDark : AppColors.primary;
        text = 'En Progreso';
        break;
      case ReportStatus.resolved:
        color = isDarkMode ? AppColors.successDark : AppColors.success;
        text = 'Resuelto';
        break;
      case ReportStatus.rejected:
        color = isDarkMode ? AppColors.errorDark : AppColors.error;
        text = 'Rechazado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForStatus(status),
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.hourglass_empty;
      case ReportStatus.assigned:
        return Icons.person_add;
      case ReportStatus.inProgress:
        return Icons.engineering;
      case ReportStatus.resolved:
        return Icons.check_circle;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }
}
