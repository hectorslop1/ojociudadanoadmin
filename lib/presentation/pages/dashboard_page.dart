import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/utils/status_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_state.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/category_distribution_chart.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/delegation_selector.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/map_preview_card.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/performance_metrics_card.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/reports_page.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/resolved_card.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/summary_card.dart';
import 'package:ojo_ciudadano_admin/core/animations/animated_card.dart';
import 'package:ojo_ciudadano_admin/core/animations/animated_list_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _selectedDelegationId;

  @override
  void initState() {
    super.initState();
    // Cargar las delegaciones y estadísticas al iniciar la página
    context.read<DelegationsBloc>().add(const LoadDelegationsEvent(isActive: true));
    context.read<ReportsBloc>().add(const LoadReportStatisticsEvent());
  }
  
  void _onDelegationSelected(String? delegationId) {
    setState(() {
      _selectedDelegationId = delegationId;
    });
    // Recargar las estadísticas con la delegación seleccionada
    context.read<ReportsBloc>().add(LoadReportStatisticsEvent(delegationId: delegationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportStatisticsLoaded) {
            return _buildDashboard(state);
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
                    onPressed: () {
                      context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                    },
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
    );
  }

  // Obtener el nombre de la delegación seleccionada
  String _getDelegationName(String? delegationId) {
    if (delegationId == null) return '';
    
    final delegationsState = context.read<DelegationsBloc>().state;
    if (delegationsState is DelegationsLoaded) {
      final delegation = delegationsState.delegations.firstWhere(
        (d) => d.id == delegationId,
        orElse: () => throw Exception('Delegación no encontrada'),
      );
      return delegation.name;
    }
    return 'Delegación $delegationId';
  }
  
  Widget _buildDashboard(ReportStatisticsLoaded state) {
    // Calcular totales
    final totalReports = state.reportsByStatus.values.fold(0, (sum, count) => sum + count);
    final pendingReports = state.reportsByStatus[ReportStatus.pending] ?? 0;
    final assignedReports = state.reportsByStatus[ReportStatus.assigned] ?? 0;
    final inProgressReports = state.reportsByStatus[ReportStatus.inProgress] ?? 0;
    final resolvedReports = state.reportsByStatus[ReportStatus.resolved] ?? 0;
    
    // Crear una lista de widgets para AnimatedListView
    final dashboardWidgets = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Reportes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Selector de delegación
          Container(
            width: double.infinity,
            child: DelegationSelector(
              onDelegationSelected: _onDelegationSelected,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      
      // Mostrar la delegación seleccionada
      if (state.delegationId != null)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Filtrando por delegación:',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getDelegationName(state.delegationId),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedDelegationId = null;
                      });
                      context.read<ReportsBloc>().add(const LoadReportStatisticsEvent());
                      context.read<DelegationsBloc>().add(ClearSelectedDelegationEvent());
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Limpiar'),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      
      
      // Tarjetas de resumen - Primera fila
      Row(
        children: [
          Expanded(
            child: AnimatedCard(
              elevation: 2,
              pressedElevation: 4,
              scaleOnTap: true,
              pressedScale: 0.98,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Navegar a la página de reportes mostrando todos los reportes
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportsPage(),
                  ),
                ).then((_) {
                  // Recargar las estadísticas al regresar
                  context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                });
              },
              child: SummaryCard(
                title: 'Total',
                value: totalReports.toString(),
                icon: Icons.assignment,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.primary
                    : AppColors.primaryDark,
                progressValue: 1.0,
                percentageText: '100%',
                onTap: () {
                  // Navegar a la página de reportes mostrando todos los reportes
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportsPage(),
                    ),
                  ).then((_) {
                    // Recargar las estadísticas al regresar
                    context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedCard(
              elevation: 2,
              pressedElevation: 4,
              scaleOnTap: true,
              pressedScale: 0.98,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Navegar a la página de reportes mostrando solo los pendientes
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportsPage(
                      initialStatus: ReportStatus.pending,
                    ),
                  ),
                ).then((_) {
                  // Recargar las estadísticas al regresar
                  context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                });
              },
              child: SummaryCard(
                title: StatusUtils.getStatusName(ReportStatus.pending),
                value: pendingReports.toString(),
                icon: StatusUtils.getStatusIcon(ReportStatus.pending),
                color: StatusUtils.getStatusColor(ReportStatus.pending),
                progressValue: totalReports > 0 ? pendingReports / totalReports : 0,
                percentageText: totalReports > 0 ? '${(pendingReports / totalReports * 100).toStringAsFixed(1)}%' : '0%',
                onTap: () {
                  // Navegar a la página de reportes mostrando solo los pendientes
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportsPage(
                        initialStatus: ReportStatus.pending,
                      ),
                    ),
                  ).then((_) {
                    // Recargar las estadísticas al regresar
                    context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                  });
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      
      // Tarjetas de resumen - Segunda fila
      Row(
        children: [
          Expanded(
            child: AnimatedCard(
              elevation: 2,
              pressedElevation: 4,
              scaleOnTap: true,
              pressedScale: 0.98,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Navegar a la página de reportes mostrando los reportes en proceso
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportsPage(
                      initialStatus: ReportStatus.inProgress,
                    ),
                  ),
                ).then((_) {
                  // Recargar las estadísticas al regresar
                  context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                });
              },
              child: SummaryCard(
                title: StatusUtils.getStatusName(ReportStatus.inProgress),
                value: (assignedReports + inProgressReports).toString(),
                icon: StatusUtils.getStatusIcon(ReportStatus.inProgress),
                color: StatusUtils.getStatusColor(ReportStatus.inProgress),
                progressValue: totalReports > 0 ? (assignedReports + inProgressReports) / totalReports : 0,
                percentageText: totalReports > 0 ? '${((assignedReports + inProgressReports) / totalReports * 100).toStringAsFixed(1)}%' : '0%',
                onTap: () {
                  // Navegar a la página de reportes mostrando los reportes en proceso
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportsPage(
                        initialStatus: ReportStatus.inProgress,
                      ),
                    ),
                  ).then((_) {
                    // Recargar las estadísticas al regresar
                    context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedCard(
              elevation: 2,
              pressedElevation: 4,
              scaleOnTap: true,
              pressedScale: 0.98,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Navegar a la página de reportes mostrando los reportes resueltos
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportsPage(
                      initialStatus: ReportStatus.resolved,
                    ),
                  ),
                ).then((_) {
                  // Recargar las estadísticas al regresar
                  context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                });
              },
              child: ResolvedCard(
                value: resolvedReports.toString(),
                percentageText: totalReports > 0 ? '${(resolvedReports / totalReports * 100).toStringAsFixed(1)}%' : '32.6%',
                onTap: () {
                  // Navegar a la página de reportes mostrando los reportes resueltos
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportsPage(
                        initialStatus: ReportStatus.resolved,
                      ),
                    ),
                  ).then((_) {
                    // Recargar las estadísticas al regresar
                    context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
                  });
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      
      // Vista previa del mapa con AnimatedCard
      AnimatedCard(
        elevation: 2,
        pressedElevation: 4,
        scaleOnTap: false,
        borderRadius: BorderRadius.circular(16),
        child: MapPreviewCard(
          reports: state.allReports,
          onReturn: () {
            // Recargar las estadísticas al regresar del mapa
            context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
          },
        ),
      ),
      const SizedBox(height: 24),
      
      // Distribución por categoría
      const Text(
        'Distribución por Categoría',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      AnimatedCard(
        elevation: 2,
        pressedElevation: 4,
        scaleOnTap: false,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 300,
          child: CategoryDistributionChart(
            reportsByCategory: state.reportsByCategory,
            onCategoryTap: (category) {
              // Navegar a la página de reportes filtrada por categoría
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReportsPage(
                    initialCategory: category,
                  ),
                ),
              ).then((_) {
                // Recargar las estadísticas al regresar
                context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
              });
            },
          ),
        ),
      ),
      const SizedBox(height: 24),
      
      // Métricas de rendimiento ampliadas
      if (state.performanceMetrics != null)
        AnimatedCard(
          elevation: 2,
          pressedElevation: 4,
          scaleOnTap: false,
          borderRadius: BorderRadius.circular(12),
          child: PerformanceMetricsCard(
            metrics: state.performanceMetrics!,
          ),
        ),
    ];
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
      },
      child: AnimatedListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemSpacing: 8.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutQuint,
        children: dashboardWidgets,
      ),
    );
  }
}
