import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/animations/page_transitions.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/dashboard_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/evidence_feed_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/login_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/splash_page.dart';

/// Clase para manejar la navegación y transiciones entre páginas
class AppRouter {
  /// Nombres de rutas para la navegación
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String evidenceFeed = '/evidence-feed';
  
  /// Método para generar rutas con animaciones
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return PageTransitions.fadeThrough(
          const SplashPage(),
          settings: settings,
        );
      
      case login:
        return PageTransitions.scaleIn(
          const LoginPage(),
          settings: settings,
        );
      
      case dashboard:
        return PageTransitions.slideHorizontal(
          const DashboardPage(),
          settings: settings,
        );
      
      case evidenceFeed:
        return PageTransitions.slideVertical(
          const EvidenceFeedPage(),
          settings: settings,
          isUp: true,
        );
      
      default:
        // Ruta por defecto si no se encuentra la ruta solicitada
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  /// Método para navegar a una página con animación personalizada
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }
  
  /// Método para reemplazar la página actual con una nueva
  static Future<T?> navigateAndReplace<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }
  
  /// Método para eliminar todas las páginas y navegar a una nueva
  static Future<T?> navigateAndRemoveUntil<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// Método para navegar a una página con transición personalizada
  static Future<T?> navigateWithCustomTransition<T>(
    BuildContext context,
    Widget page, {
    TransitionType transitionType = TransitionType.slide,
    RouteSettings? settings,
  }) {
    late final Route<T> route;
    
    switch (transitionType) {
      case TransitionType.fade:
        route = PageTransitions.fadeThrough<T>(page, settings: settings);
        break;
      case TransitionType.scale:
        route = PageTransitions.scaleIn<T>(page, settings: settings);
        break;
      case TransitionType.rotation:
        route = PageTransitions.rotation<T>(page, settings: settings);
        break;
      case TransitionType.slideVertical:
        route = PageTransitions.slideVertical<T>(page, settings: settings);
        break;
      case TransitionType.slide:
        route = PageTransitions.slideHorizontal<T>(page, settings: settings);
        break;
    }
    
    return Navigator.of(context).push(route);
  }
}

/// Tipos de transición disponibles
enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideVertical,
}
