import 'package:flutter/material.dart';

import '../services/auth_store.dart';
import '../views/profile/settings/profile_store.dart';
import '../widgets/rizz_auth_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;
  bool _isGoogleLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RizzAuthScaffold(
      scrollable: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).vertical,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 28),
              const RizzBrandMark(compact: true),
              const SizedBox(height: 38),
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick up right where the music left off.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.64),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              RizzAuthPanel(
                child: Column(
                  children: [
                    RizzInput(
                      controller: _emailController,
                      hint: 'Email address',
                      icon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 13),
                    RizzInput(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _show(
                          'Reset flow is not connected yet. Use your registered account credentials.',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB6C4FF),
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 5),
                    RizzPrimaryButton(
                      label: 'Sign in',
                      loading: _isLoggingIn,
                      onPressed: _isLoggingIn ? null : _handleLogin,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.38),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _isGoogleLoggingIn
                            ? null
                            : _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 25),
                        label: Text(
                          _isGoogleLoggingIn
                              ? 'Signing in...'
                              : 'Continue with Google',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'New to Rizz? ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/signup'),
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ),
            ],
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
    if (mounted) setState(() => _isLoggingIn = false);
    if (!mounted) return;
    if (error != null) {
      _show(error);
      return;
    }
    _onLoginSuccess();
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoggingIn = true);
    final error = await AuthStore.signInWithGoogle();
    if (mounted) setState(() => _isGoogleLoggingIn = false);
    if (!mounted) return;
    if (error != null) {
      _show(error);
      return;
    }
    _onLoginSuccess();
  }

  void _onLoginSuccess() {
    final user = AuthStore.currentUser.value!;
    final profile = ProfileStore.profile.value;
    final fallbackName = user.email.split('@').first;
    ProfileStore.update(
      profile.copyWith(
        name: user.name.trim().isEmpty ? fallbackName : user.name,
        username: fallbackName.replaceAll(RegExp(r'\s+'), ''),
      ),
    );
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
