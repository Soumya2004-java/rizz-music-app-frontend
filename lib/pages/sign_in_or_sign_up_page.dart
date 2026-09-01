import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/rizz_auth_ui.dart';

class SignInOrSignUp extends StatefulWidget {
  const SignInOrSignUp({super.key});

  @override
  State<SignInOrSignUp> createState() => _SignInOrSignUpState();
}

class _SignInOrSignUpState extends State<SignInOrSignUp>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _colorFlow;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
    _colorFlow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _colorFlow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    final rise = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(fade);

    return RizzAuthScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _colorFlow,
                builder: (context, _) => _floatingColorField(_colorFlow.value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: rise,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RizzBrandMark(),
                    const Spacer(flex: 2),
                    Text(
                      'Your sound.\nYour space.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.sizeOf(context).width < 370
                            ? 42
                            : 48,
                        height: 0.96,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2.1,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Discover music that feels like it was made for you.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    RizzAuthPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.headphones_rounded,
                                size: 20,
                                color: Color(0xFFB6C4FF),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'LISTEN YOUR WAY',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.62),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          RizzPrimaryButton(
                            label: 'Create your account',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                          ),
                          const SizedBox(height: 13),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'I already have an account',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingColorField(double progress) {
    final t = progress * math.pi * 2;
    return Stack(
      children: [
        _colorCloud(
          size: 330,
          color: const Color(0xFF7183FF),
          alignment: const Alignment(0.95, -0.78),
          offset: Offset(math.sin(t) * 28, math.cos(t * 0.8) * 24),
        ),
        _colorCloud(
          size: 300,
          color: const Color(0xFFFF8F70),
          alignment: const Alignment(-0.95, 0.48),
          offset: Offset(math.cos(t * 0.7) * 34, math.sin(t * 0.72) * 26),
        ),
        _colorCloud(
          size: 230,
          color: const Color(0xFF9CAEFF),
          alignment: const Alignment(0.55, 0.98),
          offset: Offset(
            math.sin(t * 0.62 + 1.1) * 22,
            -math.cos(t * 0.7) * 18,
          ),
        ),
      ],
    );
  }

  Widget _colorCloud({
    required double size,
    required Color color,
    required Alignment alignment,
    required Offset offset,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.22),
                color.withValues(alpha: 0.06),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
