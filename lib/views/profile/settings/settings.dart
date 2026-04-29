import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';
import '../../../pages/sign_in_or_sign_up_page.dart';
import '../../../services/auth_store.dart';
import '../../../widgets/app_loading_animation.dart';
import 'change_password_page.dart';
import 'edit profile /edit_profile.dart';
import 'help_center_page.dart';
import 'profile_store.dart';
import 'report_problem_page.dart';
import 'settings_store.dart';
import 'subscription_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.focusProfile = false,
    this.focusEqualizer = false,
  });

  final bool focusProfile;
  final bool focusEqualizer;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AppConfigData _config = AppConfigData.defaults();
  UserSettingsData _settings = UserSettingsData.defaults();
  bool _loading = true;
  final GlobalKey _equalizerTileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await SettingsStore.fetchAppConfig();
    final settings = await SettingsStore.fetchUserSettings();
    if (!mounted) return;
    setState(() {
      _config = config;
      _settings = settings;
      _loading = false;
    });
    if (widget.focusEqualizer) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEqualizer());
    }
  }

  Future<void> _save() => SettingsStore.saveUserSettings(_settings);

  void _scrollToEqualizer() {
    final targetContext = _equalizerTileKey.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
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
            const Center(child: AppLoadingAnimation(size: 220))
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
                    const SizedBox(width: 8),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _section(
                  title: 'Account',
                  child: Column(
                    children: [
                      _navTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        subtitle: 'Name, bio and preferences',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        ),
                      ),
                      _navTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        subtitle: 'Update sign-in password',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<ProfileData>(
                        valueListenable: ProfileStore.profile,
                        builder: (context, profile, _) => _navTile(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Subscription Plan',
                          subtitle: profile.membership,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'Playback',
                  child: Column(
                    children: [
                      _switchTile(
                        icon: Icons.play_circle_outline_rounded,
                        title: 'Autoplay',
                        value: _settings.autoplay,
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: v,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: _settings.normalizeAudio,
                            crossfade: _settings.crossfade,
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: _settings.dolbyAtmos,
                            highResMusic: _settings.highResMusic,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: _settings.theme,
                            language: _settings.language,
                            cacheLimit: _settings.cacheLimit,
                          ),
                        ),
                      ),
                      _switchTile(
                        icon: Icons.graphic_eq_rounded,
                        title: 'Normalize Audio',
                        value: _settings.normalizeAudio,
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: _settings.autoplay,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: v,
                            crossfade: _settings.crossfade,
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: _settings.dolbyAtmos,
                            highResMusic: _settings.highResMusic,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: _settings.theme,
                            language: _settings.language,
                            cacheLimit: _settings.cacheLimit,
                          ),
                        ),
                      ),
                      _choiceTile(
                        icon: Icons.compare_arrows_rounded,
                        title: 'Crossfade',
                        value: _settings.crossfade ? 'On' : 'Off',
                        options: const ['On', 'Off'],
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: _settings.autoplay,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: _settings.normalizeAudio,
                            crossfade: v == 'On',
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: _settings.dolbyAtmos,
                            highResMusic: _settings.highResMusic,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: _settings.theme,
                            language: _settings.language,
                            cacheLimit: _settings.cacheLimit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'Audio & Preferences',
                  child: Column(
                    children: [
                      _choiceTile(
                        icon: Icons.spatial_audio_rounded,
                        title: 'Dolby Atmos',
                        value: _settings.dolbyAtmos,
                        options: _config.dolbyAtmosOptions,
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: _settings.autoplay,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: _settings.normalizeAudio,
                            crossfade: _settings.crossfade,
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: v,
                            highResMusic: _settings.highResMusic,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: _settings.theme,
                            language: _settings.language,
                            cacheLimit: _settings.cacheLimit,
                          ),
                        ),
                      ),
                      _choiceTile(
                        icon: Icons.high_quality_rounded,
                        title: 'High-Res Music',
                        value: _settings.highResMusic,
                        options: _config.highResOptions,
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: _settings.autoplay,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: _settings.normalizeAudio,
                            crossfade: _settings.crossfade,
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: _settings.dolbyAtmos,
                            highResMusic: v,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: _settings.theme,
                            language: _settings.language,
                            cacheLimit: _settings.cacheLimit,
                          ),
                        ),
                      ),
                      Container(
                        key: _equalizerTileKey,
                        child: _choiceTile(
                          icon: Icons.equalizer_rounded,
                          title: 'Equalizer Preset',
                          value: _settings.equalizerPreset,
                          options: _config.equalizerPresets,
                          onChanged: (v) => _update(
                            _settings = UserSettingsData(
                              autoplay: _settings.autoplay,
                              wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                              normalizeAudio: _settings.normalizeAudio,
                              crossfade: _settings.crossfade,
                              equalizerEnabled: _settings.equalizerEnabled,
                              pushNewReleases: _settings.pushNewReleases,
                              pushRecommendations:
                                  _settings.pushRecommendations,
                              privateSession: _settings.privateSession,
                              listeningActivityVisible:
                                  _settings.listeningActivityVisible,
                              biometricLock: _settings.biometricLock,
                              crossfadeSeconds: _settings.crossfadeSeconds,
                              bassLevel: _settings.bassLevel,
                              midLevel: _settings.midLevel,
                              trebleLevel: _settings.trebleLevel,
                              dolbyAtmos: _settings.dolbyAtmos,
                              highResMusic: _settings.highResMusic,
                              equalizerPreset: v,
                              theme: _settings.theme,
                              language: _settings.language,
                              cacheLimit: _settings.cacheLimit,
                            ),
                          ),
                        ),
                      ),
                      _choiceTile(
                        icon: Icons.storage_rounded,
                        title: 'Offline Cache Limit',
                        value: _settings.cacheLimit,
                        options: _config.cacheLimits,
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: _settings.autoplay,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: _settings.normalizeAudio,
                            crossfade: _settings.crossfade,
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: _settings.dolbyAtmos,
                            highResMusic: _settings.highResMusic,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: _settings.theme,
                            language: _settings.language,
                            cacheLimit: v,
                          ),
                        ),
                      ),
                      _choiceTile(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        value: _settings.theme,
                        options: _config.themes,
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: _settings.autoplay,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: _settings.normalizeAudio,
                            crossfade: _settings.crossfade,
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: _settings.dolbyAtmos,
                            highResMusic: _settings.highResMusic,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: v,
                            language: _settings.language,
                            cacheLimit: _settings.cacheLimit,
                          ),
                        ),
                      ),
                      _choiceTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        value: _settings.language,
                        options: _config.languages,
                        onChanged: (v) => _update(
                          _settings = UserSettingsData(
                            autoplay: _settings.autoplay,
                            wifiOnlyDownloads: _settings.wifiOnlyDownloads,
                            normalizeAudio: _settings.normalizeAudio,
                            crossfade: _settings.crossfade,
                            equalizerEnabled: _settings.equalizerEnabled,
                            pushNewReleases: _settings.pushNewReleases,
                            pushRecommendations: _settings.pushRecommendations,
                            privateSession: _settings.privateSession,
                            listeningActivityVisible:
                                _settings.listeningActivityVisible,
                            biometricLock: _settings.biometricLock,
                            crossfadeSeconds: _settings.crossfadeSeconds,
                            bassLevel: _settings.bassLevel,
                            midLevel: _settings.midLevel,
                            trebleLevel: _settings.trebleLevel,
                            dolbyAtmos: _settings.dolbyAtmos,
                            highResMusic: _settings.highResMusic,
                            equalizerPreset: _settings.equalizerPreset,
                            theme: _settings.theme,
                            language: v,
                            cacheLimit: _settings.cacheLimit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _section(
                  title: 'Help',
                  child: Column(
                    children: [
                      _navTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        subtitle: 'FAQs from Firestore config',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterPage(),
                          ),
                        ),
                      ),
                      _navTile(
                        icon: Icons.bug_report_outlined,
                        title: 'Report a Problem',
                        subtitle: 'Send issue to Firestore',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReportProblemPage(),
                          ),
                        ),
                      ),
                      _navTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About App',
                        subtitle: 'Version ${_config.aboutVersion}',
                        onTap: _showAbout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    AuthStore.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInOrSignUp()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _update(UserSettingsData data) {
    setState(() => _settings = data);
    _save();
  }

  Widget _buildGlassDialog({required Widget child}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.28),
                  const Color(0xFFB8D3F0).withValues(alpha: 0.18),
                  const Color(0xFF9DB5D6).withValues(alpha: 0.14),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.36),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Future<void> _showChoiceDialog({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _buildGlassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  children: options
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => Navigator.of(dialogContext).pop(item),
                          leading: Icon(
                            item == value
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: Colors.white,
                          ),
                          title: Text(
                            item,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF10151D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null && selected != value) {
      onChanged(selected);
    }
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _buildGlassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _config.aboutAppName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Version ${_config.aboutVersion}\n\n'
              '${_config.aboutDescription}\n\n'
              'Core Developer: Soumyadeep jana\n'
              'Email: ${_config.aboutDeveloperEmail}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFF10151D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      secondary: Icon(icon, color: Colors.white),
      activeThumbColor: Colors.white,
      activeTrackColor: Colors.white.withValues(alpha: 0.5),
    );
  }

  Widget _choiceTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final safeValue = options.contains(value)
        ? value
        : (options.isNotEmpty ? options.first : value);

    return ListTile(
      onTap: () => _showChoiceDialog(
        title: title,
        value: safeValue,
        options: options,
        onChanged: onChanged,
      ),
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            safeValue,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.expand_more_rounded,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}
