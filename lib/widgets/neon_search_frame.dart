import 'dart:ui';

import 'package:flutter/material.dart';

/// A glass search surface with a continuously moving neon edge.
class NeonSearchFrame extends StatefulWidget {
  const NeonSearchFrame({
    super.key,
    required this.child,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.active = false,
  });

  final Widget child;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool active;

  @override
  State<NeonSearchFrame> createState() => _NeonSearchFrameState();
}

class _NeonSearchFrameState extends State<NeonSearchFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lightController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final glowOpacity = widget.active ? 0.65 : 0.42;

    return AnimatedBuilder(
      animation: _lightController,
      builder: (context, child) {
        final turn = reduceMotion ? 0.0 : _lightController.value * 6.283185;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF00F5FF,
                ).withValues(alpha: glowOpacity * 0.22),
                blurRadius: widget.active ? 22 : 16,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(
                  0xFFFF38D1,
                ).withValues(alpha: glowOpacity * 0.16),
                blurRadius: widget.active ? 28 : 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: SweepGradient(
                transform: GradientRotation(turn),
                colors: const [
                  Color(0xFF00F5FF),
                  Color(0xFF775CFF),
                  Color(0xFFFF38D1),
                  Color(0xFFFFD24A),
                  Color(0xFF00F5FF),
                ],
                stops: const [0.0, 0.28, 0.50, 0.72, 1.0],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF101119).withValues(alpha: 0.82),
                    borderRadius: widget.borderRadius,
                  ),
                  child: Padding(padding: widget.padding, child: child),
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
