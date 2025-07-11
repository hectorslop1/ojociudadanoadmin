import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
  
  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkTheme;
  
  const ThemeLoaded({required this.isDarkTheme});
  
  @override
  List<Object> get props => [isDarkTheme];
}

class ThemeError extends ThemeState {
  final String message;
  
  const ThemeError({required this.message});
  
  @override
  List<Object> get props => [message];
}
