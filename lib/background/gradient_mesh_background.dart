import 'dart:ui';

import 'package:flutter/material.dart';

class GradientMeshBackground extends StatelessWidget {
  const GradientMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(child: _GradientMeshLayer());
  }
}

class _GradientMeshLayer extends StatelessWidget {
  const _GradientMeshLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF090E1A)),
        // Blur only the mesh blobs instead of the full backdrop layer.
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Stack(
              children: [
                _meshBlob(
                  color: const Color(0xFF2B6BFF),
                  top: -130,
                  left: -110,
                  size: 340,
                ),
                _meshBlob(
                  color: const Color(0xFFFF7A59),
                  top: 70,
                  right: -120,
                  size: 310,
                ),
                _meshBlob(
                  color: const Color(0xFF12B886),
                  bottom: -150,
                  left: 40,
                  size: 360,
                ),
                _meshBlob(
                  color: const Color(0xFFFFB347),
                  bottom: 110,
                  right: -90,
                  size: 280,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.16),
                  Colors.black.withValues(alpha: 0.40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _meshBlob({
    required Color color,
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.52),
              color.withValues(alpha: 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
