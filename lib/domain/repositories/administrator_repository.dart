import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/domain/entities/administrator.dart';

abstract class AdministratorRepository {
  Future<Either<Failure, Administrator>> login(String email, String password);
  
  Future<Either<Failure, bool>> logout();
  
  Future<Either<Failure, Administrator>> getCurrentAdministrator();
  
  Future<Either<Failure, Administrator>> updateProfile(Administrator administrator);
  
  Future<Either<Failure, bool>> changePassword(String currentPassword, String newPassword);
  
  Future<Either<Failure, bool>> updateThemePreference(bool isDarkTheme);
  
  Future<Either<Failure, List<Administrator>>> getAllAdministrators();
  
  Future<Either<Failure, Administrator>> createAdministrator(Administrator administrator, String password);
  
  Future<Either<Failure, bool>> deleteAdministrator(String id);
}
