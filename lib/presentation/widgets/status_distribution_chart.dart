import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'dart:math';

class StatusDistributionChart extends StatelessWidget {
  final Map<ReportStatus, int> reportsByStatus;

  const StatusDistributionChart({
    super.key,
    required this.reportsByStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el total de reportes
    final total = reportsByStatus.values.fold(0, (sum, count) => sum + count);
    
    // Definir colores para cada estado
    final statusColors = {
      ReportStatus.pending: AppColors.warning,
      ReportStatus.assigned: AppColors.info,
      ReportStatus.inProgress: Theme.of(context).brightness == Brightness.light
          ? AppColors.primary
          : AppColors.primaryDark,
      ReportStatus.resolved: AppColors.success,
      ReportStatus.rejected: AppColors.error,
    };
    
    // Definir nombres para cada estado
    final statusNames = {
      ReportStatus.pending: 'Pendientes',
      ReportStatus.assigned: 'Asignados',
      ReportStatus.inProgress: 'En Progreso',
      ReportStatus.resolved: 'Resueltos',
      ReportStatus.rejected: 'Rechazados',
    };
    
    // Ordenar los estados para asegurar que aparezcan en un orden consistente
    final sortedStatuses = [
      ReportStatus.pending,
      ReportStatus.assigned,
      ReportStatus.inProgress,
      ReportStatus.resolved,
      ReportStatus.rejected,
    ].where((status) => reportsByStatus.containsKey(status)).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            // Crear una lista estática de widgets para cada estado
            for (final status in sortedStatuses)
              _buildStatusItem(
                context: context,
                status: status,
                count: reportsByStatus[status] ?? 0,
                total: total,
                statusName: statusNames[status] ?? 'Desconocido',
                statusColor: statusColors[status] ?? Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusItem({
    required BuildContext context,
    required ReportStatus status,
    required int count,
    required int total,
    required String statusName,
    required Color statusColor,
  }) {
    final percentage = total > 0 ? count / total * 100 : 0;
    // Asegurar un ancho mínimo visible para la barra de progreso
    final double progressWidth = percentage > 0 
        ? max(20.0, MediaQuery.of(context).size.width * 0.6 * (percentage / 100))
        : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusName,
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Contenedor para la barra de progreso
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                // Barra de progreso coloreada con estilo uniforme
                Container(
                  width: progressWidth,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
