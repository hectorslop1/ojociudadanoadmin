import 'package:flutter/material.dart';

/// Clase de utilidad para animaciones en toda la aplicación
class AppAnimations {
  /// Duración estándar para la mayoría de las animaciones
  static const Duration defaultDuration = Duration(milliseconds: 300);
  
  /// Duración para animaciones más rápidas
  static const Duration quickDuration = Duration(milliseconds: 150);
  
  /// Duración para animaciones más lentas
  static const Duration slowDuration = Duration(milliseconds: 500);
  
  /// Curva estándar para la mayoría de las animaciones
  static const Curve defaultCurve = Curves.easeInOut;
  
  /// Curva para animaciones de entrada
  static const Curve entranceCurve = Curves.easeOutBack;
  
  /// Curva para animaciones de salida
  static const Curve exitCurve = Curves.easeInBack;
  
  /// Curva para animaciones de rebote
  static const Curve bounceCurve = Curves.elasticOut;
  
  /// Transición de página con desvanecimiento
  static PageRouteBuilder fadeTransition({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: defaultDuration,
    );
  }
  
  /// Transición de página con deslizamiento desde la derecha
  static PageRouteBuilder slideTransition({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = defaultCurve;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: defaultDuration,
    );
  }
  
  /// Transición de página con escala y desvanecimiento
  static PageRouteBuilder scaleTransition({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = defaultCurve;
        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));
        var opacityTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        
        return FadeTransition(
          opacity: animation.drive(opacityTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
      transitionDuration: defaultDuration,
    );
  }
  
  /// Widget para animar la entrada de elementos en una lista
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    required Animation<double> animation,
    Curve? curve,
    Duration? delay,
  }) {
    final calculatedDelay = Duration(milliseconds: 50 * index);
    final effectiveDelay = delay ?? calculatedDelay;
    final effectiveCurve = curve ?? entranceCurve;
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final delayedAnimation = CurvedAnimation(
          parent: animation,
          curve: Interval(
            effectiveDelay.inMilliseconds / slowDuration.inMilliseconds,
            1.0,
            curve: effectiveCurve,
          ),
        );
        
        return FadeTransition(
          opacity: delayedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(delayedAnimation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Widget para animar cambios en el tamaño de un contenedor
  static Widget animatedSize({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return AnimatedSize(
      duration: duration ?? defaultDuration,
      curve: curve ?? defaultCurve,
      child: child,
    );
  }
  
  /// Widget para animar la aparición con escala
  static Widget scaleIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
    bool animate = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0.0 : 1.0, end: 1.0),
      duration: duration ?? defaultDuration,
      curve: curve ?? entranceCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Widget para animar la aparición con desvanecimiento
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
    bool animate = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0.0 : 1.0, end: 1.0),
      duration: duration ?? defaultDuration,
      curve: curve ?? defaultCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Widget para animar la aparición con deslizamiento
  static Widget slideIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
    Offset? beginOffset,
    bool animate = true,
  }) {
    final effectiveBeginOffset = beginOffset ?? const Offset(0.0, 0.2);
    
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: animate ? effectiveBeginOffset : Offset.zero,
        end: Offset.zero,
      ),
      duration: duration ?? defaultDuration,
      curve: curve ?? entranceCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * MediaQuery.of(context).size.width,
            value.dy * MediaQuery.of(context).size.height,
          ),
          child: Opacity(
            opacity: animate ? (1.0 - value.distance) : 1.0,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
