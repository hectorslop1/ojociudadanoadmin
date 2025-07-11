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
  }) async {
    try {
      final reports = await remoteDataSource.getReports(
        status: status != null ? _statusToString(status) : null,
        category: category != null ? _categoryToString(category) : null,
        startDate: startDate,
        endDate: endDate,
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
  Future<Either<Failure, Map<ReportCategory, int>>> getReportCountByCategory() async {
    try {
      final countByCategory = await remoteDataSource.getReportCountByCategory();
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
  Future<Either<Failure, Map<ReportStatus, int>>> getReportCountByStatus() async {
    try {
      final countByStatus = await remoteDataSource.getReportCountByStatus();
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
  Future<Either<Failure, double>> getAverageResolutionTime() async {
    try {
      final averageTime = await remoteDataSource.getAverageResolutionTime();
      return Right(averageTime);
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
      case ReportCategory.lighting:
        return 'lighting';
      case ReportCategory.roadRepair:
        return 'road_repair';
      case ReportCategory.garbageCollection:
        return 'garbage_collection';
      case ReportCategory.waterLeaks:
        return 'water_leaks';
      case ReportCategory.abandonedVehicles:
        return 'abandoned_vehicles';
      case ReportCategory.noise:
        return 'noise';
      case ReportCategory.animalAbuse:
        return 'animal_abuse';
      case ReportCategory.insecurity:
        return 'insecurity';
      case ReportCategory.stopSignsDamaged:
        return 'stop_signs_damaged';
      case ReportCategory.trafficLightsDamaged:
        return 'traffic_lights_damaged';
      case ReportCategory.poorSignage:
        return 'poor_signage';
      case ReportCategory.genderEquity:
        return 'gender_equity';
      case ReportCategory.disabilityRamps:
        return 'disability_ramps';
      case ReportCategory.serviceComplaints:
        return 'service_complaints';
      case ReportCategory.other:
        return 'other';
    }
  }

  ReportCategory _categoryFromString(String category) {
    switch (category) {
      case 'lighting':
        return ReportCategory.lighting;
      case 'road_repair':
        return ReportCategory.roadRepair;
      case 'garbage_collection':
        return ReportCategory.garbageCollection;
      case 'water_leaks':
        return ReportCategory.waterLeaks;
      case 'abandoned_vehicles':
        return ReportCategory.abandonedVehicles;
      case 'noise':
        return ReportCategory.noise;
      case 'animal_abuse':
        return ReportCategory.animalAbuse;
      case 'insecurity':
        return ReportCategory.insecurity;
      case 'stop_signs_damaged':
        return ReportCategory.stopSignsDamaged;
      case 'traffic_lights_damaged':
        return ReportCategory.trafficLightsDamaged;
      case 'poor_signage':
        return ReportCategory.poorSignage;
      case 'gender_equity':
        return ReportCategory.genderEquity;
      case 'disability_ramps':
        return ReportCategory.disabilityRamps;
      case 'service_complaints':
        return ReportCategory.serviceComplaints;
      case 'other':
        return ReportCategory.other;
      default:
        return ReportCategory.other;
    }
  }
}
