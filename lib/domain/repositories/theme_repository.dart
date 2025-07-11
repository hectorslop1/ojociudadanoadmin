import 'package:dartz/dartz.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';

abstract class ThemeRepository {
  Future<Either<Failure, bool>> getThemePreference();
  Future<Either<Failure, bool>> updateThemePreference(bool isDarkTheme);
}
