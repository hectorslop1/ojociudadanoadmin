import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';

class TechnicianAssignmentDialog extends StatefulWidget {
  final String reportId;

  const TechnicianAssignmentDialog({
    super.key,
    required this.reportId,
  });

  @override
  State<TechnicianAssignmentDialog> createState() => _TechnicianAssignmentDialogState();
}

class _TechnicianAssignmentDialogState extends State<TechnicianAssignmentDialog> {
  String? _selectedTechnicianId;
  bool _isLoading = true;
  String? _errorMessage;
  List<Technician> _technicians = [];
  String? _filterSpecialty;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    // En una implementación real, aquí se cargarían los técnicos desde el repositorio
    // Por ahora, simulamos una carga con datos de ejemplo
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _technicians = [
        Technician(
          id: '1',
          name: 'Juan Pérez',
          email: 'juan.perez@ejemplo.com',
          phone: '555-123-4567',
          profileImageUrl: 'https://via.placeholder.com/150',
          specialties: [
            'Electricista',
            'Bacheo',
          ],
          isActive: true,
          currentWorkload: 3,
          averageResolutionTime: 24.5,
          rating: 4.5,
          lastKnownLatitude: 31.871170,
          lastKnownLongitude: -116.607612,
        ),
        Technician(
          id: '2',
          name: 'María López',
          email: 'maria.lopez@ejemplo.com',
          phone: '555-765-4321',
          profileImageUrl: 'https://via.placeholder.com/150',
          specialties: [
            'Plomería',
            'Recolección',
          ],
          isActive: true,
          currentWorkload: 2,
          averageResolutionTime: 18.3,
          rating: 4.8,
          lastKnownLatitude: 31.872170,
          lastKnownLongitude: -116.608612,
        ),
        Technician(
          id: '3',
          name: 'Carlos Rodríguez',
          email: 'carlos.rodriguez@ejemplo.com',
          phone: '555-987-6543',
          profileImageUrl: 'https://via.placeholder.com/150',
          specialties: [
            'Recolección',
            'Accesibilidad',
          ],
          isActive: true,
          currentWorkload: 5,
          averageResolutionTime: 36.7,
          rating: 4.2,
          lastKnownLatitude: 31.873170,
          lastKnownLongitude: -116.609612,
        ),
        Technician(
          id: '4',
          name: 'Ana Martínez',
          email: 'ana.martinez@ejemplo.com',
          phone: '555-456-7890',
          profileImageUrl: 'https://via.placeholder.com/150',
          specialties: [
            'Seguridad',
            'Semáforos',
          ],
          isActive: true,
          currentWorkload: 1,
          averageResolutionTime: 12.8,
          rating: 4.9,
          lastKnownLatitude: 31.874170,
          lastKnownLongitude: -116.610612,
        ),
        Technician(
          id: '5',
          name: 'Roberto Gómez',
          email: 'roberto.gomez@ejemplo.com',
          phone: '555-234-5678',
          profileImageUrl: 'https://via.placeholder.com/150',
          specialties: [
            'Protección Animal',
            'General',
          ],
          isActive: false, // De vacaciones
          currentWorkload: 0,
          averageResolutionTime: 20.1,
          rating: 4.3,
          lastKnownLatitude: 31.875170,
          lastKnownLongitude: -116.611612,
        ),
      ];
    });
  }

  List<Technician> get _filteredTechnicians {
    if (_filterSpecialty == null) {
      return _technicians.where((tech) => tech.isActive).toList();
    }
    return _technicians
        .where((tech) => tech.isActive && (_filterSpecialty == null || tech.specialties.contains(_filterSpecialty)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar Técnico'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro por especialidad
            ElevatedButton(
              onPressed: _showFilterDialog,
              child: const Text('Filtrar por especialidad'),
            ),
            const SizedBox(height: 16),
            
            // Lista de técnicos
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTechnicians,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredTechnicians.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay técnicos disponibles con esta especialidad',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredTechnicians.length,
                  itemBuilder: (context, index) {
                    final technician = _filteredTechnicians[index];
                    return RadioListTile<String>(
                      title: Text(
                        technician.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Especialidades: ${technician.specialties.join(", ")}',
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.work,
                                size: 16,
                                color: _getWorkloadColor(technician.currentWorkload),
                              ),
                              const SizedBox(width: 4),
                              Text('Carga: ${technician.currentWorkload} reportes'),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text('Calificación: ${technician.rating.toStringAsFixed(1)}/5.0'),
                            ],
                          ),
                        ],
                      ),
                      value: technician.id,
                      groupValue: _selectedTechnicianId,
                      onChanged: (value) {
                        setState(() {
                          _selectedTechnicianId = value;
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundImage: technician.profileImageUrl != null
                            ? NetworkImage(technician.profileImageUrl!)
                            : null,
                        child: technician.profileImageUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedTechnicianId == null
              ? null
              : () {
                  context.read<ReportsBloc>().add(
                    AssignReportEvent(
                      reportId: widget.reportId,
                      technicianId: _selectedTechnicianId!,
                    ),
                  );
                  Navigator.of(context).pop();
                },
          child: const Text('Asignar'),
        ),
      ],
    );
  }

  Color _getWorkloadColor(int workload) {
    if (workload <= 2) {
      return AppColors.success;
    } else if (workload <= 4) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por especialidad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String?>(
                title: const Text('Todas'),
                value: null,
                groupValue: _filterSpecialty,
                onChanged: (value) {
                  setState(() {
                    _filterSpecialty = value;
                  });
                  Navigator.pop(context);
                },
              ),
              // Lista de especialidades comunes
              ...[
                'Bacheo',
                'Electricista',
                'Plomería',
                'Recolección',
                'Señalización',
                'Tránsito',
                'Seguridad',
                'Protección Animal',
              ].map((specialty) {
                return RadioListTile<String>(
                  title: Text(specialty),
                  value: specialty,
                  groupValue: _filterSpecialty,
                  onChanged: (value) {
                    setState(() {
                      _filterSpecialty = value;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
