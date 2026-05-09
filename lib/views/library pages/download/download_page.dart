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
  final Set<String> _savingSongPaths = <String>{};

  @override
  void initState() {
    super.initState();
    _downloadsFuture = SongDownloadService.listDownloadedSongs();
  }

  void _reloadDownloads() {
    setState(() {
      _downloadsFuture = SongDownloadService.listDownloadedSongs();
    });
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
                  Colors.white.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.26),
                  const Color(0xFFE8F1FA).withValues(alpha: 0.20),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.50),
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

  Future<void> _deleteDownloadedSong(DownloadedSong song) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _buildGlassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete download?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Remove "${song.title}" from this device?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF10151D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Color(0xFF10151D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (shouldDelete != true) return;

    try {
      await SongDownloadService.deleteDownloadedSong(song);
      if (!mounted) return;
      _reloadDownloads();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('"${song.title}" deleted from downloads.')),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to delete download: $error')),
        );
    }
  }

  Future<void> _saveSongToDevice(DownloadedSong song) async {
    final key = song.filePath;
    if (_savingSongPaths.contains(key)) return;

    setState(() => _savingSongPaths.add(key));
    try {
      final savedFile = await SongDownloadService.saveDownloadedSongToDevice(
        song,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Saved to device: ${savedFile.uri.pathSegments.last}',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to save to device: $error')),
        );
    } finally {
      if (mounted) {
        setState(() => _savingSongPaths.remove(key));
      }
    }
  }

  Widget _songCard(DownloadedSong song, List<DownloadedSong> allDownloads) {
    return GestureDetector(
      onTap: () => _playDownloadedSong(song, allDownloads),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 7),
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
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _deleteDownloadedSong(song),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.delete_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                _metaPill(Icons.music_note_rounded, 'Offline'),
                const SizedBox(height: 6),
                _saveToDeviceButton(song),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _saveToDeviceButton(DownloadedSong song) {
    final isSaving = _savingSongPaths.contains(song.filePath);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: isSaving ? null : () => _saveSongToDevice(song),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaving)
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.save_alt_rounded,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                const SizedBox(width: 6),
                Text(
                  isSaving ? 'Saving...' : 'Save to device',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
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
                              childAspectRatio: 0.60,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _songCard(downloads[index], downloads),
                          childCount: downloads.length,
                        ),
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
}
