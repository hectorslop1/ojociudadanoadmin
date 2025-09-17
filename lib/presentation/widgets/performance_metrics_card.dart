import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';

class PerformanceMetricsCard extends StatelessWidget {
  final Map<String, double> metrics;
  final bool isLoading;

  const PerformanceMetricsCard({
    super.key,
    required this.metrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas de Rendimiento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            context,
            'Tiempo de Respuesta',
            '${metrics['averageResponseTime']?.toStringAsFixed(1) ?? '0.0'} horas',
            Icons.timer_outlined,
            AppColors.info,
          ),
          const Divider(),
          _buildMetricRow(
            context,
            'Tasa de Resolución',
            '${(metrics['resolutionRate'] ?? 0.0 * 100).toStringAsFixed(1)}%',
            Icons.check_circle_outline,
            AppColors.success,
          ),
          const Divider(),
          _buildMetricRow(
            context,
            'Reportes Pendientes',
            '${(metrics['pendingRate'] ?? 0.0 * 100).toStringAsFixed(1)}%',
            Icons.pending_outlined,
            AppColors.warning,
          ),
          const Divider(),
          _buildMetricRow(
            context,
            'Satisfacción Ciudadana',
            '${metrics['satisfactionRating']?.toStringAsFixed(1) ?? '0.0'}/5.0',
            Icons.sentiment_satisfied_alt_outlined,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas de Rendimiento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
