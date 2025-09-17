import 'package:flutter/material.dart';

/// Widget de tarjeta con animaciones de interacción
class AnimatedCard extends StatefulWidget {
  /// Contenido de la tarjeta
  final Widget child;

  /// Callback cuando se presiona la tarjeta
  final VoidCallback? onTap;

  /// Duración de la animación
  final Duration duration;

  /// Curva de la animación
  final Curve curve;

  /// Si debe mostrar efecto de elevación al presionar
  final bool elevationOnTap;

  /// Si debe mostrar efecto de escala al presionar
  final bool scaleOnTap;

  /// Elevación inicial de la tarjeta
  final double elevation;

  /// Elevación al presionar la tarjeta
  final double pressedElevation;

  /// Factor de escala al presionar la tarjeta
  final double pressedScale;

  /// Color de la tarjeta
  final Color? color;

  /// Color de la sombra
  final Color? shadowColor;

  /// Radio del borde
  final BorderRadius? borderRadius;

  /// Margen de la tarjeta
  final EdgeInsetsGeometry? margin;

  /// Padding del contenido
  final EdgeInsetsGeometry? padding;

  /// Altura de la tarjeta
  final double? height;

  /// Ancho de la tarjeta
  final double? width;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeInOut,
    this.elevationOnTap = true,
    this.scaleOnTap = true,
    this.elevation = 1.0,
    this.pressedElevation = 4.0,
    this.pressedScale = 0.98,
    this.color,
    this.shadowColor,
    this.borderRadius,
    this.margin,
    this.padding = const EdgeInsets.all(16.0),
    this.height,
    this.width,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.pressedElevation,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Theme.of(context).cardColor;
    final effectiveShadowColor =
        widget.shadowColor ?? Colors.black.withAlpha(51);
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(12);

    // Usar _isPressed para propósitos de accesibilidad
    final String semanticsLabel = _isPressed ? 'Presionado' : 'No presionado';

    return Semantics(
      label: semanticsLabel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.scaleOnTap ? _scaleAnimation.value : 1.0,
            child: Container(
              height: widget.height,
              width: widget.width,
              margin: widget.margin,
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: effectiveBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: effectiveShadowColor,
                    blurRadius: widget.elevationOnTap
                        ? _elevationAnimation.value * 2
                        : widget.elevation * 2,
                    spreadRadius: widget.elevationOnTap
                        ? _elevationAnimation.value
                        : widget.elevation,
                    offset: Offset(
                      0,
                      widget.elevationOnTap
                          ? _elevationAnimation.value
                          : widget.elevation,
                    ),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  onTap: widget.onTap,
                  borderRadius: effectiveBorderRadius,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
