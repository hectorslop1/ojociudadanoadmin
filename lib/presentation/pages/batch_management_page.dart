import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/batch_selection_card.dart';

class BatchManagementPage extends StatefulWidget {
  const BatchManagementPage({super.key});

  @override
  State<BatchManagementPage> createState() => _BatchManagementPageState();
}

class _BatchManagementPageState extends State<BatchManagementPage> {
  final Set<String> _selectedReportIds = {};
  ReportStatus? _filterStatus;
  ReportCategory? _filterCategory;
  int? _filterMinPriority;
  String? _filterDelegationId;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    context.read<ReportsBloc>().add(
      LoadReportsEvent(
        status: _filterStatus,
        category: _filterCategory,
        minPriority: _filterMinPriority,
        delegationId: _filterDelegationId,
      ),
    );
  }

  void _toggleReportSelection(String reportId) {
    setState(() {
      if (_selectedReportIds.contains(reportId)) {
        _selectedReportIds.remove(reportId);
      } else {
        _selectedReportIds.add(reportId);
      }
    });
  }

  void _selectAll(List<Report> reports) {
    setState(() {
      _selectedReportIds.addAll(reports.map((r) => r.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedReportIds.clear();
    });
  }

  void _showBatchActionsBottomSheet(
    BuildContext context,
    List<Report> selectedReports,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BatchActionsBottomSheet(
        selectedReports: selectedReports,
        onUpdatePriority: _updatePriority,
        onAssignTechnician: _assignTechnician,
        onUpdateStatus: _updateStatus,
      ),
    );
  }

  void _updatePriority(List<Report> reports, int priority) {
    // Implementar la actualización de prioridad por lotes
    for (final report in reports) {
      context.read<ReportsBloc>().add(
        UpdateReportPriorityEvent(reportId: report.id, priority: priority),
      );
    }

    Navigator.pop(context); // Cerrar el bottom sheet
    _showSuccessSnackBar(
      'Prioridad actualizada para ${reports.length} reportes',
    );
    _loadReports(); // Recargar los reportes
  }

  void _assignTechnician(List<Report> reports, String technicianId) {
    // Implementar la asignación de técnico por lotes
    for (final report in reports) {
      context.read<ReportsBloc>().add(
        AssignReportEvent(reportId: report.id, technicianId: technicianId),
      );
    }

    Navigator.pop(context); // Cerrar el bottom sheet
    _showSuccessSnackBar('Técnico asignado a ${reports.length} reportes');
    _loadReports(); // Recargar los reportes
  }

  void _updateStatus(List<Report> reports, ReportStatus status) {
    // Implementar la actualización de estado por lotes
    for (final report in reports) {
      context.read<ReportsBloc>().add(
        UpdateReportStatusEvent(reportId: report.id, status: status),
      );
    }

    Navigator.pop(context); // Cerrar el bottom sheet
    _showSuccessSnackBar('Estado actualizado para ${reports.length} reportes');
    _loadReports(); // Recargar los reportes
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión por Lotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar reportes',
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsLoaded) {
            final reports = state.reports;

            if (reports.isEmpty) {
              return const Center(child: Text('No hay reportes disponibles'));
            }

            return Column(
              children: [
                // Barra de selección
                _buildSelectionBar(reports),

                // Lista de reportes
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      final isSelected = _selectedReportIds.contains(report.id);

                      return BatchSelectionCard(
                        report: report,
                        isSelected: isSelected,
                        onToggleSelection: () =>
                            _toggleReportSelection(report.id),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
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
      floatingActionButton: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded && _selectedReportIds.isNotEmpty) {
            final selectedReports = state.reports
                .where((r) => _selectedReportIds.contains(r.id))
                .toList();

            return FloatingActionButton.extended(
              onPressed: () =>
                  _showBatchActionsBottomSheet(context, selectedReports),
              label: Text('Acciones (${_selectedReportIds.length})'),
              icon: const Icon(Icons.batch_prediction),
              backgroundColor: Theme.of(context).primaryColor,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSelectionBar(List<Report> reports) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Reportes: ${reports.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Text(
            'Seleccionados: ${_selectedReportIds.length}',
            style: TextStyle(
              color: _selectedReportIds.isNotEmpty
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _selectAll(reports),
            icon: const Icon(Icons.select_all),
            label: const Text('Todos'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _deselectAll,
            icon: const Icon(Icons.deselect),
            label: const Text('Ninguno'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Reportes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado'),
              const SizedBox(height: 8),
              _buildStatusFilter(),
              const SizedBox(height: 16),
              const Text('Categoría'),
              const SizedBox(height: 8),
              _buildCategoryFilter(),
              const SizedBox(height: 16),
              const Text('Prioridad mínima'),
              const SizedBox(height: 8),
              _buildPriorityFilter(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterStatus = null;
                _filterCategory = null;
                _filterMinPriority = null;
                _filterDelegationId = null;
              });
              Navigator.pop(context);
              _loadReports();
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadReports();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<ReportStatus?>(
      value: _filterStatus,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<ReportStatus?>(
          value: null,
          child: Text('Todos'),
        ),
        ...ReportStatus.values.map((status) {
          return DropdownMenuItem<ReportStatus>(
            value: status,
            child: Text(_getStatusName(status)),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _filterStatus = value;
        });
      },
    );
  }

  Widget _buildCategoryFilter() {
    return DropdownButtonFormField<ReportCategory?>(
      value: _filterCategory,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<ReportCategory?>(
          value: null,
          child: Text('Todas'),
        ),
        ...ReportCategory.values.map((category) {
          return DropdownMenuItem<ReportCategory>(
            value: category,
            child: Text(_getCategoryName(category)),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _filterCategory = value;
        });
      },
    );
  }

  Widget _buildPriorityFilter() {
    return DropdownButtonFormField<int?>(
      value: _filterMinPriority,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Todas')),
        for (int i = 1; i <= 5; i++)
          DropdownMenuItem<int>(
            value: i,
            child: Text('≥ ${_getPriorityName(i)}'),
          ),
      ],
      onChanged: (value) {
        setState(() {
          _filterMinPriority = value;
        });
      },
    );
  }

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

  String _getPriorityName(int priority) {
    switch (priority) {
      case 5:
        return 'Crítica';
      case 4:
        return 'Alta';
      case 3:
        return 'Media';
      case 2:
        return 'Baja';
      case 1:
        return 'Muy baja';
      default:
        return 'Sin prioridad';
    }
  }
}

class BatchActionsBottomSheet extends StatefulWidget {
  final List<Report> selectedReports;
  final Function(List<Report>, int) onUpdatePriority;
  final Function(List<Report>, String) onAssignTechnician;
  final Function(List<Report>, ReportStatus) onUpdateStatus;

  const BatchActionsBottomSheet({
    super.key,
    required this.selectedReports,
    required this.onUpdatePriority,
    required this.onAssignTechnician,
    required this.onUpdateStatus,
  });

  @override
  State<BatchActionsBottomSheet> createState() =>
      _BatchActionsBottomSheetState();
}

class _BatchActionsBottomSheetState extends State<BatchActionsBottomSheet> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Prioridad', 'Técnico', 'Estado'];

  // Valores seleccionados
  int? _selectedPriority;
  String? _selectedTechnicianId;
  ReportStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Acciones para ${widget.selectedReports.length} reportes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pestañas
          Row(
            children: List.generate(_tabs.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withAlpha(77),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedTabIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        fontWeight: _selectedTabIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Contenido de la pestaña seleccionada
          _buildTabContent(),

          const SizedBox(height: 16),

          // Botón de acción
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isActionEnabled() ? _performAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(_getActionButtonText()),
            ),
          ),

          // Espacio para el notch en dispositivos con notch
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPriorityTab();
      case 1:
        return _buildTechnicianTab();
      case 2:
        return _buildStatusTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPriorityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona la prioridad a asignar:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(5, (index) {
            final priority = 5 - index; // 5, 4, 3, 2, 1
            final isSelected = _selectedPriority == priority;

            return ChoiceChip(
              label: Text(_getPriorityName(priority)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPriority = selected ? priority : null;
                });
              },
              backgroundColor: _getPriorityColor(priority).withAlpha(26),
              selectedColor: _getPriorityColor(priority).withAlpha(77),
              labelStyle: TextStyle(
                color: isSelected
                    ? _getPriorityColor(priority)
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTechnicianTab() {
    // En una implementación real, obtendríamos los técnicos del repositorio
    // Por ahora, usamos una lista de ejemplo
    final technicians = [
      Technician(
        id: 't1',
        name: 'Carlos Rodríguez',
        email: 'carlos@example.com',
        phone: '5551234567',
        specialties: ['Bacheo', 'Electricista'],
        isActive: true,
        currentWorkload: 3,
        averageResolutionTime: 24.5,
        rating: 4.8,
      ),
      Technician(
        id: 't2',
        name: 'Ana Martínez',
        email: 'ana@example.com',
        phone: '5559876543',
        specialties: ['Plomería', 'Recolección'],
        isActive: true,
        currentWorkload: 2,
        averageResolutionTime: 18.2,
        rating: 4.5,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona el técnico a asignar:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...technicians.map((technician) {
          final isSelected = _selectedTechnicianId == technician.id;

          return ListTile(
            leading: CircleAvatar(child: Text(technician.name.substring(0, 1))),
            title: Text(technician.name),
            subtitle: Text(
              'Especialidades: ${technician.specialties.join(", ")}',
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedTechnicianId = technician.id;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildStatusTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona el estado a asignar:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...ReportStatus.values.map((status) {
          final isSelected = _selectedStatus == status;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status).withAlpha(51),
              child: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
            ),
            title: Text(_getStatusName(status)),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
          );
        }),
      ],
    );
  }

  bool _isActionEnabled() {
    switch (_selectedTabIndex) {
      case 0:
        return _selectedPriority != null;
      case 1:
        return _selectedTechnicianId != null;
      case 2:
        return _selectedStatus != null;
      default:
        return false;
    }
  }

  String _getActionButtonText() {
    switch (_selectedTabIndex) {
      case 0:
        return 'Actualizar prioridad';
      case 1:
        return 'Asignar técnico';
      case 2:
        return 'Actualizar estado';
      default:
        return 'Aplicar';
    }
  }

  void _performAction() {
    switch (_selectedTabIndex) {
      case 0:
        if (_selectedPriority != null) {
          widget.onUpdatePriority(widget.selectedReports, _selectedPriority!);
        }
        break;
      case 1:
        if (_selectedTechnicianId != null) {
          widget.onAssignTechnician(
            widget.selectedReports,
            _selectedTechnicianId!,
          );
        }
        break;
      case 2:
        if (_selectedStatus != null) {
          widget.onUpdateStatus(widget.selectedReports, _selectedStatus!);
        }
        break;
    }
  }

  String _getPriorityName(int priority) {
    switch (priority) {
      case 5:
        return 'Crítica';
      case 4:
        return 'Alta';
      case 3:
        return 'Media';
      case 2:
        return 'Baja';
      case 1:
        return 'Muy baja';
      default:
        return 'Sin prioridad';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.deepOrange;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.blue;
      case ReportStatus.assigned:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.purple;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.hourglass_empty;
      case ReportStatus.assigned:
        return Icons.person_add;
      case ReportStatus.inProgress:
        return Icons.engineering;
      case ReportStatus.resolved:
        return Icons.check_circle;
      case ReportStatus.rejected:
        return Icons.cancel;
    }
  }
}
