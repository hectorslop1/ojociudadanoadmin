import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/domain/entities/administrator.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Administrator administrator;
  
  const AuthAuthenticated({required this.administrator});
  
  @override
  List<Object> get props => [administrator];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ThemeUpdated extends AuthState {
  final bool isDarkTheme;
  
  const ThemeUpdated({required this.isDarkTheme});
  
  @override
  List<Object> get props => [isDarkTheme];
}

class ProfileUpdated extends AuthState {
  final Administrator administrator;
  
  const ProfileUpdated({required this.administrator});
  
  @override
  List<Object> get props => [administrator];
}

class PasswordChanged extends AuthState {}

class PasswordChangeError extends AuthState {
  final String message;
  
  const PasswordChangeError({required this.message});
  
  @override
  List<Object> get props => [message];
}
