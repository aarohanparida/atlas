import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedGlobe extends StatefulWidget {
  const AnimatedGlobe({
    super.key,
    this.size = 180,
    this.duration = const Duration(milliseconds: 1200),
  });

  final double size;
  final Duration duration;

  @override
  State<AnimatedGlobe> createState() => _AnimatedGlobeState();
}

class _AnimatedGlobeState extends State<AnimatedGlobe>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  bool finished = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.forward();
    _controller.forward().then((_) {
      setState(() {
        finished = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (finished) {
      return SvgPicture.asset(
        "assets/images/globe.svg",
        width: widget.size,
      );
    }

    return AnimatedBuilder(

      animation: _controller,

      builder: (context, child) {

        final t = Curves.easeOutCubic.transform(_controller.value);

        return Opacity(

          opacity: t,

          child: CustomPaint(

            size: Size.square(widget.size),

            painter: GlobePainter(t),

          ),

        );

      },

    );

  }

}

class GlobePainter extends CustomPainter {

  GlobePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final r = size.width / 2;

    final center = Offset(r, r);

    canvas.drawCircle(center, r - 2, paint);

    // Latitude lines

    for (double y in [-0.45, 0, 0.45]) {

      final rect = Rect.fromCenter(
        center: Offset(r, r + y * r),
        width: r * 2,
        height: r * 0.55,
      );

      canvas.drawArc(
        rect,
        0,
        math.pi,
        false,
        paint,
      );

    }

    // Animated longitude lines

    final progress = math.cos((1 - t) * math.pi / 2);

    for (double x in [-0.5, 0, 0.5]) {

      final width = (r * .65) * (1 - x.abs() * .35) * progress;

      final rect = Rect.fromCenter(
        center: center,
        width: width * 2,
        height: r * 2,
      );

      canvas.drawOval(rect, paint);

    }

  }

  @override
  bool shouldRepaint(covariant GlobePainter oldDelegate) {

    return true;

  }

}