import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/utils/category_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/interactive_map_page.dart';

class MapPreviewCard extends StatelessWidget {
  final List<Report> reports;
  final VoidCallback onReturn;
  
  const MapPreviewCard({
    super.key,
    required this.reports,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    // Posición central inicial (Ensenada, Baja California)
    final LatLng initialPosition = LatLng(31.871170072167523, -116.6076128288358);
    
    // Crear marcadores para el mapa
    final List<Marker> markers = _createMarkersFromReports(reports);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navegar a la página completa del mapa
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const InteractiveMapPage(),
            ),
          ).then((_) {
            // Recargar los datos al regresar al dashboard
            onReturn();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la tarjeta
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reportes en el Mapa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.fullscreen,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
            
            // Vista previa del mapa
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[800] 
                    : Colors.grey[200],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Mapa
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: initialPosition,
                      initialZoom: 13.0,
                      interactionOptions: const InteractionOptions(
                        // Desactivar interacciones para la vista previa
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ojo_ciudadano_admin',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                    
                  // Overlay con gradiente para mejor legibilidad
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 77), // 0.3 * 255 = 76.5 ≈ 77
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Botón para ver mapa completo
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const InteractiveMapPage(),
                          ),
                        ).then((_) {
                          // Recargar los datos al regresar al dashboard
                          onReturn();
                        });
                      },
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Ver mapa completo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.light
                            ? AppColors.primary
                            : AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Estadísticas rápidas
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context, 
                    Icons.location_on, 
                    '${reports.length}',
                    'Reportes',
                  ),
                  _buildStatItem(
                    context, 
                    Icons.category, 
                    '${_getUniqueCategories(reports).length}',
                    'Categorías',
                  ),
                  _buildStatItem(
                    context, 
                    Icons.pending_actions, 
                    '${reports.where((r) => r.status == ReportStatus.pending).length}',
                    'Pendientes',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Crear marcadores para el mapa
  List<Marker> _createMarkersFromReports(List<Report> reports) {
    return reports.map((report) {
      // Verificar que las coordenadas sean válidas
      if (report.latitude == 0 && report.longitude == 0) return null;
      
      // Obtener color según categoría
      final Color markerColor = CategoryUtils.getColorForCategory(report.category);
      
      return Marker(
        point: LatLng(report.latitude, report.longitude),
        child: GestureDetector(
          onTap: () {
            // No implementamos acción aquí porque es solo vista previa
          },
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            width: 20,
            height: 20,
            child: Center(
              child: Icon(
                CategoryUtils.getIconForCategory(report.category),
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      );
    }).whereType<Marker>().toList(); // Filtrar nulls
  }
  
  // Obtener categorías únicas
  Set<ReportCategory> _getUniqueCategories(List<Report> reports) {
    return reports.map((report) => report.category).toSet();
  }
  
  // Construir elemento de estadística
  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.primary.withAlpha(30)
                : AppColors.primaryDark.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.primary
                : AppColors.primaryDark,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.primary
                : AppColors.primaryDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
