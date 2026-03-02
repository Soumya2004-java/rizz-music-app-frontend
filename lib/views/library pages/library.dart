import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rizzmusicapp/songs/albums/album_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Artsts/artists_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Playlists/playlist_page.dart';
import 'package:rizzmusicapp/views/library%20pages/songs/songs_page.dart';

import '../../background/gradient_mesh_background.dart';
import 'download/download_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

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
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.40),
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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Space',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _glassPanel(
                        borderRadius: 28,
                        child: Column(
                          children: const [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatChip(
                                    value: '122',
                                    label: 'Playlists',
                                    icon: Icons.queue_music_rounded,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _StatChip(
                                    value: '4.8K',
                                    label: 'Saved Songs',
                                    icon: Icons.music_note_rounded,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatChip(
                                    value: '63',
                                    label: 'Albums',
                                    icon: Icons.album_rounded,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: _StatChip(
                                    value: '17',
                                    label: 'Downloads',
                                    icon: Icons.download_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Browse Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _glassPanel(
                        borderRadius: 24,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Column(
                          children: [
                            _entryTile(
                              icon: Icons.queue_music_rounded,
                              title: 'Playlists',
                              subtitle: 'Your curated collections',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaylistPage(
                                      playlistName: '',
                                      songs: [],
                                    ),
                                  ),
                                );
                              },
                            ),
                            _entryTile(
                              icon: Icons.person_rounded,
                              title: 'Artists',
                              subtitle: 'Following and favorites',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ArtistPage(),
                                  ),
                                );
                              },
                            ),
                            _entryTile(
                              icon: Icons.album_rounded,
                              title: 'Albums',
                              subtitle: 'Full releases and collections',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlbumPage(artist: ''),
                                  ),
                                );
                              },
                            ),
                            _entryTile(
                              icon: Icons.library_music_rounded,
                              title: 'Songs',
                              subtitle: 'All tracks in one place',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SongsPage(),
                                  ),
                                );
                              },
                            ),
                            _entryTile(
                              icon: Icons.download_rounded,
                              title: 'Downloads',
                              subtitle: 'Offline listening',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DownloadPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _glassPanel(
                        borderRadius: 22,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tip: Pin your most-used playlists for quicker access.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _glassPanel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double borderRadius = 22,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _entryTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
