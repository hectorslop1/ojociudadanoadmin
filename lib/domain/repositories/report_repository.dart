import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<Report>>> getReports({
    ReportStatus? status,
    ReportCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Either<Failure, Report>> getReportById(String id);
  
  Future<Either<Failure, Report>> assignReportToTechnician(String reportId, String technicianId);
  
  Future<Either<Failure, Report>> updateReportStatus(String reportId, ReportStatus status);
  
  Future<Either<Failure, Report>> addResolutionNotes(String reportId, String notes);
  
  Future<Either<Failure, Map<ReportCategory, int>>> getReportCountByCategory();
  
  Future<Either<Failure, Map<ReportStatus, int>>> getReportCountByStatus();
  
  Future<Either<Failure, double>> getAverageResolutionTime();
}
