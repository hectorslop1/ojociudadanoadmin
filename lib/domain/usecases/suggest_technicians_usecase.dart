import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/report_repository.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/technician_repository.dart';
import 'package:ojo_ciudadano_admin/domain/services/technician_assignment_service.dart';

class SuggestTechniciansUseCase {
  final ReportRepository reportRepository;
  final TechnicianRepository technicianRepository;
  final TechnicianAssignmentService assignmentService;

  SuggestTechniciansUseCase({
    required this.reportRepository,
    required this.technicianRepository,
    required this.assignmentService,
  });

  /// Sugiere técnicos para un reporte específico
  Future<Either<Failure, List<Technician>>> call(String reportId) async {
    try {
      // Obtener el reporte
      final reportResult = await reportRepository.getReportById(reportId);

      return reportResult.fold((failure) => Left(failure), (report) async {
        // Obtener todos los técnicos disponibles
        final techniciansResult = await technicianRepository.getTechnicians();

        return techniciansResult.fold((failure) => Left(failure), (
          technicians,
        ) {
          // Filtrar técnicos disponibles (no de vacaciones, etc.)
          final availableTechnicians = technicians
              .where((t) => t.isAvailable)
              .toList();

          // Usar el servicio para sugerir técnicos
          final suggestedTechnicians = assignmentService.suggestTechnicians(
            report,
            availableTechnicians,
          );

          return Right(suggestedTechnicians);
        });
      });
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
