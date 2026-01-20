import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientMeshBackground extends StatelessWidget {
  const GradientMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark layer
        Container(
          color: const Color(0xFF0B0B14),
        ),

        _meshBlob(
          color: Colors.purpleAccent,
          top: -120,
          left: -100,
          size: 320,
        ),
        _meshBlob(
          color: Colors.orangeAccent,
          top: 80,
          right: -120,
          size: 300,
        ),
        _meshBlob(
          color: Colors.pinkAccent,
          bottom: -140,
          left: 60,
          size: 340,
        ),
        _meshBlob(
          color: Colors.blueAccent,
          bottom: 120,
          right: -100,
          size: 280,
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
              color.withOpacity(0.55),
              color.withOpacity(0.05),
            ],
          ),
        ),
      ),
    );
  }
}
