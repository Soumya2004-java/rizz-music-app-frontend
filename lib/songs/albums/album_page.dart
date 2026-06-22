import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/song_download_service.dart';
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

  String _coverSource(List<Song> songs) {
    final selectedCover = albumCover?.trim() ?? '';
    if (selectedCover.isNotEmpty) return selectedCover;
    if (songs.isNotEmpty) return songs.first.imageUrl?.trim() ?? '';
    return '';
  }

  bool _isAssetImage(String source) => source.startsWith('assets/');

  bool _isNetworkImage(String source) =>
      source.startsWith('http://') || source.startsWith('https://');

  Widget _coverImage(String source, {BoxFit fit = BoxFit.cover}) {
    final cover = source.trim();
    if (_isAssetImage(cover)) {
      return Image.asset(
        cover,
        fit: fit,
        errorBuilder: (_, __, ___) => _coverFallback(),
      );
    }

    if (_isNetworkImage(cover)) {
      return Image.network(
        cover,
        fit: fit,
        errorBuilder: (_, __, ___) => _coverFallback(),
      );
    }

    return _coverFallback();
  }

  Widget _coverFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14151D), Color(0xFF4D576C), Color(0xFFB07388)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.album_rounded, color: Colors.white70, size: 54),
    );
  }

  Widget _blurredCoverBackground(List<Song> songs) {
    final cover = _coverSource(songs);
    final hasCover = _isAssetImage(cover) || _isNetworkImage(cover);

    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF090A0F),
                  Color(0xFF1A1B24),
                  Color(0xFF11131B),
                ],
              ),
            ),
          ),
        ),
        if (hasCover)
          Positioned.fill(
            child: Transform.scale(
              scale: 1.16,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
                child: _coverImage(cover),
              ),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.34),
                  Colors.black.withValues(alpha: 0.54),
                  Colors.black.withValues(alpha: 0.86),
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.75, -0.62),
                radius: 1.25,
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroCover(List<Song> songs) {
    final cover = _coverSource(songs);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(child: _coverImage(cover)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.18),
                        Colors.black.withValues(alpha: 0.46),
                      ],
                      stops: const [0.0, 0.56, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: 14,
                child: _heroChip(icon: Icons.album_rounded, label: 'Album'),
              ),
              Positioned(
                right: 14,
                bottom: 14,
                child: _heroChip(
                  icon: Icons.music_note_rounded,
                  label: _songCountText(songs.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Ink(
            height: 52,
            decoration: BoxDecoration(
              color: label == 'Play'
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: label == 'Play'
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: label == 'Play' ? Colors.black : Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: label == 'Play' ? Colors.black : Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
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
        color: Colors.white.withValues(alpha: 0.62),
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _albumHeroText({
    required String albumLabel,
    required String artistLabel,
    required int songCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionLabel('Album'),
        const SizedBox(height: 10),
        Text(
          albumLabel,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            height: 0.98,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          artistLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _heroChip(
              icon: Icons.music_note_rounded,
              label: _songCountText(songCount),
            ),
            _heroChip(icon: Icons.library_music_rounded, label: 'Collection'),
          ],
        ),
      ],
    );
  }

  Widget _albumHero({
    required BuildContext context,
    required List<Song> songs,
    required String albumLabel,
    required String artistLabel,
  }) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 74, 22, 30),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 580;
            if (wide) {
              final coverSize = math.min(300.0, constraints.maxWidth * 0.36);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(width: coverSize, child: _heroCover(songs)),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _albumHeroText(
                        albumLabel: albumLabel,
                        artistLabel: artistLabel,
                        songCount: songs.length,
                      ),
                    ),
                  ),
                ],
              );
            }

            final coverSize = math.min(226.0, constraints.maxWidth * 0.62);
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(width: coverSize, child: _heroCover(songs)),
                ),
                const SizedBox(height: 22),
                _albumHeroText(
                  albumLabel: albumLabel,
                  artistLabel: artistLabel,
                  songCount: songs.length,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _roundActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Material(
        color: Colors.white.withValues(alpha: 0.13),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _glassIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.black.withValues(alpha: 0.28),
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: tooltip,
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _albumControlDock(BuildContext context, List<Song> songs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              _actionButton(
                Icons.play_arrow_rounded,
                'Play',
                () => _playAlbum(context, songs),
              ),
              const SizedBox(width: 10),
              _actionButton(
                Icons.shuffle_rounded,
                'Shuffle',
                () => _shuffleAlbum(context, songs),
              ),
              const SizedBox(width: 10),
              _roundActionButton(
                icon: Icons.download_rounded,
                tooltip: 'Download all',
                onTap: () => _downloadAllSongs(context, songs),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _playSongNow(context, song, songs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text(
                        '${index + 1}'.padLeft(2, '0'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.52),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: _coverImage(imageUrl),
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
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            song.artist.trim().isEmpty
                                ? 'Unknown artist'
                                : song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.58),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                        tooltip: 'Track options',
                        onPressed: () =>
                            _openSongOptionsSheet(context, song, songs),
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white.withValues(alpha: 0.72),
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
          stretch: true,
          expandedHeight: 540,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.black.withValues(alpha: 0.16),
          foregroundColor: Colors.white,
          leadingWidth: 64,
          titleSpacing: 0,
          title: Text(
            albumLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: _glassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: 'Back',
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 44,
                height: 44,
                child: _glassIconButton(
                  icon: Icons.download_rounded,
                  tooltip: 'Download all',
                  onTap: () => _downloadAllSongs(context, songs),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.04),
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.68),
                        ],
                        stops: const [0.0, 0.54, 1.0],
                      ),
                    ),
                  ),
                ),
                _albumHero(
                  context: context,
                  songs: songs,
                  albumLabel: albumLabel,
                  artistLabel: artistLabel,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _albumControlDock(context, songs),
                const SizedBox(height: 26),
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
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        if (songs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.26),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.music_off_rounded,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No songs found for this album.',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
      backgroundColor: const Color(0xFF08090D),
      body: FutureBuilder<List<Song>>(
        future: _loadSongs(),
        builder: (context, snapshot) {
          final songs = snapshot.data ?? const <Song>[];
          return Stack(
            children: [
              _blurredCoverBackground(songs),
              _buildContent(context, snapshot),
            ],
          );
        },
      ),
    );
  }
}

enum _SongMenuAction { playNow, playNext, addToQueue, download }
