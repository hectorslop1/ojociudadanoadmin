import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/utils/category_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/status_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReportListItem extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const ReportListItem({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Configurar timeago en español
    timeago.setLocaleMessages('es', timeago.EsMessages());
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: ID, Fecha y Estado
              Row(
                children: [
                  // ID del reporte
                  Expanded(
                    child: Text(
                      'Reporte #${report.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // Estado del reporte
                  StatusBadge(status: report.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Categoría y descripción
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de la categoría
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(report.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(report.category),
                      color: _getCategoryColor(report.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Categoría y descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryName(report.category),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Ubicación, fecha y técnico asignado
              Row(
                children: [
                  // Ubicación
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Fecha
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(report.createdAt, locale: 'es'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Técnico asignado (si existe)
              if (report.assignedTechnician != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.primary
                          : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Asignado a: ${report.assignedTechnician!.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.primary
                            : AppColors.primaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Indicador de evidencias
              if (report.evidenceUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.evidenceUrls.length} ${report.evidenceUrls.length == 1 ? 'evidencia' : 'evidencias'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ReportCategory category) {
    return CategoryUtils.getIconForCategory(category);
  }

  Color _getCategoryColor(ReportCategory category) {
    // Usamos el color sin contexto, ya que este método es estático
    // y no tiene acceso al contexto de la aplicación
    return CategoryUtils.getColorForCategory(category);
  }

  String _getCategoryName(ReportCategory category) {
    return CategoryUtils.getCategoryName(category);
  }
}
