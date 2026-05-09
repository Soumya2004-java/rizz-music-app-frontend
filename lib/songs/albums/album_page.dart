import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/song_download_service.dart';
import '../../background/gradient_mesh_background.dart';
import '../../views/player/player_scrreen.dart';
import '../../views/player/player_session.dart';
import '../../widgets/app_skeletons.dart';
import '../songs.dart';
import '../songs_api.dart';

class AlbumPage extends StatelessWidget {
  final String artist;
  final String? albumTitle;
  final String? albumCover;

  const AlbumPage({
    super.key,
    required this.artist,
    this.albumTitle,
    this.albumCover,
  });

  Future<List<Song>> _loadSongs() async {
    final selectedAlbum = albumTitle?.trim() ?? '';
    if (selectedAlbum.isNotEmpty) {
      return SongApi.fetchSongsByAlbum(selectedAlbum);
    }

    final q = artist.trim();
    final songs = q.isEmpty
        ? await SongApi.fetchSongs()
        : await SongApi.fetchSongsByArtist(q);
    return songs;
  }

  String _artistName(List<Song> songs) {
    final q = artist.trim();
    if (q.isNotEmpty) return q;
    if (songs.isNotEmpty && songs.first.artist.trim().isNotEmpty) {
      return songs.first.artist;
    }
    return 'Various Artists';
  }

  String _albumName(List<Song> songs) {
    final selectedAlbum = albumTitle?.trim() ?? '';
    if (selectedAlbum.isNotEmpty) return selectedAlbum;
    if (songs.isNotEmpty && songs.first.album.trim().isNotEmpty) {
      return songs.first.album;
    }
    return 'Album Collection';
  }

  String _songCountText(int count) => count == 1 ? '1 Song' : '$count Songs';

