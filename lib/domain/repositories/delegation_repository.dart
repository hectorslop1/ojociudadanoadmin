import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/delegation.dart';

abstract class DelegationRepository {
  /// Obtiene todas las delegaciones
  Future<Either<Failure, List<Delegation>>> getDelegations({bool? isActive});
  
  /// Obtiene una delegación por su ID
  Future<Either<Failure, Delegation>> getDelegationById(String id);
  
  /// Crea una nueva delegación
  Future<Either<Failure, Delegation>> createDelegation(Delegation delegation);
  
  /// Actualiza una delegación existente
  Future<Either<Failure, Delegation>> updateDelegation(Delegation delegation);
  
  /// Elimina una delegación
  Future<Either<Failure, bool>> deleteDelegation(String id);
  
  /// Obtiene estadísticas de reportes por delegación
  Future<Either<Failure, Map<String, int>>> getReportCountByDelegation();
}
