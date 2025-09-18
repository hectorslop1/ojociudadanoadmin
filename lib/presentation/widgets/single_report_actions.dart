import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/batch_management_page.dart';

/// Adaptador para mostrar el diálogo de acciones para un solo reporte
/// Utiliza el mismo BatchActionsBottomSheet que se usa en la gestión por lotes
class SingleReportActions {
  static void showActionsForReport(BuildContext context, Report report) {
    // Crear una lista con un solo reporte
    final List<Report> reports = [report];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BatchActionsBottomSheet(
        selectedReports: reports,
        onUpdatePriority: (reports, priority) {
          _updatePriority(context, reports, priority);
        },
        onAssignTechnician: (reports, technicianId) {
          _assignTechnician(context, reports, technicianId);
        },
        onUpdateStatus: (reports, status) {
          _updateStatus(context, reports, status);
        },
      ),
    );
  }

  static void _updatePriority(BuildContext context, List<Report> reports, int priority) {
    for (final report in reports) {
      context.read<ReportsBloc>().add(
        UpdateReportPriorityEvent(reportId: report.id, priority: priority),
      );
    }

    Navigator.pop(context);
    _showSuccessSnackBar(context, 'Prioridad actualizada correctamente');
  }

  static void _assignTechnician(BuildContext context, List<Report> reports, String technicianId) {
    for (final report in reports) {
      context.read<ReportsBloc>().add(
        AssignReportEvent(reportId: report.id, technicianId: technicianId),
      );
    }

    Navigator.pop(context);
    _showSuccessSnackBar(context, 'Técnico asignado correctamente');
  }

  static void _updateStatus(BuildContext context, List<Report> reports, ReportStatus status) {
    for (final report in reports) {
      context.read<ReportsBloc>().add(
        UpdateReportStatusEvent(reportId: report.id, status: status),
      );
    }

    Navigator.pop(context);
    _showSuccessSnackBar(context, 'Estado actualizado correctamente');
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
