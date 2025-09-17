import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/delegation.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/delegation_repository.dart';

class MockDelegationRepository implements DelegationRepository {
  final List<Delegation> _delegations = [
    const Delegation(
      id: 'd1',
      name: 'Centro',
      description: 'Delegación Centro de la ciudad',
      latitude: 19.432608,
      longitude: -99.133209,
    ),
    const Delegation(
      id: 'd2',
      name: 'Norte',
      description: 'Delegación Norte de la ciudad',
      latitude: 19.442608,
      longitude: -99.143209,
    ),
    const Delegation(
      id: 'd3',
      name: 'Sur',
      description: 'Delegación Sur de la ciudad',
      latitude: 19.422608,
      longitude: -99.123209,
    ),
    const Delegation(
      id: 'd4',
      name: 'Este',
      description: 'Delegación Este de la ciudad',
      latitude: 19.432608,
      longitude: -99.123209,
    ),
    const Delegation(
      id: 'd5',
      name: 'Oeste',
      description: 'Delegación Oeste de la ciudad',
      latitude: 19.432608,
      longitude: -99.143209,
    ),
  ];

  @override
  Future<Either<Failure, List<Delegation>>> getDelegations({bool? isActive}) {
    try {
      if (isActive != null) {
        final filteredDelegations = _delegations
            .where((delegation) => delegation.isActive == isActive)
            .toList();
        return Future.value(Right(filteredDelegations));
      }
      return Future.value(Right(_delegations));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Delegation>> getDelegationById(String id) {
    try {
      final delegation = _delegations.firstWhere(
        (delegation) => delegation.id == id,
        orElse: () => throw Exception('Delegación no encontrada'),
      );
      return Future.value(Right(delegation));
    } catch (e) {
      return Future.value(
        Left(NotFoundFailure(message: 'Delegación no encontrada')),
      );
    }
  }

  @override
  Future<Either<Failure, Delegation>> createDelegation(Delegation delegation) {
    try {
      if (_delegations.any((d) => d.id == delegation.id)) {
        return Future.value(
          Left(ServerFailure(message: 'Ya existe una delegación con ese ID')),
        );
      }
      _delegations.add(delegation);
      return Future.value(Right(delegation));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Delegation>> updateDelegation(Delegation delegation) {
    try {
      final index = _delegations.indexWhere((d) => d.id == delegation.id);
      if (index == -1) {
        return Future.value(
          Left(NotFoundFailure(message: 'Delegación no encontrada')),
        );
      }
      _delegations[index] = delegation;
      return Future.value(Right(delegation));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDelegation(String id) {
    try {
      final initialLength = _delegations.length;
      _delegations.removeWhere((d) => d.id == id);
      final deleted = initialLength > _delegations.length;
      
      if (deleted) {
        return Future.value(const Right(true));
      } else {
        return Future.value(
          Left(NotFoundFailure(message: 'Delegación no encontrada')),
        );
      }
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getReportCountByDelegation() {
    try {
      // Simulamos conteo de reportes por delegación
      final Map<String, int> countByDelegation = {
        'd1': 15, // Centro: 15 reportes
        'd2': 8,  // Norte: 8 reportes
        'd3': 12, // Sur: 12 reportes
        'd4': 5,  // Este: 5 reportes
        'd5': 10, // Oeste: 10 reportes
      };
      
      return Future.value(Right(countByDelegation));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }
}
