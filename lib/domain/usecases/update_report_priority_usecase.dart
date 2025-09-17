import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/report_repository.dart';
import 'package:ojo_ciudadano_admin/domain/services/report_priority_service.dart';

class UpdateReportPriorityUseCase {
  final ReportRepository repository;
  final ReportPriorityService priorityService;

  UpdateReportPriorityUseCase(this.repository, this.priorityService);

  /// Actualiza la prioridad de un reporte específico
  Future<Either<Failure, Report>> call({
    required String reportId,
    int? priority,
  }) async {
    // Si no se proporciona una prioridad, calcularla automáticamente
    if (priority == null) {
      // Primero obtener el reporte
      final reportResult = await repository.getReportById(reportId);
      
      return reportResult.fold(
        (failure) => Left(failure),
        (report) {
          // Calcular la prioridad automáticamente
          final calculatedPriority = priorityService.calculatePriority(report);
          
          // Actualizar la prioridad en el repositorio
          return repository.updateReportPriority(reportId, calculatedPriority);
        },
      );
    } else {
      // Si se proporciona una prioridad, usarla directamente
      return repository.updateReportPriority(reportId, priority);
    }
  }

  /// Actualiza la prioridad de todos los reportes automáticamente
  Future<Either<Failure, List<Report>>> updateAllReportsPriorities() async {
    // Obtener todos los reportes
    final reportsResult = await repository.getReports();
    
    return reportsResult.fold(
      (failure) => Left(failure),
      (reports) async {
        List<Report> updatedReports = [];
        
        for (final report in reports) {
          // Calcular la prioridad automáticamente
          final priority = priorityService.calculatePriority(report);
          
          // Actualizar la prioridad en el repositorio
          final result = await repository.updateReportPriority(report.id, priority);
          
          result.fold(
            (failure) => null, // Ignorar fallos individuales
            (updatedReport) => updatedReports.add(updatedReport),
          );
        }
        
        return Right(updatedReports);
      },
    );
  }
}
