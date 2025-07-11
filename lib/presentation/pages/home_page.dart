import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_state.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/dashboard_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/evidence_feed_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/login_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/profile_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const EvidenceFeedPage(),
    const ReportsPage(),
    const ProfilePage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Evidencias',
    'Reportes',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Redirigir al login si el usuario no está autenticado
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentIndex]),
          backgroundColor: _currentIndex == 2 
              ? Theme.of(context).brightness == Brightness.light 
                  ? AppColors.primary 
                  : AppColors.primaryDark 
              : null, // Color guinda adaptado al modo
          foregroundColor: _currentIndex == 2 ? Colors.white : null, // Texto blanco para la página de Reportes
          elevation: 2,
          actions: [
            if (_currentIndex != 4) // No mostrar en la página de perfil
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Implementar visualización de notificaciones
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificaciones no implementadas aún'),
                    ),
                  );
                },
                tooltip: 'Notificaciones',
              ),
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.primary
              : AppColors.primaryDark,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Evidencias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Reportes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
