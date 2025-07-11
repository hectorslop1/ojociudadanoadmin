import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class GetThemeEvent extends ThemeEvent {}

class UpdateThemeEvent extends ThemeEvent {
  final bool isDarkTheme;

  const UpdateThemeEvent({required this.isDarkTheme});

  @override
  List<Object> get props => [isDarkTheme];
}
