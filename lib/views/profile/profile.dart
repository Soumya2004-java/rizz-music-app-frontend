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
                            style: const TextStyle(
                              color: Colors.white,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '@${profile.username}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.membership,
                                style: const TextStyle(color: Colors.white70),
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
                    children: [
                      _line(
                        'Bio',
                        profile.bio.isEmpty ? 'Not set' : profile.bio,
                      ),
                      _line(
                        'Favorite Genre',
                        profile.favoriteGenre.isEmpty
                            ? 'Not set'
                            : profile.favoriteGenre,
                      ),
                      _line(
                        'Favorite Artist',
                        profile.favoriteArtist.isEmpty
                            ? 'Not set'
                            : profile.favoriteArtist,
                      ),
                      _line(
                        'Location',
                        profile.location.isEmpty ? 'Not set' : profile.location,
                      ),
                      _line(
                        'Email',
                        AuthStore.currentUser.value?.email.isNotEmpty == true
                            ? AuthStore.currentUser.value!.email
                            : 'Not available',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _action(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your information',
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                  _action(
                    icon: Icons.library_music_rounded,
                    title: 'Your Songs',
                    subtitle: 'Open cloud song list',
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

  Widget _panel({required String title, required List<Widget> children}) {
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
            style: const TextStyle(
              color: Colors.white,
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

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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

  String _avatarText(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return 'U';
    return normalized[0].toUpperCase();
  }
}
