import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportsEvent extends ReportsEvent {
  final ReportStatus? status;
  final ReportCategory? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? delegationId;
  final int? minPriority;

  const LoadReportsEvent({
    this.status,
    this.category,
    this.startDate,
    this.endDate,
    this.delegationId,
    this.minPriority,
  });

  @override
  List<Object?> get props => [status, category, startDate, endDate, delegationId, minPriority];
}

class LoadReportDetailsEvent extends ReportsEvent {
  final String reportId;

  const LoadReportDetailsEvent({required this.reportId});

  @override
  List<Object> get props => [reportId];
}

class AssignReportEvent extends ReportsEvent {
  final String reportId;
  final String technicianId;

  const AssignReportEvent({
    required this.reportId,
    required this.technicianId,
  });

  @override
  List<Object> get props => [reportId, technicianId];
}

class UpdateReportStatusEvent extends ReportsEvent {
  final String reportId;
  final ReportStatus status;

  const UpdateReportStatusEvent({
    required this.reportId,
    required this.status,
  });

  @override
  List<Object> get props => [reportId, status];
}

class AddResolutionNotesEvent extends ReportsEvent {
  final String reportId;
  final String notes;

  const AddResolutionNotesEvent({
    required this.reportId,
    required this.notes,
  });

  @override
  List<Object> get props => [reportId, notes];
}

class LoadReportStatisticsEvent extends ReportsEvent {
  final String? delegationId;
  
  const LoadReportStatisticsEvent({this.delegationId});
  
  @override
  List<Object?> get props => [delegationId];
}

class UpdateReportPriorityEvent extends ReportsEvent {
  final String reportId;
  final int? priority; // Si es null, se calculará automáticamente

  const UpdateReportPriorityEvent({
    required this.reportId,
    this.priority,
  });

  @override
  List<Object?> get props => [reportId, priority];
}

class UpdateAllReportPrioritiesEvent extends ReportsEvent {}

class FilterReportsByPriorityEvent extends ReportsEvent {
  final int minPriority;

  const FilterReportsByPriorityEvent({required this.minPriority});

  @override
  List<Object> get props => [minPriority];
}
