import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  final ReportStatus? filterStatus;
  final ReportCategory? filterCategory;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  
  const ReportsLoaded({
    required this.reports,
    this.filterStatus,
    this.filterCategory,
    this.filterStartDate,
    this.filterEndDate,
  });
  
  @override
  List<Object?> get props => [
    reports,
    filterStatus,
    filterCategory,
    filterStartDate,
    filterEndDate,
  ];
}

class ReportDetailsLoaded extends ReportsState {
  final Report report;
  final List<Report>? previousReports;
  final ReportStatus? filterStatus;
  final ReportCategory? filterCategory;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  
  const ReportDetailsLoaded({
    required this.report,
    this.previousReports,
    this.filterStatus,
    this.filterCategory,
    this.filterStartDate,
    this.filterEndDate,
  });
  
  @override
  List<Object?> get props => [
    report,
    previousReports,
    filterStatus,
    filterCategory,
    filterStartDate,
    filterEndDate,
  ];
}

class ReportAssigned extends ReportsState {
  final Report report;
  
  const ReportAssigned({required this.report});
  
  @override
  List<Object> get props => [report];
}

class ReportStatusUpdated extends ReportsState {
  final Report report;
  
  const ReportStatusUpdated({required this.report});
  
  @override
  List<Object> get props => [report];
}

class ResolutionNotesAdded extends ReportsState {
  final Report report;
  
  const ResolutionNotesAdded({required this.report});
  
  @override
  List<Object> get props => [report];
}

class ReportsError extends ReportsState {
  final String message;
  
  const ReportsError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ReportStatisticsLoaded extends ReportsState {
  final Map<ReportCategory, int> reportsByCategory;
  final Map<ReportStatus, int> reportsByStatus;
  final double averageResolutionTime;
  final List<Report> allReports;
  
  const ReportStatisticsLoaded({
    required this.reportsByCategory,
    required this.reportsByStatus,
    required this.averageResolutionTime,
    required this.allReports,
  });
  
  @override
  List<Object> get props => [
    reportsByCategory,
    reportsByStatus,
    averageResolutionTime,
    allReports,
  ];
}
