import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoadingAnimation extends StatelessWidget {
  const AppLoadingAnimation({super.key, this.size = 170});

  final double size;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/anim/Guitar.json',
        fit: BoxFit.contain,
        repeat: true,
        frameRate: FrameRate.max,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.music_note_rounded, color: iconColor, size: 44),
      ),
    );
  }
}
