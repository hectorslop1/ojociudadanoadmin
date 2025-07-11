import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/report_repository.dart';

class GetReportsUseCase {
  final ReportRepository repository;

  GetReportsUseCase(this.repository);

  Future<Either<Failure, List<Report>>> call(GetReportsParams params) async {
    return await repository.getReports(
      status: params.status,
      category: params.category,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetReportsParams extends Equatable {
  final ReportStatus? status;
  final ReportCategory? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetReportsParams({
    this.status,
    this.category,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, category, startDate, endDate];
}
