import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/administrator.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/administrator_repository.dart';

class LoginUseCase {
  final AdministratorRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, Administrator>> call(LoginParams params) async {
    return await repository.login(
      params.email,
      params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
