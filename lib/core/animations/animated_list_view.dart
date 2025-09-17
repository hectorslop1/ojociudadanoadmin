import 'package:flutter/material.dart';

/// Widget personalizado para listas animadas
class AnimatedListView extends StatefulWidget {
  /// Lista de widgets a mostrar
  final List<Widget> children;

  /// Duración de la animación
  final Duration duration;

  /// Curva de la animación
  final Curve curve;

  /// Dirección de la animación (vertical u horizontal)
  final Axis scrollDirection;

  /// Padding de la lista
  final EdgeInsetsGeometry? padding;

  /// Espacio entre elementos
  final double? itemSpacing;

  /// Si debe mostrar la animación
  final bool animate;

  /// Si debe animar solo la primera vez
  final bool animateOnlyOnce;

  /// Controlador de scroll
  final ScrollController? controller;

  /// Comportamiento de física del scroll
  final ScrollPhysics? physics;

  /// Shrink wrap
  final bool shrinkWrap;

  const AnimatedListView({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutQuint,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.itemSpacing,
    this.animate = true,
    this.animateOnlyOnce = true,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  State<AnimatedListView> createState() => _AnimatedListViewState();
}

class _AnimatedListViewState extends State<AnimatedListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasAnimatedOnce = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.animate && (!widget.animateOnlyOnce || !_hasAnimatedOnce)) {
      _controller.forward();
      _hasAnimatedOnce = true;
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animate != oldWidget.animate) {
      if (widget.animate && (!widget.animateOnlyOnce || !_hasAnimatedOnce)) {
        _controller.forward(from: 0.0);
        _hasAnimatedOnce = true;
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: widget.controller,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      scrollDirection: widget.scrollDirection,
      itemCount: widget.children.length,
      separatorBuilder: (context, index) => SizedBox(
        height: widget.scrollDirection == Axis.vertical
            ? widget.itemSpacing ?? 0
            : 0,
        width: widget.scrollDirection == Axis.horizontal
            ? widget.itemSpacing ?? 0
            : 0,
      ),
      itemBuilder: (context, index) {
        final Animation<double> animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / widget.children.length * 0.5,
            (index + 1) / widget.children.length,
            curve: widget.curve,
          ),
        );

        return _AnimatedListItem(
          animation: animation,
          scrollDirection: widget.scrollDirection,
          child: widget.children[index],
        );
      },
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Axis scrollDirection;

  const _AnimatedListItem({
    required this.animation,
    required this.child,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final slideOffset = scrollDirection == Axis.vertical
            ? Offset(0, 1 - animation.value)
            : Offset(1 - animation.value, 0);

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(offset: slideOffset * 50, child: child),
        );
      },
      child: child,
    );
  }
}
