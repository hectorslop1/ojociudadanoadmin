import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class BatchSelectionCard extends StatelessWidget {
  final Report report;
  final bool isSelected;
  final VoidCallback onToggleSelection;

  const BatchSelectionCard({
    super.key,
    required this.report,
    required this.isSelected,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
                color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onToggleSelection,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox para selección
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelection(),
                activeColor: isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.primary,
              ),
              const SizedBox(width: 8),

              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y categoría
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            report.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(context, report.category),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Descripción
                    Text(
                      report.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Información adicional
                    Row(
                      children: [
                        // Estado
                        _buildStatusChip(context, report.status),
                        const SizedBox(width: 8),

                        // Prioridad
                        if (report.priority != null) ...[
                          _buildPriorityChip(context, report.priority!),
                          const SizedBox(width: 8),
                        ],

                        // Fecha
                        Expanded(
                          child: Text(
                            'Creado: ${_formatDate(report.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, ReportCategory category) {
    final categoryInfo = _getCategoryInfo(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryInfo.color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryInfo.color.withAlpha(77), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryInfo.icon, size: 12, color: categoryInfo.color),
          const SizedBox(width: 4),
          Text(
            categoryInfo.name,
            style: TextStyle(
              fontSize: 12,
              color: categoryInfo.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.blue;
        text = 'Pendiente';
        break;
      case ReportStatus.assigned:
        color = Colors.orange;
        text = 'Asignado';
        break;
      case ReportStatus.inProgress:
        color = Colors.purple;
        text = 'En progreso';
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        text = 'Resuelto';
        break;
      case ReportStatus.rejected:
        color = Colors.red;
        text = 'Rechazado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, int priority) {
    Color color;
    String text;

    switch (priority) {
      case 5:
        color = Colors.red;
        text = 'Crítica';
        break;
      case 4:
        color = Colors.deepOrange;
        text = 'Alta';
        break;
      case 3:
        color = Colors.amber;
        text = 'Media';
        break;
      case 2:
        color = Colors.blue;
        text = 'Baja';
        break;
      case 1:
        color = Colors.green;
        text = 'Muy baja';
        break;
      default:
        color = Colors.grey;
        text = 'Sin prioridad';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  CategoryInfo _getCategoryInfo(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return CategoryInfo(
          name: 'Bacheo',
          icon: Icons.construction,
          color: Colors.orange,
        );
      case ReportCategory.garbageCollection:
        return CategoryInfo(
          name: 'Recolección de basura',
          icon: Icons.delete_outline,
          color: Colors.green,
        );
      case ReportCategory.streetImprovement:
        return CategoryInfo(
          name: 'Mejoramiento de calles',
          icon: Icons.home_repair_service,
          color: Colors.blue,
        );
    }
  }
}

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
  });
}
