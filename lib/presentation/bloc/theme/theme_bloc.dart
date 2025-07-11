import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/theme_repository.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/theme/theme_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository themeRepository;

  ThemeBloc({required this.themeRepository}) : super(ThemeInitial()) {
    on<GetThemeEvent>(_onGetTheme);
    on<UpdateThemeEvent>(_onUpdateTheme);
  }

  void _onGetTheme(GetThemeEvent event, Emitter<ThemeState> emit) async {
    emit(ThemeLoading());
    final result = await themeRepository.getThemePreference();
    result.fold(
      (failure) => emit(ThemeError(message: failure.message)),
      (isDarkTheme) => emit(ThemeLoaded(isDarkTheme: isDarkTheme)),
    );
  }

  void _onUpdateTheme(UpdateThemeEvent event, Emitter<ThemeState> emit) async {
    emit(ThemeLoading());
    final result = await themeRepository.updateThemePreference(event.isDarkTheme);
    result.fold(
      (failure) => emit(ThemeError(message: failure.message)),
      (_) => emit(ThemeLoaded(isDarkTheme: event.isDarkTheme)),
    );
  }
}
