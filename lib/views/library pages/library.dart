import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rizzmusicapp/views/library%20pages/Albums/albums_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Artsts/artists_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Playlists/playlist_page.dart';
import 'package:rizzmusicapp/views/library%20pages/songs/songs_page.dart';

import '../../background/gradient_mesh_background.dart';
import '../../music/music_repository.dart';
import '../../songs/songs.dart';
import '../../widgets/app_loading_animation.dart';
import '../player/player_session.dart';
import 'download/download_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  Future<void> _openLikedSongs(BuildContext context) async {
    final allSongs = await MusicRepository.fetchSongs();
    final likedIds = PlayerSession.instance.likedSongIds;
    final likedSongs = allSongs
        .where((song) => likedIds.contains(song.id))
        .toList();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SongsPage(title: 'Liked Songs', songsOverride: likedSongs),
      ),
    );
  }

  Future<List<Song>> _fetchLikedSongs() async {
    final allSongs = await MusicRepository.fetchSongs();
    final likedIds = PlayerSession.instance.likedSongIds;
    return allSongs.where((song) => likedIds.contains(song.id)).toList();
  }

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
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<LibraryStats>(
              future: MusicRepository.fetchLibraryStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppLoadingAnimation());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load library: ${snapshot.error}',
                        style: TextStyle(color: primaryText),
                      ),
                    ),
                  );
                }

                final stats =
                    snapshot.data ??
                    const LibraryStats(
                      songs: 0,
                      albums: 0,
                      artists: 0,
                      playlists: 0,
                    );

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  children: [
                    Text(
                      'Library',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _glassPanel(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _statTile(
                                  value: '${stats.songs}',
                                  label: 'Songs',
                                  icon: Icons.music_note_rounded,
                                  primaryText: primaryText,
                                  secondaryText: secondaryText,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _statTile(
                                  value: '${stats.albums}',
                                  label: 'Albums',
                                  icon: Icons.album_rounded,
                                  primaryText: primaryText,
                                  secondaryText: secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _statTile(
                                  value: '${stats.artists}',
                                  label: 'Artists',
                                  icon: Icons.person_rounded,
                                  primaryText: primaryText,
                                  secondaryText: secondaryText,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _statTile(
                                  value: '${stats.playlists}',
                                  label: 'Playlists',
                                  icon: Icons.queue_music_rounded,
                                  primaryText: primaryText,
                                  secondaryText: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _glassPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _staggerReveal(
                            index: 0,
                            child: _entryTile(
                              icon: Icons.library_music_rounded,
                              title: 'Songs',
                              subtitle: 'All Firebase songs',
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SongsPage(),
                                ),
                              ),
                            ),
                          ),
                          _staggerReveal(
                            index: 1,
                            child: _entryTile(
                              icon: Icons.album_rounded,
                              title: 'Albums',
                              subtitle: 'Grouped by album name',
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AlbumsPage(),
                                ),
                              ),
                            ),
                          ),
                          _staggerReveal(
                            index: 2,
                            child: _entryTile(
                              icon: Icons.people_alt_rounded,
                              title: 'Artists',
                              subtitle: 'Grouped by artist name',
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ArtistPage(),
                                ),
                              ),
                            ),
                          ),
                          _staggerReveal(
                            index: 3,
                            child: _entryTile(
                              icon: Icons.queue_music_rounded,
                              title: 'Playlists',
                              subtitle: 'From Firestore playlists collection',
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PlaylistPage(
                                    playlistName: '',
                                    songs: [],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _staggerReveal(
                            index: 4,
                            child: _entryTile(
                              icon: Icons.download_rounded,
                              title: 'Downloads',
                              subtitle: 'Local/offline files',
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DownloadPage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _glassPanel(
                      child: FutureBuilder<List<Song>>(
                        future: _fetchLikedSongs(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 86,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: secondaryText,
                                ),
                              ),
                            );
                          }

                          final likedSongs = snapshot.data ?? const <Song>[];
                          if (likedSongs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                'No liked songs yet',
                                style: TextStyle(color: secondaryText),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Liked Songs',
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 168,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: likedSongs.length.clamp(0, 10),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final song = likedSongs[index];
                                    return _staggerReveal(
                                      index: index,
                                      child: _likedSongCard(
                                        context,
                                        song,
                                        likedSongs,
                                        primaryText: primaryText,
                                        secondaryText: secondaryText,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (likedSongs.length > 6) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _openLikedSongs(context),
                                    child: Text(
                                      'View all',
                                      style: TextStyle(color: primaryText),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassPanel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _statTile({
    required String value,
    required String label,
    required IconData icon,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: secondaryText, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(label, style: TextStyle(color: secondaryText, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _entryTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: primaryText),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: secondaryText),
          ],
        ),
      ),
    );
  }

  Widget _likedSongCard(
    BuildContext context,
    Song song,
    List<Song> queue, {
    required Color primaryText,
    required Color secondaryText,
  }) {
    final image = song.imageUrl?.trim() ?? '';
    return InkWell(
      onTap: () {
        final session = PlayerSession.instance;
        session.setQueue(queue, currentSong: song);
        session.playSong(song);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 132,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: double.infinity,
                height: 96,
                child: image.startsWith('http')
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _albumFallbackCover(secondaryText: secondaryText),
                      )
                    : _albumFallbackCover(secondaryText: secondaryText),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondaryText, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _albumFallbackCover({required Color secondaryText}) {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      child: Icon(Icons.music_note_rounded, color: secondaryText),
    );
  }

  Widget _staggerReveal({required int index, required Widget child}) {
    final delay = (index * 35).clamp(0, 280);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, builtChild) {
        final t = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - t)),
            child: builtChild,
          ),
        );
      },
      child: child,
    );
  }
}
