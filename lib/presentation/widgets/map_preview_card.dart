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
    
    // Obtener el tema actual
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColors.primaryDark : AppColors.primary;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la tarjeta con mejor diseño
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.map,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Reportes en el Mapa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InteractiveMapPage(),
                      ),
                    ).then((_) {
                      onReturn();
                    });
                  },
                  icon: Icon(
                    Icons.fullscreen,
                    color: primaryColor,
                    size: 22,
                  ),
                  tooltip: 'Ver mapa completo',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
            
          // Vista previa del mapa con diseño mejorado
          Container(
            height: 200,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[800] 
                  : Colors.grey[200],
            ),
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
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Botón para ver mapa completo
                Positioned(
                  bottom: 12,
                  right: 12,
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
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Estadísticas rápidas con diseño mejorado
          Padding(
            padding: const EdgeInsets.all(16),
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
  
  // Construir elemento de estadística con diseño mejorado
  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColors.primaryDark : AppColors.primary;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
