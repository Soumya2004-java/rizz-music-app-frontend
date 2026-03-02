import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart'
    show GradientMeshBackground;
import 'profile_store.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late String _selectedPlan;

  static const plans = ['Free Member', 'Premium Member', 'Family Plan'];

  @override
  void initState() {
    super.initState();
    _selectedPlan = ProfileStore.profile.value.membership;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 8;

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
                      'Subscription',
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
              ...plans.map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PlanTile(
                    plan: plan,
                    selected: plan == _selectedPlan,
                    onTap: () => setState(() => _selectedPlan = plan),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _apply,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF89A6FF), Color(0xFF5D56FF)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Apply Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _apply() {
    final current = ProfileStore.profile.value;
    ProfileStore.update(current.copyWith(membership: _selectedPlan));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Subscription updated.')));
    Navigator.of(context).pop();
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final String plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.56)
                    : Colors.white.withValues(alpha: 0.20),
              ),
              color: selected
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    plan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: Colors.white,
                ),
              ],
            ),
          ),
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
