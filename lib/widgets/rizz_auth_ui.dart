import 'dart:ui';

import 'package:flutter/material.dart';

class RizzAuthScaffold extends StatelessWidget {
  const RizzAuthScaffold({
    super.key,
    required this.child,
    this.scrollable = false,
  });

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = scrollable
        ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: child,
          )
        : child;

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        children: [
          const Positioned.fill(child: _RizzAuthBackdrop()),
          SafeArea(child: content),
        ],
      ),
    );
  }
}

class RizzBrandMark extends StatelessWidget {
  const RizzBrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 58.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB6C4FF), Color(0xFF7183FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7183FF).withValues(alpha: 0.38),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.graphic_eq_rounded,
            color: const Color(0xFF0B1020),
            size: compact ? 23 : 31,
          ),
        ),
        const SizedBox(width: 11),
        Text(
          'RizzMusic',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 18 : 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class RizzAuthPanel extends StatelessWidget {
  const RizzAuthPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFF171B29).withValues(alpha: 0.70),
            border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class RizzInput extends StatelessWidget {
  const RizzInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      cursorColor: const Color(0xFFB6C4FF),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFB6C4FF), size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.22),
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.09)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF9EB1FF), width: 1.3),
        ),
      ),
    );
  }
}

class RizzPrimaryButton extends StatelessWidget {
  const RizzPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFAFC0FF), Color(0xFF7487FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7487FF).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Color(0xFF10162B),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF10162B),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (icon != null) ...[
                          const SizedBox(width: 8),
                          Icon(icon, color: const Color(0xFF10162B), size: 19),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RizzAuthBackdrop extends StatelessWidget {
  const _RizzAuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ColoredBox(color: Color(0xFF07090F)),
        Positioned(
          top: -180,
          right: -115,
          child: _glow(360, const Color(0xFF5E72E9), 0.24),
        ),
        Positioned(
          bottom: -170,
          left: -130,
          child: _glow(360, const Color(0xFFFF8F70), 0.17),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.38),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glow(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
