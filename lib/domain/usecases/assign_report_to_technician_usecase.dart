import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/report_repository.dart';

class AssignReportToTechnicianUseCase {
  final ReportRepository repository;

  AssignReportToTechnicianUseCase(this.repository);

  Future<Either<Failure, Report>> call(AssignReportParams params) async {
    return await repository.assignReportToTechnician(
      params.reportId,
      params.technicianId,
    );
  }
}

class AssignReportParams extends Equatable {
  final String reportId;
  final String technicianId;

  const AssignReportParams({
    required this.reportId,
    required this.technicianId,
  });

  @override
  List<Object> get props => [reportId, technicianId];
}
