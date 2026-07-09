import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpinningGlobe extends StatefulWidget {
  const SpinningGlobe({
    super.key,
    this.child,
    this.duration = const Duration(seconds: 25),
  });

  final Widget? child;
  final Duration duration;

  @override
  State<SpinningGlobe> createState() => _SpinningGlobeState();
}

class _SpinningGlobeState extends State<SpinningGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
    );
  }
}