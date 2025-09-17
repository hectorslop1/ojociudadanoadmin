import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/utils/category_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/citizen.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/enhanced_evidence_gallery.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/evidence_categorization.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/status_badge.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/technician_assignment_dialog.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/technician_suggestions_list.dart';

class ReportDetailPage extends StatefulWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  @override
  void initState() {
    super.initState();
    // Cargar los detalles del reporte
    context.read<ReportsBloc>().add(
      LoadReportDetailsEvent(reportId: widget.reportId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        centerTitle: true,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportDetailsLoaded) {
            final report = state.report;
            return _buildReportDetails(report);
          } else if (state is ReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.error
                        : AppColors.errorDark,
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
                      context.read<ReportsBloc>().add(
                        LoadReportDetailsEvent(reportId: widget.reportId),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else {
            // Simulamos un reporte para mostrar la interfaz
            // En una implementación real, esto no sería necesario
            final mockReport = Report(
              id: widget.reportId,
              title: 'Bache profundo en avenida principal',
              category: ReportCategory.roadRepair,
              latitude: 19.432608,
              longitude: -99.133209,
              address: 'Av. Paseo de la Reforma 222, Juárez, CDMX',
              description: 'Bache profundo que causa daños a los vehículos',
              evidenceUrls: [
                'https://via.placeholder.com/500x300?text=Evidencia+1',
                'https://via.placeholder.com/500x300?text=Evidencia+2',
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 2)),

              citizen: Citizen(
                id: 'mock-citizen-id',
                name: 'Ciudadano Ejemplo',
                email: 'ciudadano@ejemplo.com',
                phone: '555-123-4567',
                registeredAt: DateTime.now().subtract(const Duration(days: 30)),
              ),
              status: ReportStatus.pending,
              assignedTechnician: null,
              resolutionNotes: '',
            );

            return _buildReportDetails(mockReport);
          }
        },
      ),
    );
  }

  Widget _buildReportDetails(Report report) {
    // Obtener el nombre de la categoría
    String categoryName = _getCategoryName(report.category);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de información principal
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: ${report.id}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[600]
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                      StatusBadge(status: report.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  Row(
                    children: [
                      Icon(
                        CategoryUtils.getIconForCategory(report.category),
                        size: 20,
                        color: CategoryUtils.getColorForCategory(
                          report.category,
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Categoría: $categoryName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Descripción
                  const Text(
                    'Descripción:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.description,
                    style: const TextStyle(fontSize: 16),
                    softWrap: true,
                  ),
                  const SizedBox(height: 12),

                  // Ubicación
                  Text(
                    'Ubicación:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.primary
                            : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.address,
                          style: const TextStyle(fontSize: 16),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${report.latitude.toStringAsFixed(6)}, Lng: ${report.longitude.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Fechas
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha de creación:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatDate(report.createdAt),
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey[600]
                                    : AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha de asignación:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              report.assignedAt != null
                                  ? _formatDate(report.assignedAt!)
                                  : 'No asignado',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey[600]
                                    : AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información del ciudadano
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Ciudadano',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: report.citizen.profileImageUrl != null
                            ? NetworkImage(report.citizen.profileImageUrl!)
                            : null,
                        child: report.citizen.profileImageUrl == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.citizen.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Email: ${report.citizen.email ?? 'No disponible'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (report.citizen.phone != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Teléfono: ${report.citizen.phone}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Técnico asignado
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text(
                        'Técnico Asignado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (report.status == ReportStatus.pending)
                        ElevatedButton.icon(
                          onPressed: () {
                            _showSuggestedTechniciansDialog(context, report);
                          },
                          icon: const Icon(Icons.recommend, size: 16),
                          label: const Text('Sugerir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
                                ? AppColors.primary
                                : AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.assignedTechnician != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              report.assignedTechnician!.profileImageUrl != null
                              ? NetworkImage(
                                  report.assignedTechnician!.profileImageUrl!,
                                )
                              : null,
                          child:
                              report.assignedTechnician!.profileImageUrl == null
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.assignedTechnician!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Email: ${report.assignedTechnician!.email}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Especialidades: ${report.assignedTechnician!.specialties.join(", ")}',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Calificación: ${report.assignedTechnician!.rating.toStringAsFixed(1)}/5.0',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No hay técnico asignado',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.grey
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Evidencias
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text(
                        'Evidencias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (report.evidenceUrls.isNotEmpty)
                        TextButton.icon(
                          icon: const Icon(Icons.category, size: 16),
                          label: const Text('Categorizar'),
                          onPressed: () =>
                              _showCategorizationDialog(context, report),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.evidenceUrls.isNotEmpty) ...[
                    EnhancedEvidenceGallery(
                      evidenceUrls: report.evidenceUrls,
                      report: report,
                      showCategories: true,
                      allowDownload: true,
                    ),
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No hay evidencias disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.grey
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notas de resolución
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text(
                        'Notas de Resolución',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (report.status != ReportStatus.resolved &&
                          report.status != ReportStatus.rejected)
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddNotesDialog(context, report);
                          },
                          icon: const Icon(Icons.note_add, size: 16),
                          label: const Text('Agregar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
                                ? AppColors.primary
                                : AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.resolutionNotes != null &&
                      report.resolutionNotes!.isNotEmpty) ...[
                    Text(
                      report.resolutionNotes ?? '',
                      style: const TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No hay notas de resolución',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.grey
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botones de acción
          if (report.status != ReportStatus.resolved &&
              report.status != ReportStatus.rejected) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showUpdateStatusDialog(context, report);
                },
                icon: const Icon(Icons.update, size: 18),
                label: const Text('Actualizar Estado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                      ? AppColors.primary
                      : AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAssignTechnicianDialog(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (context) => TechnicianAssignmentDialog(reportId: report.id),
    );
  }

  void _showSuggestedTechniciansDialog(BuildContext context, Report report) {
    // Primero verificamos si el reporte existe en la base de datos
    context.read<ReportsBloc>().add(LoadReportDetailsEvent(reportId: report.id));
    
    // Mostramos el diálogo con los técnicos disponibles
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ReportDetailsLoaded) {
                // Si el reporte se cargó correctamente, mostrar la lista de técnicos sugeridos
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Asignación Inteligente',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: TechnicianSuggestionsList(
                        report: state.report, // Usamos el reporte cargado del estado
                        onTechnicianAssigned: (Technician technician) {
                          Navigator.pop(context);
                          // Recargar los detalles del reporte para mostrar el técnico asignado
                          context.read<ReportsBloc>().add(
                            LoadReportDetailsEvent(reportId: report.id),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is ReportsError) {
                // Si hay un error, mostrar un mensaje amigable y opciones para el usuario
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Asignación Inteligente',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo cargar la información del reporte',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Por favor, verifica que el reporte exista e intenta nuevamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Recargar los detalles del reporte
                        context.read<ReportsBloc>().add(
                          LoadReportDetailsEvent(reportId: report.id),
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                );
              } else {
                // Estado inicial o desconocido
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Asignación Inteligente',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showCategorizationDialog(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categorizar Evidencias',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Selecciona una evidencia para categorizar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: report.evidenceUrls.length,
                  itemBuilder: (context, index) {
                    final url = report.evidenceUrls[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showSingleEvidenceCategorization(context, url, report);
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildEvidenceThumbnail(url),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'O categoriza todas las evidencias a la vez:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showBulkCategorizationDialog(context, report);
                  },
                  icon: const Icon(Icons.category),
                  label: const Text('Categorización por lotes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceThumbnail(String url) {
    final isVideo =
        url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');

    if (isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(
                Icons.movie_outlined,
                size: 30,
                color: Colors.white70,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(179),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image, size: 30, color: Colors.grey),
            ),
          );
        },
      );
    }
  }

  void _showSingleEvidenceCategorization(
    BuildContext context,
    String evidenceUrl,
    Report report,
  ) {
    // En una implementación real, aquí se cargarían las categorías existentes para esta evidencia
    final List<String> initialCategories = [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categorizar Evidencia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              SingleChildScrollView(
                child: EvidenceCategorization(
                  evidenceUrl: evidenceUrl,
                  availableCategories: PredefinedEvidenceCategories.categories,
                  initialCategories: initialCategories,
                  onCategoriesChanged: (categories) {
                    // En una implementación real, aquí se guardarían las categorías
                    print('Categorías seleccionadas: $categories');
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkCategorizationDialog(BuildContext context, Report report) {
    // En una implementación real, aquí se cargarían las categorías existentes
    final List<String> initialCategories = [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categorización por Lotes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Las categorías seleccionadas se aplicarán a todas las evidencias:',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PredefinedEvidenceCategories.categories.map((
                  category,
                ) {
                  final isSelected = initialCategories.contains(category.id);
                  return FilterChip(
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (_) {
                      // En una implementación real, aquí se actualizaría la selección
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: category.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aplicar a todas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNotesDialog(BuildContext context, Report report) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Notas de Resolución'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Ingrese las notas de resolución...',
            border: OutlineInputBorder(),
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
            onPressed: () {
              if (notesController.text.isNotEmpty) {
                context.read<ReportsBloc>().add(
                  AddResolutionNotesEvent(
                    reportId: report.id,
                    notes: notesController.text,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Report report) {
    ReportStatus? selectedStatus = report.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Actualizar Estado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...ReportStatus.values.map((status) {
                  return RadioListTile<ReportStatus>(
                    title: Text(_getStatusName(status)),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedStatus != null &&
                      selectedStatus != report.status) {
                    context.read<ReportsBloc>().add(
                      UpdateReportStatusEvent(
                        reportId: report.id,
                        status: selectedStatus!,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Actualizar'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getCategoryName(ReportCategory category) {
    return CategoryUtils.getCategoryName(category);
  }

  String _getStatusName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.assigned:
        return 'Asignado';
      case ReportStatus.inProgress:
        return 'En Progreso';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.rejected:
        return 'Rechazado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
