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
    final primaryText = isLight ? const Color(0xFF243042) : Colors.white;
    final secondaryText = isLight ? const Color(0xFF5A6578) : Colors.white70;
    final cardSurface = isLight
        ? Colors.white.withValues(alpha: 0.84)
        : Colors.white.withValues(alpha: 0.10);

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
              final email =
                  AuthStore.currentUser.value?.email.isNotEmpty == true
                  ? AuthStore.currentUser.value!.email
                  : 'Not available';

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 16,
                  16,
                  120,
                ),
                children: [
                  _heroCard(
                    profile: profile,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardSurface: cardSurface,
                  ),
                  const SizedBox(height: 12),
                  _quickStats(
                    profile: profile,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardSurface: cardSurface,
                  ),
                  const SizedBox(height: 12),
                  _panel(
                    title: 'About',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardSurface: cardSurface,
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
                        email,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _primaryAction(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _outlineAction(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          primaryText: primaryText,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _actionTile(
                    icon: Icons.library_music_rounded,
                    title: 'Your Songs',
                    subtitle: 'Open cloud song list',
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    cardSurface: cardSurface,
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

  Widget _heroCard({
    required ProfileData profile,
    required Color primaryText,
    required Color secondaryText,
    required Color cardSurface,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7B68), Color(0xFFFFAA5A)],
              ),
            ),
            child: Center(
              child: Text(
                _avatarText(profile.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '@${profile.username}',
                  style: TextStyle(
                    color: secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.membership,
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStats({
    required ProfileData profile,
    required Color primaryText,
    required Color secondaryText,
    required Color cardSurface,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Genre',
            value: profile.favoriteGenre.isEmpty
                ? 'Not set'
                : profile.favoriteGenre,
            icon: Icons.equalizer_rounded,
            primaryText: primaryText,
            secondaryText: secondaryText,
            cardSurface: cardSurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Artist',
            value: profile.favoriteArtist.isEmpty
                ? 'Not set'
                : profile.favoriteArtist,
            icon: Icons.mic_rounded,
            primaryText: primaryText,
            secondaryText: secondaryText,
            cardSurface: cardSurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Location',
            value: profile.location.isEmpty ? 'Not set' : profile.location,
            icon: Icons.location_on_outlined,
            primaryText: primaryText,
            secondaryText: secondaryText,
            cardSurface: cardSurface,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color primaryText,
    required Color secondaryText,
    required Color cardSurface,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryText, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required String title,
    required Color primaryText,
    required Color secondaryText,
    required Color cardSurface,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardSurface,
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

  Widget _primaryAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.edit_outlined),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        backgroundColor: const Color(0xFFFF6F61),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _outlineAction({
    required IconData icon,
    required String title,
    required Color primaryText,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: primaryText),
      label: Text(title, style: TextStyle(color: primaryText)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryText,
    required Color secondaryText,
    required Color cardSurface,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: primaryText),
        title: Text(title, style: TextStyle(color: primaryText)),
        subtitle: Text(subtitle, style: TextStyle(color: secondaryText)),
        trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
      ),
    );
  }

  String _avatarText(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return 'U';
    return normalized[0].toUpperCase();
  }
}
