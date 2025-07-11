import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class UpdateThemeEvent extends AuthEvent {
  final bool isDarkTheme;

  const UpdateThemeEvent({required this.isDarkTheme});

  @override
  List<Object> get props => [isDarkTheme];
}

class UpdateProfileEvent extends AuthEvent {
  final String name;
  final String? profileImageUrl;

  const UpdateProfileEvent({
    required this.name,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [name, profileImageUrl];
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}
