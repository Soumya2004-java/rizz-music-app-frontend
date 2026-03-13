import 'dart:ui';

import 'package:flutter/material.dart';

import '../background/gradient_mesh_background.dart';
import '../naviogations/tabbar.dart';
import '../services/auth_store.dart';
import '../views/profile/settings/profile_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _rise;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _rise = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Positioned(
            top: 70,
            right: -30,
            child: _glowOrb(180, const Color(0x66FFFFFF)),
          ),
          Positioned(
            bottom: 90,
            left: -40,
            child: _glowOrb(220, const Color(0x55FF8A65)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _rise,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in and continue your music journey',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _glassCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFB56B),
                                        Color(0xFFFF6B6B),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Rizz Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                _pill('Premium'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _input(
                              icon: Icons.alternate_email_rounded,
                              hint: 'Email address',
                              controller: _emailController,
                            ),
                            const SizedBox(height: 12),
                            _input(
                              icon: Icons.lock_outline_rounded,
                              hint: 'Password',
                              obscure: true,
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => _show(
                                  'Use demo@rizz.app / 123456 or change password from settings after login.',
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.84),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _loginButton(),
                            const SizedBox(height: 16),
                            Text(
                              'or continue with',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.74),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _socialButton(
                                    label: 'Google',
                                    icon: Icons.g_mobiledata_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _socialButton(
                                    label: 'Facebook',
                                    icon: Icons.facebook_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'New to Rizz? ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/signup',
                              ),
                              child: Text(
                                'Create account',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                Colors.white.withValues(alpha: 0.24),
                Colors.white.withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
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

  Widget _input({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.86)),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return GestureDetector(
      onTap: _isLoggingIn ? null : _handleLogin,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA55A), Color(0xFFFF5F6D)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7B64).withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _isLoggingIn ? 'Logging in...' : 'Login',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _show('Please enter email and password.');
      return;
    }
    if (!email.contains('@')) {
      _show('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoggingIn = true);
    final error = await AuthStore.signIn(email: email, password: password);
    setState(() => _isLoggingIn = false);

    if (!mounted) return;
    if (error != null) {
      _show(error);
      return;
    }

    final user = AuthStore.currentUser.value!;
    final currentProfile = ProfileStore.profile.value;
    final username = user.email
        .split('@')
        .first
        .replaceAll(RegExp(r'\\s+'), '');
    ProfileStore.update(
      currentProfile.copyWith(name: user.name, username: username),
    );

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const Tabbars()));
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _socialButton({required String label, required IconData icon}) {
    return GestureDetector(
      onTap: () {
        _emailController.text = 'demo@rizz.app';
        _passwordController.text = '123456';
        _handleLogin();
      },
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontWeight: FontWeight.w700,
          fontSize: 11,
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
}
