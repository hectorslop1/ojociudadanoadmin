import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/animations/animated_list_view.dart';
import 'package:ojo_ciudadano_admin/core/utils/status_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/interactive_map_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/report_detail_page.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/priority_filter.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/report_card.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/single_report_actions.dart';

class ReportsPage extends StatefulWidget {
  final ReportStatus? initialStatus;
  final ReportCategory? initialCategory;
  
  const ReportsPage({
    super.key, 
    this.initialStatus,
    this.initialCategory,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'Todos', 
    StatusUtils.getStatusName(ReportStatus.pending),
    StatusUtils.getStatusName(ReportStatus.assigned),
    StatusUtils.getStatusName(ReportStatus.inProgress),
    StatusUtils.getStatusName(ReportStatus.resolved)
  ];
  final List<ReportStatus?> _statusFilters = [
    null,
    ReportStatus.pending,
    ReportStatus.assigned,
    ReportStatus.inProgress,
    ReportStatus.resolved,
  ];

  ReportCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _minPriority;

  @override
  void initState() {
    super.initState();
    
    // Inicializar filtros si se proporcionaron
    _selectedCategory = widget.initialCategory;
    
    // Configurar el tab controller
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // Si se proporciona un estado inicial, seleccionar la pestaña correspondiente
    if (widget.initialStatus != null) {
      final statusIndex = _statusFilters.indexOf(widget.initialStatus);
      if (statusIndex >= 0) {
        _tabController.index = statusIndex;
      }
    }
    
    _tabController.addListener(_handleTabChange);

    // Cargar los reportes con los filtros iniciales
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
    if (!mounted) return;
    
    final ReportStatus? statusFilter = _statusFilters[_tabController.index];
    
    context.read<ReportsBloc>().add(
      LoadReportsEvent(
        status: statusFilter,
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        minPriority: _minPriority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Ciudadanos'),
        backgroundColor: const Color(0xFF612232), // Fondo guinda
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterTabs(),
        ),
        actions: [
          // Botón para actualizar prioridades automáticamente
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Priorizar automáticamente',
            onPressed: _updateAllPriorities,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF612232)),
                          strokeWidth: 3.0,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando reportes...',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is ReportsLoaded) {
                  final reports = state.reports;
                  List<Report> filteredReports;

                  // Aplicar filtro por estado según la pestaña seleccionada
                  switch (_tabController.index) {
                    case 1: // Abierto
                      filteredReports = reports
                          .where((r) => r.status == ReportStatus.pending)
                          .toList();
                      break;
                    case 2: // Asignado
                      filteredReports = reports
                          .where((r) => r.status == ReportStatus.assigned)
                          .toList();
                      break;
                    case 3: // En Progreso
                      filteredReports = reports
                          .where((r) => r.status == ReportStatus.inProgress)
                          .toList();
                      break;
                    case 4: // Resuelto
                      filteredReports = reports
                          .where((r) => r.status == ReportStatus.resolved)
                          .toList();
                      break;
                    default: // Todos
                      filteredReports = reports;
                  }

                  if (filteredReports.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay reportes disponibles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No se encontraron reportes con los filtros actuales',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = null;
                                _startDate = null;
                                _endDate = null;
                                _minPriority = null;
                                _tabController.index = 0; // Mostrar todos los reportes
                              });
                              _loadReports();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Limpiar filtros'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF612232),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return AnimatedListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemSpacing: 12.0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutQuint,
                    children: filteredReports
                        .map((report) => ReportCard(
                          report: report,
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => ReportDetailPage(reportId: report.id),
                                  ),
                                )
                                .then((_) {
                                  // Recargar los reportes cuando se regresa de la página de detalles
                                  _loadReports();
                                });
                          },
                          onChangeStatus: () => _showChangeStatusDialog(report),
                          onMapTap: () {
                            // Navegar a la página de mapa y centrar en la ubicación del reporte
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => InteractiveMapPage(initialReport: report),
                              ),
                            ).then((_) {
                              // Recargar los reportes al regresar
                              _loadReports();
                            });
                          },
                          // El botón de asignar técnico ya no existe en la tarjeta de reporte
                          // Esta función se mantiene por compatibilidad con ReportCard
                          onAssignTechnician: () {},
                        ))
                        .toList(),
                  );
                } else if (state is ReportsError) {
                  // Mostrar información de error detallada
                  print('Error en ReportsPage: ${state.message}');
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
                          'Error al cargar reportes:',
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Color(0xFFE53935),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Recargar los reportes con un mensaje de depuración
                            print('Intentando recargar reportes...');
                            _loadReports();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF612232),
                            foregroundColor: Colors.white,
                          ),
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
        unselectedLabelColor: Color.fromRGBO(
          255,
          255,
          255,
          0.7,
        ), // Texto blanco con opacidad para pestañas no seleccionadas
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        indicatorColor: Colors.white, // Indicador blanco
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _tabs.map((tab) => Tab(text: tab, height: 40)).toList(),
      ),
    );
  }

  // Método para actualizar todas las prioridades automáticamente
  void _updateAllPriorities() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Priorizar automáticamente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Deseas actualizar automáticamente la prioridad de todos los reportes basado en su categoría, antigüedad y ubicación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualizando prioridades...'),
                  duration: Duration(seconds: 2),
                ),
              );
              // Llamar al evento para actualizar todas las prioridades
              context.read<ReportsBloc>().add(UpdateAllReportPrioritiesEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF612232),
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(Report report) {
    // Usar el adaptador para mostrar el diálogo de acciones existente
    SingleReportActions.showActionsForReport(context, report);
    
    // Recargar los reportes después de un breve retraso para asegurar que las acciones se hayan completado
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadReports();
      }
    });
  }

  // El método _buildStatusOption ha sido eliminado ya que ahora se usa ReportActionsDialog

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Filtrar Reportes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categoría',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),

              const SizedBox(height: 16),
              const Text(
                'Rango de Fechas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Desde',
                      value: _startDate,
                      onTap: () => _selectDate(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'Hasta',
                      value: _endDate,
                      onTap: () => _selectDate(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              PriorityFilter(
                initialPriority: _minPriority,
                onPriorityChanged: (priority) {
                  setState(() {
                    _minPriority = priority;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedCategory = null;
                _startDate = null;
                _endDate = null;
                _minPriority = null;
              });
              _loadReports();
            },
            child: const Text('Limpiar Filtros'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadReports();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF612232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<ReportCategory?>(
      value: _selectedCategory,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withAlpha(80)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withAlpha(80)),
        ),
      ),
      items: [
        const DropdownMenuItem<ReportCategory?>(
          value: null,
          child: Text('Todas las categorías'),
        ),
        ...ReportCategory.values.map(
          (category) => DropdownMenuItem<ReportCategory>(
            value: category,
            child: Text(_getCategoryName(category)),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withAlpha(80)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withAlpha(80)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? '${value.day}/${value.month}/${value.year}'
                  : 'Seleccionar',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF612232),
              onPrimary: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return 'Bacheo';
      case ReportCategory.garbageCollection:
        return 'Recolección de basura';
      case ReportCategory.streetImprovement:
        return 'Mejoramiento de la Imagen Urbana';
    }
  }
}
