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
      width: 268,
      height: 268,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff7ec6ff), Color(0xffa88cff), Color(0xffff9dc6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66323a64),
            blurRadius: 34,
            spreadRadius: 4,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
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
                      Colors.white.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.68),
                    ],
                    stops: const [0.0, 0.46, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: _heroChip(icon: Icons.album_rounded, label: 'Album'),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: _heroChip(
                icon: Icons.music_note_rounded,
                label: _songCountText(songs.length),
              ),
            ),
            if (!hasCover)
              const Center(
                child: Icon(Icons.album_rounded, size: 76, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 21),
                    const SizedBox(width: 9),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
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

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.70),
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _albumHeaderCard({
    required String albumLabel,
    required String artistLabel,
    required int songCount,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                albumLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                artistLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _heroChip(
                    icon: Icons.music_note_rounded,
                    label: _songCountText(songCount),
                  ),
                  _heroChip(
                    icon: Icons.fiber_manual_record_rounded,
                    label: 'Modern UI',
                  ),
                ],
              ),
            ],
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
          content: Text(message, style: const TextStyle(color: Colors.white)),
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

  void _addToQueue(BuildContext context, Song song, {required bool playNext}) {
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
      playNext
          ? 'Will play next: ${song.title}'
          : 'Added to queue: ${song.title}',
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pop(context, action),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 21),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _playSongNow(context, song, songs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
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
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 14),
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
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 12.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                        onPressed: () =>
                            _openSongOptionsSheet(context, song, songs),
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white.withValues(alpha: 0.82),
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
          expandedHeight: 460,
          elevation: 0,
          backgroundColor: Colors.black.withValues(alpha: 0.24),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.42),
                          Colors.black.withValues(alpha: 0.82),
                        ],
                        stops: const [0.0, 0.55, 1.0],
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
                  alignment: const Alignment(0, 0.52),
                  child: _heroCover(songs),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 26,
                  child: _albumHeaderCard(
                    albumLabel: albumLabel,
                    artistLabel: artistLabel,
                    songCount: songs.length,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Controls'),
                const SizedBox(height: 12),
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
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _downloadAllSongs(context, songs),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
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
                                  fontWeight: FontWeight.w700,
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
                Row(
                  children: [
                    _sectionLabel('Tracks'),
                    const Spacer(),
                    Text(
                      _songCountText(songs.length),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
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
