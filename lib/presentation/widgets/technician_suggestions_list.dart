import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/technician_repository.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/suggest_technicians_usecase.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/technician_suggestion_card.dart';
import 'package:get_it/get_it.dart';

class TechnicianSuggestionsList extends StatefulWidget {
  final Report report;
  final Function(Technician) onTechnicianAssigned;

  const TechnicianSuggestionsList({
    super.key,
    required this.report,
    required this.onTechnicianAssigned,
  });

  @override
  State<TechnicianSuggestionsList> createState() =>
      _TechnicianSuggestionsListState();
}

class _TechnicianSuggestionsListState extends State<TechnicianSuggestionsList> {
  final SuggestTechniciansUseCase _suggestTechniciansUseCase =
      GetIt.instance<SuggestTechniciansUseCase>();
  List<Technician>? _suggestedTechnicians;
  bool _isLoading = true;
  String? _errorMessage;
  Technician? _assignedTechnician;

  @override
  void initState() {
    super.initState();
    _loadSuggestedTechnicians();
  }

  Future<void> _loadSuggestedTechnicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Intentar obtener técnicos sugeridos para el reporte específico
      final result = await _suggestTechniciansUseCase(widget.report.id);

      result.fold(
        (failure) {
          // Si hay un error al obtener el reporte, intentar obtener todos los técnicos disponibles
          if (failure.message.contains('Reporte no encontrado') ||
              failure.message.contains('no rows returned')) {
            _loadAllAvailableTechnicians();
          } else {
            setState(() {
              _errorMessage = failure.message;
              _isLoading = false;
            });
          }
        },
        (technicians) {
          setState(() {
            _suggestedTechnicians = technicians;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      // Si hay una excepción, intentar obtener todos los técnicos disponibles
      if (e.toString().contains('Reporte no encontrado') ||
          e.toString().contains('no rows returned')) {
        _loadAllAvailableTechnicians();
      } else {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Método para cargar todos los técnicos disponibles cuando no se encuentra el reporte
  Future<void> _loadAllAvailableTechnicians() async {
    try {
      // Obtener todos los técnicos del repositorio
      final technicianRepository = GetIt.instance<TechnicianRepository>();
      final result = await technicianRepository.getTechnicians();

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (technicians) {
          // Filtrar solo los técnicos disponibles
          final availableTechnicians = technicians
              .where((t) => t.isAvailable)
              .toList();

          // Ordenar por algún criterio simple (por ejemplo, calificación)
          availableTechnicians.sort((a, b) {
            // Usar 0.0 como valor predeterminado si rating es null
            double ratingA = 0.0;
            double ratingB = 0.0;

            ratingA = a.rating!;
            ratingB = b.rating!;

            return ratingB.compareTo(ratingA);
          });

          setState(() {
            _suggestedTechnicians = availableTechnicians;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar técnicos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _assignTechnician(Technician technician) {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar asignación'),
        content: Text(
          '¿Estás seguro de asignar este reporte a ${technician.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAssignTechnician(technician);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  void _confirmAssignTechnician(Technician technician) {
    // Asignar el técnico al reporte
    context.read<ReportsBloc>().add(
      AssignReportEvent(
        reportId: widget.report.id,
        technicianId: technician.id,
      ),
    );

    // Actualizar la UI
    setState(() {
      _assignedTechnician = technician;
    });

    // Notificar al widget padre
    widget.onTechnicianAssigned(technician);

    // Mostrar snackbar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reporte asignado a ${technician.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      // Si el error es "Reporte no encontrado", cargar todos los técnicos disponibles
      if (_errorMessage!.contains('Reporte no encontrado') ||
          _errorMessage!.contains('no rows returned')) {
        // Cargar técnicos disponibles en segundo plano
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadAllAvailableTechnicians();
        });

        // Mostrar indicador de carga mientras se obtienen los técnicos
        return const Center(child: CircularProgressIndicator());
      }

      // Para otros errores, mostrar mensaje de error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSuggestedTechnicians,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_suggestedTechnicians == null || _suggestedTechnicians!.isEmpty) {
      return const Center(
        child: Text('No hay técnicos disponibles para sugerir.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Técnicos sugeridos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Basado en especialidad, carga de trabajo, proximidad y eficiencia',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _suggestedTechnicians!.length,
            itemBuilder: (context, index) {
              final technician = _suggestedTechnicians![index];
              final isAssigned = _assignedTechnician?.id == technician.id;

              return TechnicianSuggestionCard(
                technician: technician,
                rank: index + 1,
                onAssign: () => _assignTechnician(technician),
                isAssigned: isAssigned,
              );
            },
          ),
        ),
      ],
    );
  }
}
