import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart'
    show GradientMeshBackground;
import '../../../pages/sign_in_or_sign_up_page.dart';
import '../../../services/auth_store.dart';
import 'change_password_page.dart';
import 'edit profile /edit_profile.dart';
import 'help_center_page.dart';
import 'profile_store.dart';
import 'report_problem_page.dart';
import 'subscription_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.focusProfile = false});

  final bool focusProfile;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _wifiOnlyDownloads = true;
  bool _normalizeAudio = true;
  bool _autoplay = true;
  bool _crossfade = true;
  bool _equalizerEnabled = true;
  bool _pushNewReleases = true;
  bool _pushRecommendations = true;
  bool _privateSession = false;
  bool _listeningActivityVisible = true;
  bool _biometricLock = false;

  double _crossfadeSeconds = 6;
  double _bassLevel = 0;
  double _midLevel = 0;
  double _trebleLevel = 0;
  String _dolbyAtmos = 'Automatic';
  String _highResMusic = 'On';
  String _equalizerPreset = 'Pop';
  String _theme = 'System';
  String _language = 'English';
  String _cacheLimit = '2 GB';

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final topSectionGap = topPadding + 8;

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
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topSectionGap, 20, 8),
                  child: Row(
                    children: [
                      _CircleGlassButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionCard(
                      title: widget.focusProfile
                          ? 'Profile Settings'
                          : 'Account & Profile',
                      children: [
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Profile Settings',
                          subtitle: 'Name, photo, bio and username',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          subtitle: 'Update your sign-in password',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                        ValueListenableBuilder<ProfileData>(
                          valueListenable: ProfileStore.profile,
                          builder: (context, profile, _) => _SettingsTile(
                            icon: Icons.credit_card_outlined,
                            title: 'Subscription Plan',
                            subtitle: profile.membership,
                            trailingText: 'Manage',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SubscriptionPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Playback',
                      children: [
                        _SettingsSwitchTile(
                          icon: Icons.play_circle_outline_rounded,
                          title: 'Autoplay Similar Tracks',
                          subtitle: 'Continue playback with recommendations',
                          value: _autoplay,
                          onChanged: (value) =>
                              setState(() => _autoplay = value),
                        ),
                        _SettingsSwitchTile(
                          icon: Icons.graphic_eq_rounded,
                          title: 'Normalize Audio',
                          subtitle: 'Keep volume consistent across tracks',
                          value: _normalizeAudio,
                          onChanged: (value) =>
                              setState(() => _normalizeAudio = value),
                        ),
                        _SettingsSwitchTile(
                          icon: Icons.compare_arrows_rounded,
                          title: 'Crossfade',
                          subtitle: 'Blend songs for smoother transitions',
                          value: _crossfade,
                          onChanged: (value) =>
                              setState(() => _crossfade = value),
                        ),
                        if (_crossfade)
                          _SliderTile(
                            icon: Icons.timelapse_rounded,
                            title: 'Crossfade Duration',
                            valueLabel: '${_crossfadeSeconds.round()} sec',
                            value: _crossfadeSeconds,
                            min: 0,
                            max: 12,
                            onChanged: (value) =>
                                setState(() => _crossfadeSeconds = value),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Equalizer',
                      children: [
                        _SettingsSwitchTile(
                          icon: Icons.equalizer_rounded,
                          title: 'Enable Equalizer',
                          subtitle: 'Shape your sound profile',
                          value: _equalizerEnabled,
                          onChanged: (value) =>
                              setState(() => _equalizerEnabled = value),
                        ),
                        if (_equalizerEnabled)
                          _SettingsChoiceTile(
                            icon: Icons.tune_rounded,
                            title: 'Preset',
                            subtitle: _equalizerPreset,
                            options: const [
                              'Flat',
                              'Pop',
                              'Rock',
                              'Hip-Hop',
                              'Classical',
                              'Jazz',
                              'Electronic',
                              'Vocal',
                            ],
                            value: _equalizerPreset,
                            onChanged: (value) =>
                                setState(() => _equalizerPreset = value),
                          ),
                        if (_equalizerEnabled)
                          _EqualizerBarsTile(
                            bass: _bassLevel,
                            mid: _midLevel,
                            treble: _trebleLevel,
                            valueFormatter: _formatEqDb,
                            onBassChanged: (value) =>
                                setState(() => _bassLevel = value),
                            onMidChanged: (value) =>
                                setState(() => _midLevel = value),
                            onTrebleChanged: (value) =>
                                setState(() => _trebleLevel = value),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Audio & Downloads',
                      children: [
                        _AppleMusicStreamingTile(
                          icon: Icons.high_quality_rounded,
                          dolbyAtmosValue: _dolbyAtmos,
                          highResMusicValue: _highResMusic,
                          onDolbyAtmosChanged: (value) =>
                              setState(() => _dolbyAtmos = value),
                          onHighResMusicChanged: (value) =>
                              setState(() => _highResMusic = value),
                        ),
                        _SettingsSwitchTile(
                          icon: Icons.wifi_rounded,
                          title: 'Download on Wi-Fi Only',
                          subtitle: 'Avoid mobile data usage',
                          value: _wifiOnlyDownloads,
                          onChanged: (value) =>
                              setState(() => _wifiOnlyDownloads = value),
                        ),
                        _SettingsChoiceTile(
                          icon: Icons.storage_rounded,
                          title: 'Offline Cache Limit',
                          subtitle: _cacheLimit,
                          options: const ['1 GB', '2 GB', '5 GB', '10 GB'],
                          value: _cacheLimit,
                          onChanged: (value) =>
                              setState(() => _cacheLimit = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Notifications',
                      children: [
                        _SettingsSwitchTile(
                          icon: Icons.new_releases_outlined,
                          title: 'New Release Alerts',
                          subtitle: 'Artists and playlists you follow',
                          value: _pushNewReleases,
                          onChanged: (value) =>
                              setState(() => _pushNewReleases = value),
                        ),
                        _SettingsSwitchTile(
                          icon: Icons.recommend_outlined,
                          title: 'Personalized Recommendations',
                          subtitle: 'Weekly and daily picks',
                          value: _pushRecommendations,
                          onChanged: (value) =>
                              setState(() => _pushRecommendations = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Privacy & Security',
                      children: [
                        _SettingsSwitchTile(
                          icon: Icons.visibility_off_outlined,
                          title: 'Private Session',
                          subtitle: 'Hide listening activity temporarily',
                          value: _privateSession,
                          onChanged: (value) =>
                              setState(() => _privateSession = value),
                        ),
                        _SettingsSwitchTile(
                          icon: Icons.people_outline_rounded,
                          title: 'Show Listening Activity',
                          subtitle: 'Visible to followers',
                          value: _listeningActivityVisible,
                          onChanged: (value) =>
                              setState(() => _listeningActivityVisible = value),
                        ),
                        _SettingsSwitchTile(
                          icon: Icons.fingerprint_rounded,
                          title: 'Biometric App Lock',
                          subtitle: 'Require authentication on app open',
                          value: _biometricLock,
                          onChanged: (value) =>
                              setState(() => _biometricLock = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'App Preferences',
                      children: [
                        _SettingsChoiceTile(
                          icon: Icons.palette_outlined,
                          title: 'Theme',
                          subtitle: _theme,
                          options: const ['System', 'Light', 'Dark'],
                          value: _theme,
                          onChanged: (value) => setState(() => _theme = value),
                        ),
                        _SettingsChoiceTile(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          subtitle: _language,
                          options: const ['English', 'Hindi', 'Spanish'],
                          value: _language,
                          onChanged: (value) =>
                              setState(() => _language = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Help',
                      children: [
                        _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help Center',
                          subtitle: 'FAQs and troubleshooting',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const HelpCenterPage(),
                              ),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.bug_report_outlined,
                          title: 'Report a Problem',
                          subtitle: 'Send feedback to our team',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ReportProblemPage(),
                              ),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About App',
                          subtitle: 'Version 1.0.0',
                          onTap: _showAboutDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _GlassActionButton(
                      label: 'Sign Out',
                      icon: Icons.logout_rounded,
                      onTap: _signOut,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121722),
        title: const Text(
          'Rizz Music App',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Version 1.0.0\n\nA modern music streaming experience with profile personalization, audio controls, and library browsing.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    AuthStore.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInOrSignUp()),
      (_) => false,
    );
  }

  String _formatEqDb(double value) {
    final rounded = value.round();
    if (rounded == 0) return '0 dB';
    if (rounded > 0) return '+$rounded dB';
    return '$rounded dB';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: trailingText == null
          ? const Icon(Icons.chevron_right_rounded, color: Colors.white70)
          : Text(
              trailingText!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.white.withValues(alpha: 0.5),
      ),
      onTap: () => onChanged(!value),
    );
  }
}

class _AppleMusicStreamingTile extends StatelessWidget {
  const _AppleMusicStreamingTile({
    required this.icon,
    required this.dolbyAtmosValue,
    required this.highResMusicValue,
    required this.onDolbyAtmosChanged,
    required this.onHighResMusicChanged,
  });

  final IconData icon;
  final String dolbyAtmosValue;
  final String highResMusicValue;
  final ValueChanged<String> onDolbyAtmosChanged;
  final ValueChanged<String> onHighResMusicChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _LeadingIcon(icon: icon),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Quality',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Apple Music style spatial + hi-res setup',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _qualityRow(
            label: 'Dolby Atmos',
            value: dolbyAtmosValue,
            onTap: () => _showPicker(
              context: context,
              title: 'Dolby Atmos',
              options: const ['Automatic', 'Always On', 'Off'],
              value: dolbyAtmosValue,
              onChanged: onDolbyAtmosChanged,
            ),
          ),
          _qualityRow(
            label: 'High-Res Music',
            value: highResMusicValue,
            isLast: true,
            onTap: () => _showPicker(
              context: context,
              title: 'High-Res Music',
              options: const ['On', 'Off'],
              value: highResMusicValue,
              onChanged: onHighResMusicChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualityRow({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (label == 'High-Res Music' && value == 'On')
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Text(
                  'HI-RES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _showPicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF121722),
      builder: (sheetContext) {
        final maxSheetHeight = MediaQuery.sizeOf(sheetContext).height * 0.75;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...options.map(
                    (option) => ListTile(
                      title: Text(
                        option,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: option == value
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                      onTap: () {
                        onChanged(option);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsChoiceTile extends StatelessWidget {
  const _SettingsChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.expand_more_rounded, color: Colors.white70),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF121722),
        builder: (sheetContext) {
          final maxSheetHeight = MediaQuery.sizeOf(sheetContext).height * 0.75;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...options.map(
                      (option) => ListTile(
                        title: Text(
                          option,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: option == value
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                              )
                            : null,
                        onTap: () {
                          onChanged(option);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.icon,
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _LeadingIcon(icon: icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _EqualizerBarsTile extends StatelessWidget {
  const _EqualizerBarsTile({
    required this.bass,
    required this.mid,
    required this.treble,
    required this.valueFormatter,
    required this.onBassChanged,
    required this.onMidChanged,
    required this.onTrebleChanged,
  });

  final double bass;
  final double mid;
  final double treble;
  final String Function(double) valueFormatter;
  final ValueChanged<double> onBassChanged;
  final ValueChanged<double> onMidChanged;
  final ValueChanged<double> onTrebleChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _LeadingIcon(icon: Icons.graphic_eq_rounded),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Equalizer Bands',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: _EqualizerBand(
                    label: 'Bass',
                    value: bass,
                    valueLabel: valueFormatter(bass),
                    onChanged: onBassChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _EqualizerBand(
                    label: 'Mid',
                    value: mid,
                    valueLabel: valueFormatter(mid),
                    onChanged: onMidChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _EqualizerBand(
                    label: 'Treble',
                    value: treble,
                    valueLabel: valueFormatter(treble),
                    onChanged: onTrebleChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualizerBand extends StatelessWidget {
  const _EqualizerBand({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            valueLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: value,
                min: -12,
                max: 12,
                onChanged: onChanged,
                activeColor: Colors.white,
                inactiveColor: Colors.white24,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseTile extends StatelessWidget {
  const _BaseTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            _LeadingIcon(icon: icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 19),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
