import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/animations/animated_list_view.dart';
import 'package:ojo_ciudadano_admin/core/animations/animated_card.dart';
import 'package:ojo_ciudadano_admin/core/utils/status_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/report_detail_page.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/priority_badge.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/priority_filter.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  String _formatTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'es');
  }

  IconData _getStatusIcon(ReportStatus status) {
    return StatusUtils.getStatusIcon(status);
  }

  String _getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return 'Bacheo';
      case ReportCategory.garbageCollection:
        return 'Recolección de basura';
      case ReportCategory.streetImprovement:
        return 'Mejoramiento de calles';
    }
  }

  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return Icons.construction_outlined;
      case ReportCategory.garbageCollection:
        return Icons.delete_outline;
      case ReportCategory.streetImprovement:
        return Icons.home_repair_service;
    }
  }

  Color _getCategoryColor(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return const Color(0xFF795548); // Marrón
      case ReportCategory.garbageCollection:
        return const Color(0xFF4CAF50); // Verde
      case ReportCategory.streetImprovement:
        return const Color(0xFF3F51B5); // Índigo
    }
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
                  return const Center(child: CircularProgressIndicator());
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
                    default: // Todos
                      filteredReports = reports;
                  }

                  if (filteredReports.isEmpty) {
                    return const Center(
                      child: Text('No hay reportes disponibles'),
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
                        .map((report) => _buildReportCard(report))
                        .toList(),
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
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                          ), // Error color
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

  Widget _buildReportCard(Report report) {
    // Determinar el texto del estado y colores usando StatusUtils
    String statusText = StatusUtils.getStatusName(report.status);
    Color badgeColor = StatusUtils.getStatusBackgroundColor(report.status);
    Color textColor = StatusUtils.getStatusColor(report.status);

    // Usamos la prioridad real del reporte si está disponible

    return AnimatedCard(
      elevation: 2,
      pressedElevation: 4,
      scaleOnTap: true,
      pressedScale: 0.98,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
      shadowColor: Colors.black.withAlpha(26),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                    border: report.status == ReportStatus.pending
                        ? Border.all(
                            color: textColor,
                            width: 1,
                          ) // Borde para abierto
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

                // Prioridad usando el nuevo widget PriorityBadge
                PriorityBadge(priority: report.priority, size: 20),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Hace ${_formatTimeAgo(report.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                const Spacer(),

                // Categoría
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      (_getCategoryColor(report.category).r * 255.0).round() &
                          0xff,
                      (_getCategoryColor(report.category).g * 255.0).round() &
                          0xff,
                      (_getCategoryColor(report.category).b * 255.0).round() &
                          0xff,
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color.fromRGBO(
                        (_getCategoryColor(report.category).r * 255.0).round() &
                            0xff,
                        (_getCategoryColor(report.category).g * 255.0).round() &
                            0xff,
                        (_getCategoryColor(report.category).b * 255.0).round() &
                            0xff,
                        0.3,
                      ),
                      width: 1,
                    ),
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
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withAlpha(26),
            ), // 0.1 * 255 = ~26
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  _showChangeStatusDialog(report);
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Color(0xFF8E24AA),
                ),
                label: const Text(
                  'Cambiar Estado',
                  style: TextStyle(
                    color: Color(0xFF8E24AA),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cambiar Estado',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(report, ReportStatus.pending, StatusUtils.getStatusName(ReportStatus.pending)),
            _buildStatusOption(report, ReportStatus.assigned, StatusUtils.getStatusName(ReportStatus.assigned)),
            _buildStatusOption(report, ReportStatus.inProgress, StatusUtils.getStatusName(ReportStatus.inProgress)),
            _buildStatusOption(report, ReportStatus.resolved, StatusUtils.getStatusName(ReportStatus.resolved)),
            _buildStatusOption(report, ReportStatus.rejected, StatusUtils.getStatusName(ReportStatus.rejected)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(Report report, ReportStatus status, String label) {
    final bool isSelected = report.status == status;
    final Color textColor = isSelected
        ? const Color(0xFF612232)
        : Colors.black87;
    final String statusName = StatusUtils.getStatusName(status);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Aquí iría la lógica para cambiar el estado del reporte
        // context.read<ReportsBloc>().add(UpdateReportStatusEvent(reportId: report.id, status: status));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(97, 34, 50, 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statusName,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF612232),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

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
}
