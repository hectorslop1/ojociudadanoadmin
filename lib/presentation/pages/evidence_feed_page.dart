import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/evidence_reel_feed.dart';

class EvidenceFeedPage extends StatefulWidget {
  const EvidenceFeedPage({super.key});

  @override
  State<EvidenceFeedPage> createState() => _EvidenceFeedPageState();
}

class _EvidenceFeedPageState extends State<EvidenceFeedPage> {
  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    // Cargar todos los reportes al iniciar
    _loadReports();
  }
  
  void _loadReports() {
    context.read<ReportsBloc>().add(
      LoadReportsEvent(
        status: _selectedStatus,
        category: _selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Feed principal de evidencias
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ReportsLoaded || (state is ReportDetailsLoaded && state.previousReports != null)) {
                // Obtener la lista de reportes del estado actual
                final List<Report> reports;
                
                if (state is ReportsLoaded) {
                  reports = state.reports;
                } else {
                  // Es ReportDetailsLoaded con previousReports
                  reports = (state as ReportDetailsLoaded).previousReports!;
                }
                
                return EvidenceReelFeed(
                  reports: reports,
                  onRefresh: _loadReports,
                );
              } else if (state is ReportsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReports,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No hay datos disponibles'));
              }
            },
          ),
          
          // Panel de filtros desplegable
          if (_showFilters)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 26), // 0.1 * 255 = 25.5 ≈ 26
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtrar evidencias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Filtro por categoría
                          Expanded(
                            child: _buildCategoryDropdown(),
                          ),
                          const SizedBox(width: 16),
                          
                          // Filtro por estado
                          Expanded(
                            child: _buildStatusDropdown(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<ReportCategory?>(
      decoration: const InputDecoration(
        labelText: 'Categoría',
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      isExpanded: true,
      value: _selectedCategory,
      menuMaxHeight: 300,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Todas'),
        ),
        ...ReportCategory.values.map((category) {
          String categoryName = '';
          switch (category) {
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
          return DropdownMenuItem(
            value: category,
            child: Text(categoryName),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
        _loadReports();
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<ReportStatus?>(
      decoration: const InputDecoration(
        labelText: 'Estado',
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
        isDense: true,
      ),
      isExpanded: true,
      value: _selectedStatus,
      menuMaxHeight: 300,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Todos'),
        ),
        ...ReportStatus.values.map((status) {
          String statusName = '';
          switch (status) {
            case ReportStatus.pending:
              statusName = 'Pendiente';
              break;
            case ReportStatus.assigned:
              statusName = 'Asignado';
              break;
            case ReportStatus.inProgress:
              statusName = 'En Progreso';
              break;
            case ReportStatus.resolved:
              statusName = 'Resuelto';
              break;
            case ReportStatus.rejected:
              statusName = 'Rechazado';
              break;
          }
          return DropdownMenuItem(
            value: status,
            child: Text(statusName),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
        _loadReports();
      },
    );
  }
}
