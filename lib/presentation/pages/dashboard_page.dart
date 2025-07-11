import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/category_distribution_chart.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/map_preview_card.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/resolved_card.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/summary_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Cargar las estadísticas al iniciar la página
    context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
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

  Widget _buildDashboard(ReportStatisticsLoaded state) {
    // Calcular totales
    final totalReports = state.reportsByStatus.values.fold(0, (sum, count) => sum + count);
    final pendingReports = state.reportsByStatus[ReportStatus.pending] ?? 0;
    final assignedReports = state.reportsByStatus[ReportStatus.assigned] ?? 0;
    final inProgressReports = state.reportsByStatus[ReportStatus.inProgress] ?? 0;
    final resolvedReports = state.reportsByStatus[ReportStatus.resolved] ?? 0;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Reportes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tarjetas de resumen
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total',
                    value: totalReports.toString(),
                    icon: Icons.assignment,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.primary
                        : AppColors.primaryDark,
                    progressValue: 1.0,
                    percentageText: '100%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Pendientes',
                    value: pendingReports.toString(),
                    icon: Icons.hourglass_empty,
                    color: AppColors.warning,
                    progressValue: totalReports > 0 ? pendingReports / totalReports : 0,
                    percentageText: totalReports > 0 ? '${(pendingReports / totalReports * 100).toStringAsFixed(1)}%' : '0%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'En Proceso',
                    value: (assignedReports + inProgressReports).toString(),
                    icon: Icons.engineering,
                    color: AppColors.info,
                    progressValue: totalReports > 0 ? (assignedReports + inProgressReports) / totalReports : 0,
                    percentageText: totalReports > 0 ? '${((assignedReports + inProgressReports) / totalReports * 100).toStringAsFixed(1)}%' : '0%',
                  ),
                ),
                const SizedBox(width: 16),
                // Usar el widget ResolvedCard específico para el indicador "Resueltos"
                Expanded(
                  child: ResolvedCard(
                    value: resolvedReports.toString(),
                    percentageText: totalReports > 0 ? '${(resolvedReports / totalReports * 100).toStringAsFixed(1)}%' : '32.6%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Vista previa del mapa
            MapPreviewCard(
              reports: state.allReports,
              onReturn: () {
                // Recargar las estadísticas al regresar del mapa
                context.read<ReportsBloc>().add(LoadReportStatisticsEvent());
              },
            ),
            const SizedBox(height: 24),
            
            // Tiempo promedio de resolución
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiempo Promedio de Resolución',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.averageResolutionTime.toStringAsFixed(1)} horas',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.primary
                                    : AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              '${(state.averageResolutionTime / 24).toStringAsFixed(1)} días',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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
            SizedBox(
              height: 300,
              child: CategoryDistributionChart(reportsByCategory: state.reportsByCategory),
            ),
          ],
        ),
      ),
    );
  }
}
