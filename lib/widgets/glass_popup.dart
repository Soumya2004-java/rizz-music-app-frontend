import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPopupContainer extends StatelessWidget {
  const GlassPopupContainer({
    required this.child,
    this.borderRadius = 22,
    super.key,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isLight
                    ? Colors.white.withValues(alpha: 0.58)
                    : Colors.white.withValues(alpha: 0.25),
                isLight
                    ? Colors.white.withValues(alpha: 0.42)
                    : const Color(0xFFB8D3F0).withValues(alpha: 0.16),
                isLight
                    ? Colors.white.withValues(alpha: 0.30)
                    : const Color(0xFF9DB5D6).withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.70)
                  : Colors.white.withValues(alpha: 0.34),
              width: 1.05,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
  EdgeInsetsGeometry? padding,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
      final resolvedPadding =
          padding ?? EdgeInsets.fromLTRB(14, 8, 14, 14 + bottomInset);

      return SafeArea(
        child: Padding(
          padding: resolvedPadding,
          child: GlassPopupContainer(child: child),
        ),
      );
    },
  );
}
