import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

abstract class TechnicianRepository {
  Future<Either<Failure, List<Technician>>> getTechnicians({
    bool? isActive,
    String? specialty,
  });
  
  Future<Either<Failure, Technician>> getTechnicianById(String id);
  
  Future<Either<Failure, Technician>> createTechnician(Technician technician);
  
  Future<Either<Failure, Technician>> updateTechnician(Technician technician);
  
  Future<Either<Failure, bool>> deleteTechnician(String id);
  
  Future<Either<Failure, List<Report>>> getTechnicianReports(String technicianId, {
    ReportStatus? status,
  });
  
  Future<Either<Failure, Map<String, double>>> getTechnicianPerformanceMetrics(String technicianId);
}
