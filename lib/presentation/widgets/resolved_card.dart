import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';

class ResolvedCard extends StatelessWidget {
  final String value;
  final String percentageText;

  const ResolvedCard({
    super.key,
    required this.value,
    required this.percentageText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resueltos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  percentageText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barra de progreso con estilo estándar
            Container(
              height: 8.0, // Altura estándar como en SummaryCard
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[200],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calcular el ancho de la barra de progreso
                  final percentage = double.tryParse(percentageText.replaceAll('%', ''))! / 100;
                  return Row(
                    children: [
                      Container(
                        width: constraints.maxWidth * percentage,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
