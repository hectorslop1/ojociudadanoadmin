import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/utils/category_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/report_detail_page.dart';

class InteractiveMapPage extends StatefulWidget {
  const InteractiveMapPage({super.key});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  // Filtros para los reportes
  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Controlador para el mapa
  final MapController _mapController = MapController();
  
  // Lista de marcadores para el mapa
  final List<Marker> _markers = [];
  
  // Posición central inicial (Ensenada, Baja California)
  final LatLng _initialPosition = LatLng(31.871170072167523, -116.6076128288358);
  
  // Nivel de zoom inicial
  final double _initialZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadReports();
  }

  // Verificar permisos de ubicación
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Los servicios de ubicación no están habilitados, mostrar mensaje
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los servicios de ubicación están desactivados'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Verificar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Solicitar permisos
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permisos denegados
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Los permisos de ubicación fueron denegados'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permisos denegados permanentemente
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Los permisos de ubicación están permanentemente denegados, '
            'no se puede solicitar permisos',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
  }

  // Cargar reportes
  void _loadReports() {
    context.read<ReportsBloc>().add(
          LoadReportsEvent(
            status: _selectedStatus,
            category: _selectedCategory,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  // Ir a la ubicación actual del usuario
  Future<void> _goToUserLocation() async {
    // Ir a la ubicación de Ensenada, Baja California
    _mapController.move(
      _initialPosition,
      _initialZoom,
    );
    
    // Opcional: Mostrar un mensaje informativo
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Centrando en Ensenada, Baja California'),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.primary
            : AppColors.primaryDark,
      ),
    );
  }

  // Mostrar diálogo de filtros mejorado
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildEnhancedFilterDialog(),
    );
  }
  
  // Construir diálogo de filtros mejorado con iconos
  Widget _buildEnhancedFilterDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              tabs: [
                Tab(icon: Icon(Icons.category), text: 'Categoría'),
                Tab(icon: Icon(Icons.flag), text: 'Estado'),
              ],
              labelColor: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 400,
              child: TabBarView(
                children: [
                  // Pestaña de categorías
                  _buildCategoryFilterTab(),
                  // Pestaña de estados
                  _buildStatusFilterTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedStatus = null;
                        _startDate = null;
                        _endDate = null;
                      });
                      _loadReports();
                      Navigator.of(context).pop();
                    },
                    child: Text('Limpiar filtros'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _loadReports();
                      Navigator.of(context).pop();
                    },
                    child: Text('Aplicar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construir pestaña de filtros por categoría
  Widget _buildCategoryFilterTab() {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.all_inclusive),
          title: Text('Todas las categorías'),
          selected: _selectedCategory == null,
          onTap: () {
            setState(() => _selectedCategory = null);
            Navigator.of(context).pop();
            _loadReports();
          },
        ),
        Divider(),
        ...ReportCategory.values.map((category) {
          return ListTile(
            leading: Icon(_getIconForCategory(category)),
            title: Text(_getCategoryName(category)),
            selected: _selectedCategory == category,
            onTap: () {
              setState(() => _selectedCategory = category);
              Navigator.of(context).pop();
              _loadReports();
            },
          );
        }),
      ],
    );
  }
  
  // Construir pestaña de filtros por estado
  Widget _buildStatusFilterTab() {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.all_inclusive),
          title: Text('Todos los estados'),
          selected: _selectedStatus == null,
          onTap: () {
            setState(() => _selectedStatus = null);
            Navigator.of(context).pop();
            _loadReports();
          },
        ),
        Divider(),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.amber, 
            child: Icon(Icons.pending, color: Colors.white),
          ),
          title: Text('Pendiente'),
          selected: _selectedStatus == ReportStatus.pending,
          onTap: () {
            setState(() => _selectedStatus = ReportStatus.pending);
            Navigator.of(context).pop();
            _loadReports();
          },
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue, 
            child: Icon(Icons.assignment_ind, color: Colors.white),
          ),
          title: Text('Asignado'),
          selected: _selectedStatus == ReportStatus.assigned,
          onTap: () {
            setState(() => _selectedStatus = ReportStatus.assigned);
            Navigator.of(context).pop();
            _loadReports();
          },
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange, 
            child: Icon(Icons.engineering, color: Colors.white),
          ),
          title: Text('En progreso'),
          selected: _selectedStatus == ReportStatus.inProgress,
          onTap: () {
            setState(() => _selectedStatus = ReportStatus.inProgress);
            Navigator.of(context).pop();
            _loadReports();
          },
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green, 
            child: Icon(Icons.check_circle, color: Colors.white),
          ),
          title: Text('Resuelto'),
          selected: _selectedStatus == ReportStatus.resolved,
          onTap: () {
            setState(() => _selectedStatus = ReportStatus.resolved);
            Navigator.of(context).pop();
            _loadReports();
          },
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red, 
            child: Icon(Icons.cancel, color: Colors.white),
          ),
          title: Text('Rechazado'),
          selected: _selectedStatus == ReportStatus.rejected,
          onTap: () {
            setState(() => _selectedStatus = ReportStatus.rejected);
            Navigator.of(context).pop();
            _loadReports();
          },
        ),
      ],
    );
  }

  // Crear marcadores a partir de los reportes
  void _createMarkersFromReports(List<Report> reports) {
    // Limpiar marcadores existentes
    _markers.clear();
    
    // Si no hay reportes, salir temprano
    if (reports.isEmpty) {
      return;
    }
    
    for (final report in reports) {
      final LatLng position = LatLng(report.latitude, report.longitude);
      
      final Marker marker = Marker(
        point: position,
        width: 32.0, // Reducido para evitar overflow
        height: 32.0, // Reducido para evitar overflow
        alignment: Alignment.topCenter, // Alineación para evitar overflow
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReportDetailPage(reportId: report.id),
              ),
            ).then((_) {
              // Recargar los reportes al regresar de la página de detalles
              _loadReports();
            });
          },
          child: Stack(
            clipBehavior: Clip.none, // Permite que los elementos se superpongan sin recorte
            children: [
              // Círculo con icono
              Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  color: CategoryUtils.getColorForCategory(report.category, context: context),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51), // 0.2 * 255 = 51
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    CategoryUtils.getIconForCategory(report.category),
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      
      _markers.add(marker);
    }
  }
  
  // Ya no necesitamos este método porque ahora usamos CategoryUtils para los colores
  
  // Obtener el icono según la categoría
  IconData _getIconForCategory(ReportCategory category) {
    return CategoryUtils.getIconForCategory(category);
  }

  // Obtener el nombre de la categoría
  String _getCategoryName(ReportCategory category) {
    return CategoryUtils.getCategoryName(category);
  }

  // Obtener descripción de los filtros aplicados
  String _getFilterDescription() {
    final List<String> filters = [];
    
    if (_selectedCategory != null) {
      filters.add('Categoría: ${_getCategoryName(_selectedCategory!)}');
    }
    
    if (_selectedStatus != null) {
      filters.add('Estado: ${_getStatusName(_selectedStatus!)}');
    }
    
    if (_startDate != null && _endDate != null) {
      filters.add('Periodo: ${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}');
    } else if (_startDate != null) {
      filters.add('Desde: ${_formatDate(_startDate!)}');
    } else if (_endDate != null) {
      filters.add('Hasta: ${_formatDate(_endDate!)}');
    }
    
    return filters.isEmpty ? 'Sin filtros aplicados' : filters.join(', ');
  }

  // Obtener el nombre del estado
  String _getStatusName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.assigned:
        return 'Asignado';
      case ReportStatus.inProgress:
        return 'En progreso';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.rejected:
        return 'Rechazado';
    }
  }

  // Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Construir elemento de leyenda
  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Construir leyenda de estados
  Widget _buildStatusLegend() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Leyenda',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildLegendItem('Pendiente', Colors.amber),
            _buildLegendItem('Asignado', Colors.blue),
            _buildLegendItem('En progreso', Colors.orange),
            _buildLegendItem('Resuelto', Colors.green),
            _buildLegendItem('Rechazado', Colors.red),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Reportes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Regresar al Dashboard',
        ),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text(state.message));
          } else if (state is ReportsLoaded || state is ReportDetailsLoaded) {
            // Obtener la lista de reportes según el estado
            List<Report> reports = [];
            if (state is ReportsLoaded) {
              reports = state.reports;
            } else if (state is ReportDetailsLoaded && state.previousReports != null) {
              reports = state.previousReports!;
            }
            
            // Crear marcadores a partir de los reportes filtrados
            _createMarkersFromReports(reports);
            
            // Construir el mapa con flutter_map
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: _initialZoom,
                    interactionOptions: const InteractionOptions(
                      enableScrollWheel: true,
                      enableMultiFingerGestureRace: true,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ojo_ciudadano_admin',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                // Overlay con los controles y filtros
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getFilterDescription(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.filter_alt),
                            onPressed: _showFilterDialog,
                            tooltip: 'Filtrar reportes',
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                _selectedCategory = null;
                                _selectedStatus = null;
                                _startDate = null;
                                _endDate = null;
                              });
                              _loadReports();
                            },
                            tooltip: 'Resetear filtros',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botones de zoom y ubicación
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, currentZoom + 1);
                        },
                        heroTag: 'zoomIn',
                        tooltip: 'Acercar',
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, currentZoom - 1);
                        },
                        heroTag: 'zoomOut',
                        tooltip: 'Alejar',
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        onPressed: _goToUserLocation,
                        heroTag: 'location',
                        tooltip: 'Mi ubicación',
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
                // Leyenda de colores para los estados
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: _buildStatusLegend(),
                ),
              ],
            );
          }
          
          return const Center(child: Text('No hay reportes disponibles'));
        },
      ),
    );
  }
}
