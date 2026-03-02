import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingPillGlassCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback? onTap;

  const FloatingPillGlassCard({
    super.key,
    required this.image,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageSizePx = (44 * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),

          // 🌫️ soft floating shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),

                // 🧊 glass base
                color: Colors.white.withValues(alpha: 0.16),

                // subtle highlight
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎧 album image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      image,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      cacheWidth: imageSizePx,
                      filterQuality: FilterQuality.low,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 🎵 title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