  Widget _heroCover(List<Song> songs) {
    final selectedCover = albumCover?.trim() ?? '';
    final songCover = songs.isNotEmpty
        ? (songs.first.imageUrl?.trim() ?? '')
        : '';
    final cover = selectedCover.isNotEmpty ? selectedCover : songCover;
    final hasAssetCover = cover.startsWith('assets/');
    final hasNetworkCover =
        cover.startsWith('http://') || cover.startsWith('https://');
    final hasCover = hasAssetCover || hasNetworkCover;

    return Container(
      width: 214,
      height: 214,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff7ec6ff), Color(0xffa88cff), Color(0xffff9dc6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66323a64),
            blurRadius: 28,
            spreadRadius: 2,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (hasCover)
              Positioned.fill(
                child: hasAssetCover
                    ? Image.asset(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      )
                    : Image.network(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.34),
                    ],
                  ),
                ),
              ),
            ),
            if (!hasCover)
              const Center(
                child: Icon(Icons.album_rounded, size: 64, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _playAlbum(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) return;
    final session = PlayerSession.instance;
    final firstSong = songs.first;
    session.setQueue(songs, currentSong: firstSong);
    if (session.isShuffleEnabled) {
      session.toggleShuffle();
    }
    session.playSong(firstSong);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: firstSong)),
    );
  }

  void _shuffleAlbum(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) return;
    final session = PlayerSession.instance;
    final randomSong = songs[math.Random().nextInt(songs.length)];
    session.setQueue(songs, currentSong: randomSong);
    if (!session.isShuffleEnabled) {
      session.toggleShuffle();
    }
    session.playSong(randomSong);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: randomSong)),
    );
  }

  void _showAnnouncement(BuildContext context, String message) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 110),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _downloadSong(BuildContext context, Song song) async {
    final audioUrl = (song.audioUrl ?? '').trim();
    if (audioUrl.isEmpty) {
      if (!context.mounted) return;
      _showAnnouncement(context, 'No downloadable audio for "${song.title}"');
      return;
    }

    try {
      final result = await SongDownloadService.downloadSong(song);
      if (!context.mounted) return;
      final message = result.alreadyExists
          ? 'Already downloaded: ${song.title}'
          : 'Downloaded: ${song.title}';
      _showAnnouncement(context, message);
    } catch (error) {
      if (!context.mounted) return;
      _showAnnouncement(context, 'Failed to download "${song.title}": $error');
    }
  }

  Future<void> _downloadAllSongs(BuildContext context, List<Song> songs) async {
    if (songs.isEmpty) return;
    if (!context.mounted) return;
    _showAnnouncement(context, 'Downloading ${songs.length} songs...');

    int downloaded = 0;
    int alreadyExists = 0;
    int failed = 0;

    for (final song in songs) {
      final audioUrl = (song.audioUrl ?? '').trim();
      if (audioUrl.isEmpty) {
        failed++;
        continue;
      }
      try {
        final result = await SongDownloadService.downloadSong(song);
        if (result.alreadyExists) {
          alreadyExists++;
        } else {
          downloaded++;
        }
      } catch (_) {
        failed++;
      }
    }

    if (!context.mounted) return;
    _showAnnouncement(
      context,
      'Download all done. New: $downloaded, Existing: $alreadyExists, Failed: $failed',
    );
  }

  void _addToQueue(
    BuildContext context,
    Song song, {
    required bool playNext,
  }) {
    final session = PlayerSession.instance;
    final queue = session.queue.toList();
    final currentSong = session.currentSong;
    final songKey = _songKey(song);
    queue.removeWhere((item) => _songKey(item) == songKey);

    if (queue.isEmpty) {
      queue.add(song);
      session.setQueue(queue, currentSong: song);
      session.playSong(song);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
      );
      return;
    }

    if (playNext && currentSong != null) {
      final currentKey = _songKey(currentSong);
      final index = queue.indexWhere((item) => _songKey(item) == currentKey);
      if (index >= 0) {
        queue.insert(index + 1, song);
      } else {
        queue.add(song);
      }
    } else {
      queue.add(song);
    }

    session.setQueue(queue, currentSong: currentSong ?? queue.first);
    _showAnnouncement(
      context,
      playNext ? 'Will play next: ${song.title}' : 'Added to queue: ${song.title}',
    );
  }

  String _songKey(Song song) {
    final id = song.id.trim();
    if (id.isNotEmpty) return 'id:$id';
    final audio = (song.audioUrl ?? '').trim();
    if (audio.isNotEmpty) return 'audio:$audio';
    return 'meta:${song.title.trim()}|${song.artist.trim()}|${song.album.trim()}';
  }

  void _playSongNow(BuildContext context, Song song, List<Song> songs) {
    final session = PlayerSession.instance;
    session.setQueue(songs, currentSong: song);
    session.playSong(song);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
    );
  }

  Future<void> _onSongMenuSelected(
    BuildContext context,
    Song song,
    List<Song> songs,
    _SongMenuAction action,
  ) async {
    switch (action) {
      case _SongMenuAction.playNow:
        _playSongNow(context, song, songs);
        return;
      case _SongMenuAction.playNext:
        _addToQueue(context, song, playNext: true);
        return;
      case _SongMenuAction.addToQueue:
        _addToQueue(context, song, playNext: false);
        return;
      case _SongMenuAction.download:
        await _downloadSong(context, song);
        return;
    }
  }

  Future<void> _openSongOptionsSheet(
    BuildContext context,
    Song song,
    List<Song> songs,
  ) async {
    final action = await showModalBottomSheet<_SongMenuAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sheetActionTile(
                          context: sheetContext,
                          icon: Icons.play_arrow_rounded,
                          label: 'Play now',
                          action: _SongMenuAction.playNow,
                        ),
                        _sheetActionTile(
                          context: sheetContext,
                          icon: Icons.queue_play_next_rounded,
                          label: 'Play next',
                          action: _SongMenuAction.playNext,
                        ),
                        _sheetActionTile(
                          context: sheetContext,
                          icon: Icons.queue_music_rounded,
                          label: 'Add to queue',
                          action: _SongMenuAction.addToQueue,
                        ),
                        _sheetActionTile(
                          context: sheetContext,
                          icon: Icons.download_rounded,
                          label: 'Download',
                          action: _SongMenuAction.download,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (action == null || !context.mounted) return;
    await _onSongMenuSelected(context, song, songs, action);
  }

  Widget _sheetActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required _SongMenuAction action,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pop(context, action),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _songTile(
    BuildContext context,
    Song song,
    int index,
    List<Song> songs,
  ) {
    final imageUrl = song.imageUrl?.trim() ?? '';
    final hasImage = imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _playSongNow(context, song, songs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: hasImage
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        gradient: hasImage
                            ? null
                            : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xff7ec6ff), Color(0xffa88cff)],
                              ),
                      ),
                      child: hasImage
                          ? null
                          : const Icon(
                              Icons.music_note_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 18,
                        onPressed: () => _openSongOptionsSheet(
                          context,
                          song,
                          songs,
                        ),
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white.withValues(alpha: 0.78),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<List<Song>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const ListPageSkeleton();
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            snapshot.error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final songs = snapshot.data ?? <Song>[];
    final artistLabel = _artistName(songs);
    final albumLabel = _albumName(songs);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 390,
          elevation: 0,
          backgroundColor: Colors.black.withValues(alpha: 0.18),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(
              start: 18,
              bottom: 12,
            ),
            title: Text(
              albumLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            background: Stack(
              children: [
                const GradientMeshBackground(),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.52),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: const SizedBox.expand(),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.72),
                  child: _heroCover(songs),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artistLabel,
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.2,
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _songCountText(songs.length),
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _actionButton(
                      Icons.play_arrow_rounded,
                      'Play',
                      () => _playAlbum(context, songs),
                    ),
                    const SizedBox(width: 12),
                    _actionButton(
                      Icons.shuffle_rounded,
                      'Shuffle',
                      () => _shuffleAlbum(context, songs),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _downloadAllSongs(context, songs),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Download all',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Tracks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (songs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: const Text(
                      'No songs found for this album.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _songTile(context, songs[index], index, songs),
              childCount: songs.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
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
                    Colors.black.withValues(alpha: 0.46),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<List<Song>>(
            future: _loadSongs(),
            builder: _buildContent,
          ),
        ],
      ),
    );
  }
}

enum _SongMenuAction { playNow, playNext, addToQueue, download }
