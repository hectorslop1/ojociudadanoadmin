import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/report_detail_page.dart';

class EvidenceCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onReturn;

  const EvidenceCard({
    super.key,
    required this.report,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener la primera URL de evidencia (si existe)
    final String? evidenceUrl = report.evidenceUrls.isNotEmpty 
        ? report.evidenceUrls.first 
        : null;
    
    // Determinar si es una imagen o un video
    final bool isVideo = evidenceUrl != null && 
        (evidenceUrl.endsWith('.mp4') || 
         evidenceUrl.endsWith('.mov') || 
         evidenceUrl.endsWith('.avi'));
    
    // Obtener el nombre de la categoría
    String categoryName = '';
    switch (report.category) {
      case ReportCategory.lighting:
        categoryName = 'Alumbrado';
        break;
      case ReportCategory.roadRepair:
        categoryName = 'Reparación de Calles';
        break;
      case ReportCategory.garbageCollection:
        categoryName = 'Recolección de Basura';
        break;
      case ReportCategory.waterLeaks:
        categoryName = 'Fugas de Agua';
        break;
      case ReportCategory.abandonedVehicles:
        categoryName = 'Vehículos Abandonados';
        break;
      case ReportCategory.noise:
        categoryName = 'Ruido';
        break;
      case ReportCategory.animalAbuse:
        categoryName = 'Maltrato Animal';
        break;
      case ReportCategory.insecurity:
        categoryName = 'Inseguridad';
        break;
      case ReportCategory.stopSignsDamaged:
        categoryName = 'Señales de Alto Dañadas';
        break;
      case ReportCategory.trafficLightsDamaged:
        categoryName = 'Semáforos Dañados';
        break;
      case ReportCategory.poorSignage:
        categoryName = 'Señalización Deficiente';
        break;
      case ReportCategory.genderEquity:
        categoryName = 'Equidad de Género';
        break;
      case ReportCategory.disabilityRamps:
        categoryName = 'Rampas para Discapacitados';
        break;
      case ReportCategory.serviceComplaints:
        categoryName = 'Quejas de Servicio';
        break;
      case ReportCategory.other:
        categoryName = 'Otros';
        break;
    }
    
    // Obtener el color según el estado
    Color statusColor;
    switch (report.status) {
      case ReportStatus.pending:
        statusColor = AppColors.warning;
        break;
      case ReportStatus.assigned:
        statusColor = AppColors.info;
        break;
      case ReportStatus.inProgress:
        statusColor = Theme.of(context).brightness == Brightness.light
            ? AppColors.primary
            : AppColors.primaryDark;
        break;
      case ReportStatus.resolved:
        statusColor = AppColors.success;
        break;
      case ReportStatus.rejected:
        statusColor = AppColors.error;
        break;
    }

    return GestureDetector(
      onTap: () {
        // Navegar a la página de detalles del reporte
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReportDetailPage(reportId: report.id),
          ),
        ).then((_) {
          // Llamar al callback para recargar los reportes si existe
          if (onReturn != null) {
            onReturn!();
          }
        });
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen o video (thumbnail)
            Stack(
              children: [
                // Imagen o placeholder
                AspectRatio(
                  aspectRatio: 1,
                  child: evidenceUrl != null
                      ? Image.network(
                          evidenceUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Error loading image: $evidenceUrl
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                
                // Indicador de video
                if (isVideo)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                
                // Indicador de múltiples evidencias
                if (report.evidenceUrls.length > 1)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${report.evidenceUrls.length - 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Información del reporte
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría
                    Flexible(
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Descripción
                    Flexible(
                      child: Text(
                        report.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    
                    // Estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusName(report.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getStatusName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.assigned:
        return 'Asignado';
      case ReportStatus.inProgress:
        return 'En Progreso';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.rejected:
        return 'Rechazado';
    }
  }
}
