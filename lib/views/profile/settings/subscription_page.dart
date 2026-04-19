import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';
import 'profile_store.dart';
import 'settings_store.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<String> _plans = const ['Free Member', 'Premium Member', 'Family Plan'];
  String _selectedPlan = 'Free Member';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedPlan = ProfileStore.profile.value.membership;
    _load();
  }

  Future<void> _load() async {
    final config = await SettingsStore.fetchAppConfig();
    if (!mounted) return;
    setState(() {
      _plans = config.membershipPlans;
      if (!_plans.contains(_selectedPlan) && _plans.isNotEmpty) {
        _selectedPlan = _plans.first;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 10,
                16,
                20,
              ),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Subscription',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._plans.map(
                  (plan) => RadioListTile<String>(
                    value: plan,
                    groupValue: _selectedPlan,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPlan = value);
                      }
                    },
                    title: Text(
                      plan,
                      style: const TextStyle(color: Colors.white),
                    ),
                    activeColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _apply,
                  child: const Text('Apply Plan'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _apply() {
    ProfileStore.update(
      ProfileStore.profile.value.copyWith(membership: _selectedPlan),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Subscription updated.')));
    Navigator.of(context).pop();
  }
}
