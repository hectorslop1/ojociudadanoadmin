import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_state.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/dashboard_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Verificar estado de autenticación al iniciar
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Si el usuario está autenticado, navegar al dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        } else if (state is AuthUnauthenticated) {
          // Si el usuario no está autenticado, navegar a la pantalla de login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        // Si está en estado de carga (AuthLoading), se queda en esta pantalla
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la aplicación
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.visibility,
                    size: 150,
                    color: Colors.blue,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Ojo Ciudadano Admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
