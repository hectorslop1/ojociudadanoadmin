import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/animations/animated_card.dart';
import 'package:ojo_ciudadano_admin/core/utils/status_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final VoidCallback onChangeStatus;
  final VoidCallback onMapTap;
  final VoidCallback onAssignTechnician;

  const ReportCard({
    Key? key,
    required this.report,
    required this.onTap,
    required this.onChangeStatus,
    required this.onMapTap,
    required this.onAssignTechnician,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar el texto del estado y colores usando StatusUtils
    String statusText = StatusUtils.getStatusName(report.status);
    Color badgeColor = StatusUtils.getStatusBackgroundColor(report.status);
    
    // Obtener colores y recursos de la categoría
    Color categoryColor;
    String categoryImage;
    IconData categoryIcon;
    String categoryName;
    
    switch (report.category) {
      case ReportCategory.roadRepair:
        categoryColor = AppColors.warning;
        categoryImage = 'assets/bache.jpg';
        categoryIcon = Icons.construction_outlined;
        categoryName = 'Bacheo';
        break;
      case ReportCategory.garbageCollection:
        categoryColor = AppColors.success;
        categoryImage = 'assets/camionbasura.jpg';
        categoryIcon = Icons.delete_outline;
        categoryName = 'Recolección de basura';
        break;
      case ReportCategory.streetImprovement:
        categoryColor = AppColors.info;
        categoryImage = 'assets/calles.png';
        categoryIcon = Icons.home_repair_service;
        categoryName = 'Mejoramiento de la Imagen Urbana';
        break;
    }
    
    // Determinar color de la banda de prioridad
    Color priorityColor;
    String priorityLabel;
    
    if (report.priority != null) {
      if (report.priority! >= 4) {
        priorityColor = Colors.red;
        priorityLabel = "Alta";
      } else if (report.priority! >= 3) {
        priorityColor = Colors.amber;
        priorityLabel = "Media";
      } else {
        priorityColor = Colors.blue;
        priorityLabel = "Baja";
      }
    } else {
      priorityColor = Colors.grey;
      priorityLabel = "N/A";
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: AnimatedCard(
        elevation: 2,
        pressedElevation: 4,
        scaleOnTap: true,
        pressedScale: 0.98,
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        shadowColor: Colors.black.withAlpha(26),
        onTap: onTap,
        child: Stack(
          children: [
          // Banda lateral de prioridad
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: 25, // Reducir el ancho para evitar desbordamiento
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: RotatedBox(
                quarterTurns: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      priorityLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Contenido principal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con imagen de fondo según categoría
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: categoryColor.withOpacity(0.7), // Color de respaldo en caso de error
                  image: DecorationImage(
                    image: AssetImage(categoryImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      categoryColor.withOpacity(0.7),
                      BlendMode.srcOver,
                    ),
                    onError: (exception, stackTrace) {
                      print('Error cargando imagen: $categoryImage - $exception');
                      return;
                    },
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25), // Espacio para la banda lateral
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max, // Forzar ancho máximo
                      children: [
                        // Icono de la categoría y ID
                        Row(
                          mainAxisSize: MainAxisSize.min, // Evitar expandirse infinitamente
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                categoryIcon,
                                color: categoryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                'ID: REP-${report.id.toString().padLeft(3, '0')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, // Reducir aún más el padding horizontal
                            vertical: 4, // Reducir aún más el padding vertical
                          ),
                          margin: const EdgeInsets.only(left: 16), // Mover más a la derecha
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(16), // Reducir el radio del borde
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5, // Reducir el ancho del borde
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono del estado
                              Icon(
                                StatusUtils.getStatusIcon(report.status),
                                color: Colors.black, // Color negro para mayor contraste
                                size: 12, // Tamaño aún más pequeño para el icono
                              ),
                              const SizedBox(width: 3), // Reducir espacio
                              // Texto del estado
                              Text(
                                statusText,
                                style: const TextStyle(
                                  color: Colors.black, // Color negro para mayor contraste
                                  fontWeight: FontWeight.w900, // Más negrita
                                  fontSize: 12, // Reducir aún más el tamaño de fuente
                                  letterSpacing: 0, // Sin espaciado adicional
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Eliminado el indicador de prioridad ya que ahora se muestra en la banda lateral
                      ],
                    ),
                  ),
                ),
              ),
              // Contenido del reporte
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del reporte
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Descripción
                    Padding(
                      padding: const EdgeInsets.only(right: 5), // Espacio adicional para evitar corte con la banda lateral
                      child: Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Categoría
                    Row(
                      children: [
                        Icon(
                          categoryIcon,
                          size: 16,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          categoryName,
                          style: TextStyle(
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Ubicación
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            report.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Tiempo
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Botones de acción
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Botón de cambiar estatus
                        Flexible(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: onChangeStatus,
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Cambiar Estatus',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF612232),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botón de mapa
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: IconButton(
                            onPressed: onMapTap,
                            icon: const Icon(
                              Icons.map_outlined,
                              color: Color(0xFF612232),
                            ),
                            tooltip: 'Ver en mapa',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botón de asignar técnico
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: IconButton(
                            onPressed: onAssignTechnician,
                            icon: const Icon(
                              Icons.person_add_outlined,
                              color: Color(0xFF612232),
                            ),
                            tooltip: 'Asignar técnico',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
