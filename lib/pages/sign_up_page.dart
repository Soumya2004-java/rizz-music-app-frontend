import 'package:flutter/material.dart';

import '../services/auth_store.dart';
import '../views/profile/settings/profile_store.dart';
import '../widgets/rizz_auth_ui.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RizzAuthScaffold(
      scrollable: true,
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
            const SizedBox(height: 26),
            const RizzBrandMark(compact: true),
            const SizedBox(height: 34),
            const Text(
              'Make it yours',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your account and start shaping your sound.',
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
                    controller: _nameController,
                    hint: 'Your name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 13),
                  RizzInput(
                    controller: _emailController,
                    hint: 'Email address',
                    icon: Icons.alternate_email_rounded,
                  ),
                  const SizedBox(height: 13),
                  RizzInput(
                    controller: _passwordController,
                    hint: 'Create password',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 13),
                  RizzInput(
                    controller: _confirmController,
                    hint: 'Confirm password',
                    icon: Icons.verified_user_outlined,
                    obscure: true,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 17,
                        color: Color(0xFFB6C4FF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'By continuing, you agree to the Terms and Privacy Policy.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.48),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RizzPrimaryButton(
                    label: 'Create account',
                    icon: Icons.arrow_forward_rounded,
                    loading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _handleSignUp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _show('Please fill all fields.');
      return;
    }
    if (!email.contains('@')) {
      _show('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _show('Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      _show('Passwords do not match.');
      return;
    }

    setState(() => _isSubmitting = true);
    final error = await AuthStore.signUp(
      name: name,
      email: email,
      password: password,
    );
    if (mounted) setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (error != null) {
      _show(error);
      return;
    }

    final current = ProfileStore.profile.value;
    ProfileStore.update(
      current.copyWith(
        name: name,
        username: email.split('@').first.replaceAll(RegExp(r'\s+'), ''),
      ),
    );
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
