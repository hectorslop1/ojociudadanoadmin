import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/delegation.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/delegation_repository.dart';

class GetDelegationsUseCase {
  final DelegationRepository repository;

  GetDelegationsUseCase(this.repository);

  Future<Either<Failure, List<Delegation>>> call({bool? isActive}) {
    return repository.getDelegations(isActive: isActive);
  }
}
