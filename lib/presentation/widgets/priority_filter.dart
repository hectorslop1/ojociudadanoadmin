import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/priority_badge.dart';

class PriorityFilter extends StatefulWidget {
  final int? initialPriority;
  final Function(int?)? onPriorityChanged;

  const PriorityFilter({
    super.key,
    this.initialPriority,
    this.onPriorityChanged,
  });

  @override
  State<PriorityFilter> createState() => _PriorityFilterState();
}

class _PriorityFilterState extends State<PriorityFilter> {
  int? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialPriority;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Filtrar por prioridad mínima',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPriorityFilterChip(null),
              _buildPriorityFilterChip(1),
              _buildPriorityFilterChip(2),
              _buildPriorityFilterChip(3),
              _buildPriorityFilterChip(4),
              _buildPriorityFilterChip(5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityFilterChip(int? priority) {
    final isSelected = _selectedPriority == priority;
    final label = priority == null
        ? 'Todas'
        : priority == 1
        ? 'Todas'
        : '≥ ${_getPriorityLabel(priority)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        selected: isSelected,
        label: priority == null
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  if (priority > 1) ...[
                    const SizedBox(width: 4),
                    PriorityBadge(
                      priority: priority,
                      size: 16,
                      showLabel: false,
                    ),
                  ],
                ],
              ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedPriority = priority;
            });

            if (widget.onPriorityChanged != null) {
              widget.onPriorityChanged!(priority);
            } else {
              // Si no se proporciona un callback, usar el BLoC directamente
              if (priority != null && priority > 1) {
                context.read<ReportsBloc>().add(
                  FilterReportsByPriorityEvent(minPriority: priority),
                );
              } else {
                context.read<ReportsBloc>().add(const LoadReportsEvent());
              }
            }
          }
        },
        backgroundColor: Colors.grey.withAlpha(26),
        selectedColor: Theme.of(context).colorScheme.primary.withAlpha(51),
        checkmarkColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  String _getPriorityLabel(int? priority) {
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
        return 'Todas';
    }
  }
}
