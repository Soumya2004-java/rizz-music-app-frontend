import 'package:flutter/material.dart';

import '../../services/auth_store.dart';
import '../library pages/songs/songs_page.dart';
import 'settings/edit profile /edit_profile.dart';
import 'settings/profile_store.dart';
import 'settings/settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _refresh() async {
    await ProfileStore.refresh();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = isLight ? const Color(0xFF243042) : Colors.white;
    final secondaryText = isLight ? const Color(0xFF5A6578) : Colors.white70;
    final cardSurface = isLight
        ? Colors.white.withValues(alpha: 0.84)
        : Colors.white.withValues(alpha: 0.10);

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -130,
            child: _ambientGlow(320, const Color(0xFF596FEA), 0.16),
          ),
          Positioned(
            top: 300,
            right: -170,
            child: _ambientGlow(320, const Color(0xFFFF876C), 0.09),
          ),
          ValueListenableBuilder<ProfileData>(
            valueListenable: ProfileStore.profile,
            builder: (context, profile, _) {
              final email =
                  AuthStore.currentUser.value?.email.isNotEmpty == true
                  ? AuthStore.currentUser.value!.email
                  : 'Not available';

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 18,
                    20,
                    120,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Settings',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          ),
                          style: IconButton.styleFrom(
                            foregroundColor: primaryText,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                          ),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                      title: 'Your vibe',
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
                          profile.location.isEmpty
                              ? 'Not set'
                              : profile.location,
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
                ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF262D49).withValues(alpha: 0.92),
            const Color(0xFF171B29).withValues(alpha: 0.88),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _avatar(profile),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9CAEFF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1B2032),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: Color(0xFF10162B),
                  ),
                ),
              ),
            ],
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
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB6C4FF).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF151927).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF9CAEFF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: const Color(0xFFB6C4FF), size: 17),
          ),
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
        color: const Color(0xFF151927).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
        backgroundColor: const Color(0xFF9CAEFF),
        foregroundColor: const Color(0xFF10162B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        color: const Color(0xFF151927).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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

  Widget _avatar(ProfileData profile) {
    final hasPhoto = profile.photoUrl.isNotEmpty;
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasPhoto
            ? null
            : const LinearGradient(
                colors: [Color(0xFFFF7B68), Color(0xFFFFAA5A)],
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              profile.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _avatarInitials(profile.name),
            )
          : _avatarInitials(profile.name),
    );
  }

  Widget _avatarInitials(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7B68), Color(0xFFFFAA5A)],
        ),
      ),
      child: Center(
        child: Text(
          _avatarText(name),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
      ),
    );
  }

  String _avatarText(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return 'U';
    return normalized[0].toUpperCase();
  }

  Widget _ambientGlow(double size, Color color, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
