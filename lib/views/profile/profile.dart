import 'package:flutter/material.dart';

import '../../background/gradient_mesh_background.dart';
import '../../services/auth_store.dart';
import '../library pages/songs/songs_page.dart';
import 'settings/edit profile /edit_profile.dart';
import 'settings/profile_store.dart';
import 'settings/settings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = isLight ? const Color(0xFF5F6368) : Colors.white;
    final secondaryText = isLight ? const Color(0xFF7A7F87) : Colors.white70;

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
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder<ProfileData>(
            valueListenable: ProfileStore.profile,
            builder: (context, profile, _) {
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 16,
                  16,
                  120,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white.withValues(alpha: 0.24),
                          child: Text(
                            _avatarText(profile.name),
                            style: TextStyle(
                              color: primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '@${profile.username}',
                                style: TextStyle(color: secondaryText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.membership,
                                style: TextStyle(color: secondaryText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _panel(
                    title: 'About',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    children: [
                      _line(
                        'Bio',
                        profile.bio.isEmpty ? 'Not set' : profile.bio,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      _line(
                        'Favorite Genre',
                        profile.favoriteGenre.isEmpty
                            ? 'Not set'
                            : profile.favoriteGenre,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      _line(
                        'Favorite Artist',
                        profile.favoriteArtist.isEmpty
                            ? 'Not set'
                            : profile.favoriteArtist,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      _line(
                        'Location',
                        profile.location.isEmpty ? 'Not set' : profile.location,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      _line(
                        'Email',
                        AuthStore.currentUser.value?.email.isNotEmpty == true
                            ? AuthStore.currentUser.value!.email
                            : 'Not available',
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _action(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your information',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    ),
                  ),
                  _action(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences and controls',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                  _action(
                    icon: Icons.library_music_rounded,
                    title: 'Your Songs',
                    subtitle: 'Open cloud song list',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SongsPage()),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required String title,
    required Color primaryText,
    required Color secondaryText,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _line(
    String label,
    String value, {
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: secondaryText, fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: primaryText, fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: primaryText),
      title: Text(title, style: TextStyle(color: primaryText)),
      subtitle: Text(subtitle, style: TextStyle(color: secondaryText)),
      trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
    );
  }

  String _avatarText(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return 'U';
    return normalized[0].toUpperCase();
  }
}
