import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../background/gradient_mesh_background.dart';

class SignInOrSignUp extends StatefulWidget {
  const SignInOrSignUp({super.key});

  @override
  State<SignInOrSignUp> createState() => _SignInOrSignUpState();
}

class _SignInOrSignUpState extends State<SignInOrSignUp>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _floralController;
  late final Animation<double> _fade;
  late final Animation<Offset> _rise;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _floralController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _rise = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _floralController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _floralController,
                builder: (_, __) {
                  final t = _floralController.value;
                  return Stack(
                    children: [
                      _floralBloom(
                        alignment: const Alignment(0.86, -0.72),
                        size: 170,
                        color: const Color(0x39FFB38A),
                        progress: t,
                        phase: 0.0,
                      ),
                      _floralBloom(
                        alignment: const Alignment(-0.8, -0.42),
                        size: 132,
                        color: const Color(0x309BC2FF),
                        progress: t,
                        phase: 1.4,
                      ),
                      _floralBloom(
                        alignment: const Alignment(0.9, 0.12),
                        size: 150,
                        color: const Color(0x2E95A5FF),
                        progress: t,
                        phase: 2.2,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: -20,
            child: _glowOrb(180, const Color(0x446885FF)),
          ),
          Positioned(
            bottom: 120,
            right: -30,
            child: _glowOrb(240, const Color(0x55FFA16A)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(

                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rizz your soul with music',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _rise,
                      child: _glassCard(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/PlaygroundImage-removebg-preview.png',
                              width: 130,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'MAKE YOUR CHOICE',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _actionButton(
                              text: 'Login',
                              colors: const [
                                Color(0xFFFFA75B),
                                Color(0xFFFF6E5F),
                              ],
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                            ),
                            const SizedBox(height: 14),
                            _actionButton(
                              text: 'Register',
                              colors: const [
                                Color(0xFF8CA2FF),
                                Color(0xFF6361FF),
                              ],
                              onTap: () =>
                                  Navigator.pushNamed(context, '/signup'),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Start listening in seconds',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF88A7FF).withValues(alpha: 0.26),
                const Color(0xFFFF8A74).withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF9FB4FF).withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: colors),
          border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }

  Widget _floralBloom({
    required Alignment alignment,
    required double size,
    required Color color,
    required double progress,
    required double phase,
  }) {
    final wave = math.sin((progress * 2 * math.pi) + phase);
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(0, wave * 12),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < 5; i++)
                Transform.rotate(
                  angle: (i * (2 * math.pi / 5)) + (wave * 0.1),
                  child: Transform.translate(
                    offset: Offset(0, -size * 0.22),
                    child: Container(
                      width: size * 0.34,
                      height: size * 0.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color, color.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                width: size * 0.18,
                height: size * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
