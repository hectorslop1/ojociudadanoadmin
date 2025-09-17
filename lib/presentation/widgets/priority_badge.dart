import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final int? priority;
  final double size;
  final bool showLabel;
  final bool showIcon;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.size = 24.0,
    this.showLabel = true,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay prioridad, mostrar un indicador de "sin prioridad"
    if (priority == null) {
      return _buildNoPriorityBadge(context);
    }

    // Obtener el color y el texto según la prioridad
    final (color, label, icon) = _getPriorityInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, color: color, size: size * 0.6),
            const SizedBox(width: 4),
          ],
          if (showLabel)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoPriorityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(77), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: size * 0.6,
            ),
            const SizedBox(width: 4),
          ],
          if (showLabel)
            Text(
              'Sin prioridad',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: size * 0.5,
              ),
            ),
        ],
      ),
    );
  }

  (Color, String, IconData) _getPriorityInfo() {
    switch (priority) {
      case 5:
        return (Colors.red, 'Crítica', Icons.priority_high);
      case 4:
        return (Colors.deepOrange, 'Alta', Icons.arrow_upward);
      case 3:
        return (Colors.amber, 'Media', Icons.remove);
      case 2:
        return (Colors.blue, 'Baja', Icons.arrow_downward);
      case 1:
        return (Colors.green, 'Muy baja', Icons.keyboard_double_arrow_down);
      default:
        return (Colors.grey, 'Sin prioridad', Icons.remove_circle_outline);
    }
  }
}
