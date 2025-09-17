import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/data/datasources/report_remote_datasource.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Report>>> getReports({
    ReportStatus? status,
    ReportCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? delegationId,
    int? minPriority,
  }) async {
    try {
      final reports = await remoteDataSource.getReports(
        status: status != null ? _statusToString(status) : null,
        category: category != null ? _categoryToString(category) : null,
        startDate: startDate,
        endDate: endDate,
        delegationId: delegationId,
        minPriority: minPriority,
      );
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> getReportById(String id) async {
    try {
      final report = await remoteDataSource.getReportById(id);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> assignReportToTechnician(String reportId, String technicianId) async {
    try {
      final report = await remoteDataSource.assignReportToTechnician(reportId, technicianId);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      final report = await remoteDataSource.updateReportStatus(reportId, _statusToString(status));
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Report>> addResolutionNotes(String reportId, String notes) async {
    try {
      final report = await remoteDataSource.addResolutionNotes(reportId, notes);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<ReportCategory, int>>> getReportCountByCategory({String? delegationId}) async {
    try {
      final countByCategory = await remoteDataSource.getReportCountByCategory(delegationId: delegationId);
      final result = <ReportCategory, int>{};
      
      countByCategory.forEach((key, value) {
        final category = _categoryFromString(key);
        result[category] = value;
      });
      
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<ReportStatus, int>>> getReportCountByStatus({String? delegationId}) async {
    try {
      final countByStatus = await remoteDataSource.getReportCountByStatus(delegationId: delegationId);
      final result = <ReportStatus, int>{};
      
      countByStatus.forEach((key, value) {
        final status = _statusFromString(key);
        result[status] = value;
      });
      
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageResolutionTime({String? delegationId}) async {
    try {
      final averageTime = await remoteDataSource.getAverageResolutionTime(delegationId: delegationId);
      return Right(averageTime);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Report>> updateReportPriority(String reportId, int priority) async {
    try {
      final report = await remoteDataSource.updateReportPriority(reportId, priority);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, double>>> getPerformanceMetrics({String? delegationId}) async {
    try {
      final metrics = await remoteDataSource.getPerformanceMetrics(delegationId: delegationId);
      return Right(metrics);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String _statusToString(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.assigned:
        return 'assigned';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  ReportStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'assigned':
        return ReportStatus.assigned;
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  String _categoryToString(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return 'road_repair';
      case ReportCategory.garbageCollection:
        return 'garbage_collection';
      case ReportCategory.streetImprovement:
        return 'street_improvement';
    }
  }

  ReportCategory _categoryFromString(String category) {
    switch (category) {
      case 'road_repair':
        return ReportCategory.roadRepair;
      case 'garbage_collection':
        return ReportCategory.garbageCollection;
      case 'street_improvement':
        return ReportCategory.streetImprovement;
      // Handle legacy categories by mapping them to the new ones
      case 'lighting':
      case 'poor_signage':
      case 'traffic_lights_damaged':
      case 'stop_signs_damaged':
        return ReportCategory.streetImprovement;
      case 'water_leaks':
      case 'abandoned_vehicles':
      case 'noise':
      case 'animal_abuse':
      case 'insecurity':
      case 'gender_equity':
      case 'disability_ramps':
      case 'service_complaints':
      case 'other':
      default:
        return ReportCategory.garbageCollection;
    }
  }
}
