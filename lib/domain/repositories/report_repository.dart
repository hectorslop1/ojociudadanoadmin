import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<Report>>> getReports({
    ReportStatus? status,
    ReportCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? delegationId,
    int? minPriority,
  });

  Future<Either<Failure, Report>> getReportById(String id);

  Future<Either<Failure, Report>> assignReportToTechnician(
    String reportId,
    String technicianId,
  );

  Future<Either<Failure, Report>> updateReportStatus(
    String reportId,
    ReportStatus status,
  );

  Future<Either<Failure, Report>> addResolutionNotes(
    String reportId,
    String notes,
  );

  Future<Either<Failure, Map<ReportCategory, int>>> getReportCountByCategory({
    String? delegationId,
  });

  Future<Either<Failure, Map<ReportStatus, int>>> getReportCountByStatus({
    String? delegationId,
  });

  Future<Either<Failure, double>> getAverageResolutionTime({
    String? delegationId,
  });

  Future<Either<Failure, Report>> updateReportPriority(
    String reportId,
    int priority,
  );

  Future<Either<Failure, Map<String, double>>> getPerformanceMetrics({
    String? delegationId,
  });
}
