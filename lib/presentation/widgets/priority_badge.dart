import 'package:flutter/material.dart';

// Clase auxiliar para devolver los datos de prioridad
class PriorityData {
  final Color color;
  final String label;
  final IconData icon;
  
  PriorityData(this.color, this.label, this.icon);
}

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
    final priorityInfo = _getPriorityInfo();
    final color = priorityInfo.color;
    final label = priorityInfo.label;
    final icon = priorityInfo.icon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(80),  // Aún más opaco para mejor visibilidad
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2.0),  // Borde más grueso
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                fontWeight: FontWeight.w800,
                fontSize: size * 0.55,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoPriorityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                fontWeight: FontWeight.w800,
                fontSize: size * 0.55,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  PriorityData _getPriorityInfo() {
    switch (priority) {
      case 5:
        return PriorityData(Colors.red, 'Crítica', Icons.priority_high);
      case 4:
        return PriorityData(Colors.deepOrange, 'Alta', Icons.arrow_upward);
      case 3:
        return PriorityData(Colors.amber, 'Media', Icons.remove);
      case 2:
        return PriorityData(Colors.blue, 'Baja', Icons.arrow_downward);
      case 1:
        return PriorityData(Colors.green, 'Muy baja', Icons.keyboard_double_arrow_down);
      default:
        return PriorityData(Colors.grey, 'Sin prioridad', Icons.remove_circle_outline);
    }
  }
}
