import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/login_usecase.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  // Aquí se agregarían los demás casos de uso relacionados con la autenticación

  AuthBloc({
    required this.loginUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (administrator) => emit(AuthAuthenticated(administrator: administrator)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Aquí se implementaría la lógica para cerrar sesión
    // usando el caso de uso correspondiente
    
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Aquí se implementaría la lógica para verificar el estado de autenticación
    // usando el caso de uso correspondiente
    
    // Por ahora, simulamos que no hay sesión activa
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Aquí se implementaría la lógica para actualizar el tema
    // usando el caso de uso correspondiente
    
    emit(ThemeUpdated(isDarkTheme: event.isDarkTheme));
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Aquí se implementaría la lógica para actualizar el perfil
    // usando el caso de uso correspondiente
    
    // Por ahora, simulamos una actualización exitosa
    if (state is AuthAuthenticated) {
      final currentAdmin = (state as AuthAuthenticated).administrator;
      final updatedAdmin = currentAdmin.copyWith(
        name: event.name,
        profileImageUrl: event.profileImageUrl ?? currentAdmin.profileImageUrl,
      );
      
      emit(ProfileUpdated(administrator: updatedAdmin));
      emit(AuthAuthenticated(administrator: updatedAdmin));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Aquí se implementaría la lógica para cambiar la contraseña
    // usando el caso de uso correspondiente
    
    // Por ahora, simulamos un cambio exitoso
    emit(PasswordChanged());
    
    // Mantenemos el estado de autenticación
    if (state is AuthAuthenticated) {
      emit(AuthAuthenticated(
        administrator: (state as AuthAuthenticated).administrator,
      ));
    }
  }
}
