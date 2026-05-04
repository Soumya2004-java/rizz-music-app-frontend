import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';
import '../../../services/song_download_service.dart';
import '../../../songs/songs.dart';
import '../../player/player_scrreen.dart';
import '../../player/player_session.dart';
import '../../../widgets/app_cached_image.dart';
import '../../../widgets/app_skeletons.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late Future<List<DownloadedSong>> _downloadsFuture;

  @override
  void initState() {
    super.initState();
    _downloadsFuture = SongDownloadService.listDownloadedSongs();
  }

  Widget _summaryCard(List<DownloadedSong> downloads) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              _statItem('Tracks', downloads.length.toString()),
              _divider(),
              _statItem('Offline', downloads.isEmpty ? 'No' : 'Yes'),
              _divider(),
              _statItem('Status', downloads.isEmpty ? 'Empty' : 'Ready'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }

  Widget _songCard(DownloadedSong song, List<DownloadedSong> allDownloads) {
    return GestureDetector(
      onTap: () => _playDownloadedSong(song, allDownloads),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.17)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(aspectRatio: 1, child: _coverImage(song)),
                ),
                const SizedBox(height: 10),
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: _metaPill(
                        Icons.sd_storage_rounded,
                        song.sizeLabel,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _metaPill(Icons.music_note_rounded, 'Offline'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.82)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverImage(DownloadedSong song) {
    final localCoverPath = (song.localCoverPath ?? '').trim();
    if (localCoverPath.isNotEmpty &&
        !localCoverPath.startsWith('assets/') &&
        File(localCoverPath).existsSync()) {
      return Image.file(
        File(localCoverPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCover(),
      );
    }

    if (localCoverPath.startsWith('assets/')) {
      return Image.asset(
        localCoverPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCover(),
      );
    }

    final cover = (song.coverUrl ?? '').trim();
    if (cover.startsWith('http://') || cover.startsWith('https://')) {
      return AppCachedImage(url: cover, fit: BoxFit.cover);
    }
    if (cover.isNotEmpty) {
      return Image.asset(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCover(),
      );
    }
    return _fallbackCover();
  }

  Widget _fallbackCover() {
    return Container(
      color: Colors.white.withValues(alpha: 0.16),
      child: const Icon(
        Icons.download_done_rounded,
        color: Colors.white,
        size: 34,
      ),
    );
  }

  Song _toPlayableSong(DownloadedSong song) {
    return Song(
      id: 'download_${song.filePath.hashCode}',
      title: song.title,
      artist: song.artist,
      album: 'Downloaded',
      audioUrl: song.filePath,
      imageUrl: (song.localCoverPath ?? '').trim().isNotEmpty
          ? song.localCoverPath
          : song.coverUrl,
    );
  }

  void _playDownloadedSong(
    DownloadedSong song,
    List<DownloadedSong> allDownloads,
  ) {
    final queue = allDownloads.map(_toPlayableSong).toList(growable: false);
    final current = _toPlayableSong(song);
    final session = PlayerSession.instance;
    session.setQueue(queue, currentSong: current);
    session.playSong(current);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: current)),
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
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<List<DownloadedSong>>(
            future: _downloadsFuture,
            builder: (context, snapshot) {
              final downloads = snapshot.data ?? const <DownloadedSong>[];
              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 172,
                    backgroundColor: Colors.black.withValues(alpha: 0.16),
                    elevation: 0,
                    title: const Text(
                      'Downloads',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 86, 16, 10),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _summaryCard(downloads),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Downloaded Songs',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: const [
                            AppSkeletonBox(height: 74, radius: 14),
                            SizedBox(height: 10),
                            AppSkeletonBox(height: 74, radius: 14),
                            SizedBox(height: 10),
                            AppSkeletonBox(height: 74, radius: 14),
                          ],
                        ),
                      ),
                    )
                  else if (snapshot.hasError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Failed to load downloads.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else if (downloads.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No songs downloaded yet.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 0.56,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _songCard(downloads[index], downloads),
                          childCount: downloads.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
