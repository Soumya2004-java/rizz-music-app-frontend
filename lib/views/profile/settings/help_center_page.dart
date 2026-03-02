import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart'
    show GradientMeshBackground;

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 8;

    const items = [
      (
        'How to download songs?',
        'Open any album/playlist and tap the download icon near each track.',
      ),
      (
        'How to change audio quality?',
        'Go to Settings > Audio & Downloads > Audio Quality.',
      ),
      ('How to edit profile?', 'Open Profile tab and tap Edit Profile.'),
      (
        'How to manage subscription?',
        'Go to Settings > Subscription Plan and select a plan.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.24),
                    Colors.black.withValues(alpha: 0.56),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: const SizedBox.expand(),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(20, top, 20, 16),
            children: [
              Row(
                children: [
                  _CircleGlassButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Help Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FaqTile(question: item.$1, answer: item.$2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          collapsedBackgroundColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          ),
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                answer,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleGlassButton extends StatelessWidget {
  const _CircleGlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
