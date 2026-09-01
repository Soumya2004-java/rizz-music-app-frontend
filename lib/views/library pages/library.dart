import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rizzmusicapp/views/library%20pages/Albums/albums_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Artsts/artists_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Playlists/playlist_page.dart';
import 'package:rizzmusicapp/views/library%20pages/songs/songs_page.dart';

import '../../music/music_repository.dart';
import '../../songs/songs.dart';
import '../../widgets/app_skeletons.dart';
import '../player/player_session.dart';
import 'download/download_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<LibraryStats> _libraryStatsFuture;
  late Future<List<Song>> _likedSongsFuture;

  @override
  void initState() {
    super.initState();
    _libraryStatsFuture = MusicRepository.fetchLibraryStats();
    _likedSongsFuture = _fetchLikedSongs();
  }

  Future<void> _refresh() async {
    MusicRepository.clearCaches();
    setState(() {
      _libraryStatsFuture = MusicRepository.fetchLibraryStats();
      _likedSongsFuture = _fetchLikedSongs();
    });
    await Future.wait([_libraryStatsFuture, _likedSongsFuture]);
  }

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
      backgroundColor: const Color(0xFF07090F),
      body: Stack(
        children: [
          Positioned(
            top: -170,
            right: -120,
            child: _ambientGlow(330, const Color(0xFF596FEA), 0.18),
          ),
          Positioned(
            top: 240,
            left: -160,
            child: _ambientGlow(310, const Color(0xFFFF876C), 0.10),
          ),
          SafeArea(
            child: FutureBuilder<LibraryStats>(
              future: _libraryStatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListPageSkeleton();
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

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Your Library',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh library',
                            onPressed: _refresh,
                            style: IconButton.styleFrom(
                              foregroundColor: primaryText,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Everything you love, all in one place.',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _glassPanel(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    color: const Color(0xFF9CAEFF),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Color(0xFF10162B),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your collection',
                                        style: TextStyle(
                                          color: primaryText,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Saved music at a glance',
                                        style: TextStyle(
                                          color: secondaryText,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                      const SizedBox(height: 18),
                      Text(
                        'Browse your music',
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 18),
                      _glassPanel(
                        child: FutureBuilder<List<Song>>(
                          future: _likedSongsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const AppSkeletonScope(
                                child: SizedBox(
                                  height: 86,
                                  child: AppSkeletonBox(height: 86, radius: 14),
                                ),
                              );
                            }

                            final likedSongs = snapshot.data ?? const <Song>[];
                            if (likedSongs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
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
                                  'Your liked songs',
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
                  ),
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
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF151927).withValues(alpha: 0.82),
            border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
            borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.circular(17),
        color: Colors.black.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF9CAEFF).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: const Color(0xFFB6C4FF), size: 17),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF9CAEFF).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: const Color(0xFFB6C4FF), size: 20),
            ),
            const SizedBox(width: 12),
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
