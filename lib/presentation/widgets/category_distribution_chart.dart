import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/utils/category_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class CategoryDistributionChart extends StatelessWidget {
  final Map<ReportCategory, int> reportsByCategory;

  const CategoryDistributionChart({
    super.key,
    required this.reportsByCategory,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el total de reportes
    final total = reportsByCategory.values.fold(0, (sum, count) => sum + count);
    
    // Utilizamos CategoryUtils para obtener nombres e iconos consistentes
    
    // Ordenar categorías por cantidad de reportes (de mayor a menor)
    final sortedCategories = reportsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Ahora usamos CategoryUtils para los colores
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barras horizontales para cada categoría
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  final entry = sortedCategories[index];
                  final category = entry.key;
                  final count = entry.value;
                  final percentage = total > 0 ? count / total * 100 : 0;
                  final color = CategoryUtils.getColorForCategory(category, context: context);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color.withAlpha(51), // 0.2 * 255 = 51
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CategoryUtils.getIconForCategory(category),
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                CategoryUtils.getCategoryName(category),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count (${percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: color,
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
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
