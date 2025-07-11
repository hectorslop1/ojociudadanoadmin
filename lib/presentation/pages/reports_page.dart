import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/report_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Todos', 'Abierto', 'Asignado', 'En Progreso'];
  final List<ReportStatus?> _statusFilters = [null, ReportStatus.pending, ReportStatus.assigned, ReportStatus.inProgress];
  
  ReportCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Cargar todos los reportes al iniciar
    _loadReports();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _loadReports();
    }
  }
  
  void _loadReports() {
    final selectedStatus = _tabController.index > 0 ? _statusFilters[_tabController.index] : null;
    
    context.read<ReportsBloc>().add(
      LoadReportsEvent(
        status: selectedStatus,
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Configurar timeago en español
    timeago.setLocaleMessages('es', timeago.EsMessages());
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: _buildFilterTabs(),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
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
                  
                  // Filtrar reportes según la pestaña seleccionada
                  List<Report> filteredReports;
                  switch (_tabController.index) {
                    case 1: // Abierto
                      filteredReports = reports.where((r) => r.status == ReportStatus.pending).toList();
                      break;
                    case 2: // Asignado
                      filteredReports = reports.where((r) => r.status == ReportStatus.assigned).toList();
                      break;
                    case 3: // En Progreso
                      filteredReports = reports.where((r) => r.status == ReportStatus.inProgress).toList();
                      break;
                    default: // Todos
                      filteredReports = reports;
                  }
                  
                  if (filteredReports.isEmpty) {
                    return const Center(
                      child: Text('No hay reportes disponibles'),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(report);
                    },
                  );
                } else if (state is ReportsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFE53935), // Error color
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Color(0xFFE53935)), // Error color
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
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterTabs() {
    return Container(
      color: const Color(0xFF612232), // Fondo guinda
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white, // Texto blanco para la pestaña seleccionada
        unselectedLabelColor: Color.fromRGBO(255, 255, 255, 0.7), // Texto blanco con opacidad para pestañas no seleccionadas
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        indicatorColor: Colors.white, // Indicador blanco
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _tabs.map((tab) => Tab(
          text: tab,
          height: 40,
        )).toList(),
      ),
    );
  }
  
  Widget _buildReportCard(Report report) {
    // Determinar el texto del estado y colores según la imagen compartida
    String statusText;
    Color badgeColor;
    Color textColor;
    
    switch (report.status) {
      case ReportStatus.pending:
        statusText = 'Abierto';
        badgeColor = const Color.fromRGBO(41, 182, 246, 0.1); // Azul claro sutil
        textColor = const Color(0xFF29B6F6); 
        break;
      case ReportStatus.assigned:
        statusText = 'Asignado';
        badgeColor = const Color.fromRGBO(253, 216, 53, 0.15); // Amarillo sutil
        textColor = const Color(0xFF8F6400); // Texto oscuro para contraste
        break;
      case ReportStatus.inProgress:
        statusText = 'En Progreso';
        badgeColor = const Color.fromRGBO(142, 36, 170, 0.1); // Púrpura sutil
        textColor = const Color(0xFF8E24AA); 
        break;
      case ReportStatus.resolved:
        statusText = 'Resuelto';
        badgeColor = const Color.fromRGBO(102, 187, 106, 0.1); // Verde sutil
        textColor = const Color(0xFF66BB6A); 
        break;
      case ReportStatus.rejected:
        statusText = 'Rechazado';
        badgeColor = const Color.fromRGBO(229, 57, 53, 0.1); // Rojo sutil
        textColor = const Color(0xFFE53935); 
        break;
    }
    
    // Determinar la prioridad (simulada para este ejemplo)
    String priority;
    Color priorityColor;
    
    // Simulamos la prioridad basada en la categoría
    if (report.category == ReportCategory.insecurity || 
        report.category == ReportCategory.waterLeaks) {
      priority = 'Alta';
      priorityColor = const Color(0xFFE53935); // Rojo
    } else if (report.category == ReportCategory.lighting || 
               report.category == ReportCategory.trafficLightsDamaged) {
      priority = 'Media';
      priorityColor = const Color(0xFFFB8C00); // Naranja
    } else {
      priority = 'Normal';
      priorityColor = const Color(0xFF4CAF50); // Verde
    }
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(26), width: 1), // 0.1 * 255 = ~26
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportDetailPage(reportId: report.id),
            ),
          ).then((_) {
            // Recargar los reportes cuando se regresa de la página de detalles
            _loadReports();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Estado y Prioridad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                      border: report.status == ReportStatus.pending
                          ? Border.all(color: textColor, width: 1) // Borde para abierto
                          : null, // Sin borde para otros estados
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(report.status),
                          color: textColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Prioridad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        (priorityColor.r * 255.0).round() & 0xff,
                        (priorityColor.g * 255.0).round() & 0xff,
                        (priorityColor.b * 255.0).round() & 0xff,
                        0.1
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color.fromRGBO(
                        (priorityColor.r * 255.0).round() & 0xff,
                        (priorityColor.g * 255.0).round() & 0xff,
                        (priorityColor.b * 255.0).round() & 0xff,
                        0.3
                      ), width: 1),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
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
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Ubicación
              Row(
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
              
              const SizedBox(height: 8),
              
              // Tiempo y categoría
              Row(
                children: [
                  // Tiempo
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hace ${_formatTimeAgo(report.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        (_getCategoryColor(report.category).r * 255.0).round() & 0xff,
                        (_getCategoryColor(report.category).g * 255.0).round() & 0xff,
                        (_getCategoryColor(report.category).b * 255.0).round() & 0xff,
                        0.1
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color.fromRGBO(
                        (_getCategoryColor(report.category).r * 255.0).round() & 0xff,
                        (_getCategoryColor(report.category).g * 255.0).round() & 0xff,
                        (_getCategoryColor(report.category).b * 255.0).round() & 0xff,
                        0.3
                      ), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(report.category),
                          color: _getCategoryColor(report.category),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCategoryName(report.category),
                          style: TextStyle(
                            color: _getCategoryColor(report.category),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Botón de cambiar estado
              Divider(height: 1, thickness: 1, color: Colors.grey.withAlpha(26)), // 0.1 * 255 = ~26
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    _showChangeStatusDialog(report);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF8E24AA)),
                  label: const Text(
                    'Cambiar Estado',
                    style: TextStyle(
                      color: Color(0xFF8E24AA),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.pressed)
                          ? const Color.fromRGBO(142, 36, 170, 0.05)
                          : null;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showChangeStatusDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Estado', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pendiente', style: TextStyle(fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.access_time, color: Color(0xFF29B6F6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(context);
                _updateReportStatus(report.id, ReportStatus.pending);
              },
            ),
            ListTile(
              title: const Text('Asignado', style: TextStyle(fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.person, color: Color(0xFFFDD835)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(context);
                _updateReportStatus(report.id, ReportStatus.assigned);
              },
            ),
            ListTile(
              title: const Text('En Progreso', style: TextStyle(fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.engineering, color: Color(0xFF8E24AA)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(context);
                _updateReportStatus(report.id, ReportStatus.inProgress);
              },
            ),
            ListTile(
              title: const Text('Resuelto', style: TextStyle(fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(context);
                _updateReportStatus(report.id, ReportStatus.resolved);
              },
            ),
            ListTile(
              title: const Text('Rechazado', style: TextStyle(fontWeight: FontWeight.w500)),
              leading: const Icon(Icons.cancel, color: Color(0xFFE53935)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(context);
                _updateReportStatus(report.id, ReportStatus.rejected);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8E24AA),
            ),
            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
  
  void _updateReportStatus(String reportId, ReportStatus status) {
    context.read<ReportsBloc>().add(
      UpdateReportStatusEvent(
        reportId: reportId,
        status: status,
      ),
    );
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'unos segundos';
    }
  }
  
  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.access_time;
      case ReportStatus.assigned:
        return Icons.person;
      case ReportStatus.inProgress:
        return Icons.engineering;
      case ReportStatus.resolved:
        return Icons.check_circle;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }
  
  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.lighting:
        return Icons.lightbulb;
      case ReportCategory.roadRepair:
        return Icons.construction;
      case ReportCategory.garbageCollection:
        return Icons.delete;
      case ReportCategory.waterLeaks:
        return Icons.water_drop;
      case ReportCategory.abandonedVehicles:
        return Icons.directions_car;
      case ReportCategory.noise:
        return Icons.volume_up;
      case ReportCategory.animalAbuse:
        return Icons.pets;
      case ReportCategory.insecurity:
        return Icons.security;
      case ReportCategory.stopSignsDamaged:
        return Icons.do_not_disturb_on;
      case ReportCategory.trafficLightsDamaged:
        return Icons.traffic;
      case ReportCategory.poorSignage:
        return Icons.signpost;
      case ReportCategory.genderEquity:
        return Icons.people;
      case ReportCategory.disabilityRamps:
        return Icons.accessible;
      case ReportCategory.serviceComplaints:
        return Icons.support_agent;
      case ReportCategory.other:
        return Icons.help;
    }
  }

  Color _getCategoryColor(ReportCategory category) {
    switch (category) {
      case ReportCategory.lighting:
        return const Color(0xFFFFB300); // Ámbar más suave
      case ReportCategory.roadRepair:
        return const Color(0xFF8D6E63); // Marrón más suave
      case ReportCategory.garbageCollection:
        return const Color(0xFF66BB6A); // Verde más suave
      case ReportCategory.waterLeaks:
        return const Color(0xFF42A5F5); // Azul más suave
      case ReportCategory.abandonedVehicles:
        return const Color(0xFF78909C); // Azul grisáceo más suave
      case ReportCategory.noise:
        return const Color(0xFFFF7043); // Naranja más suave
      case ReportCategory.animalAbuse:
        return const Color(0xFFBA68C8); // Púrpura más suave
      case ReportCategory.insecurity:
        return const Color(0xFFEF5350); // Rojo más suave
      case ReportCategory.stopSignsDamaged:
        return const Color(0xFFE53935); // Rojo más suave
      case ReportCategory.trafficLightsDamaged:
        return const Color(0xFFFFB300); // Ámbar más suave
      case ReportCategory.poorSignage:
        return const Color(0xFF8D6E63); // Marrón más suave
      case ReportCategory.genderEquity:
        return const Color(0xFFEC407A); // Rosa más suave
      case ReportCategory.disabilityRamps:
        return const Color(0xFF42A5F5); // Azul más suave
      case ReportCategory.serviceComplaints:
        return const Color(0xFFFF7043); // Naranja más suave
      case ReportCategory.other:
        return const Color(0xFF78909C); // Azul grisáceo más suave
    }
  }
  
  String _getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.lighting:
        return 'Alumbrado';
      case ReportCategory.roadRepair:
        return 'Baches';
      case ReportCategory.garbageCollection:
        return 'Basura';
      case ReportCategory.waterLeaks:
        return 'Fugas de agua';
      case ReportCategory.abandonedVehicles:
        return 'Vehículos abandonados';
      case ReportCategory.noise:
        return 'Ruido';
      case ReportCategory.animalAbuse:
        return 'Maltrato animal';
      case ReportCategory.insecurity:
        return 'Inseguridad';
      case ReportCategory.stopSignsDamaged:
        return 'Señalamientos dañados';
      case ReportCategory.trafficLightsDamaged:
        return 'Semáforos dañados';
      case ReportCategory.poorSignage:
        return 'Mala señalización';
      case ReportCategory.genderEquity:
        return 'Equidad de género';
      case ReportCategory.disabilityRamps:
        return 'Rampas para discapacitados';
      case ReportCategory.serviceComplaints:
        return 'Quejas de servicio';
      case ReportCategory.other:
        return 'Otro';
    }
  }
}
