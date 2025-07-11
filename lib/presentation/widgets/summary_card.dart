import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? progressValue;
  final String? percentageText;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.progressValue,
    this.percentageText,
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(
                  icon,
                  color: color,
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (percentageText != null)
                  Text(
                    percentageText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            // Siempre mostrar la barra de progreso, con un valor predeterminado si es null
            const SizedBox(height: 12),
            SizedBox(
              height: 8.0, // Aumentar aún más la altura para mayor visibilidad
              child: LinearProgressIndicator(
                value: progressValue ?? 0.5, // Valor predeterminado si es null
                backgroundColor: color.withAlpha((0.2 * 255).round()),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(4.0), // Bordes más redondeados
              ),
            ),
          ],
        ),
      ),
    );
  }
}
