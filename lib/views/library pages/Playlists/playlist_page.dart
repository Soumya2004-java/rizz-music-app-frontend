import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';
import '../../../music/music_repository.dart';
import '../../../songs/songs.dart';
import '../../../widgets/app_loading_animation.dart';
import '../../player/player_scrreen.dart';
import '../../player/player_session.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  final String playlistName;
  final List<Map<String, String>> songs;

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
          FutureBuilder<List<PlaylistSummary>>(
            future: MusicRepository.fetchPlaylists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AppLoadingAnimation());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Failed to load playlists: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              var playlists = snapshot.data ?? const <PlaylistSummary>[];
              final selectedName = playlistName.trim().toLowerCase();
              if (selectedName.isNotEmpty) {
                playlists = playlists
                    .where((p) => p.name.toLowerCase() == selectedName)
                    .toList();
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.black.withValues(alpha: 0.16),
                    title: Text(
                      playlistName.trim().isEmpty
                          ? 'Playlists'
                          : playlistName.trim(),
                    ),
                  ),
                  if (playlists.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'No playlists found. Create Firestore collection: playlists with fields: name, imageUrl, description, songIds.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      sliver: SliverList.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _playlistTile(context, playlist),
                          );
                        },
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

  Widget _playlistTile(BuildContext context, PlaylistSummary playlist) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ListTile(
          tileColor: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          ),
          onTap: () async {
            final songs = await MusicRepository.fetchSongsForPlaylist(playlist);
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    _PlaylistSongsScreen(playlist: playlist, songs: songs),
              ),
            );
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: playlist.imageUrl.startsWith('http')
                  ? Image.network(
                      playlist.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackCover(),
                    )
                  : _fallbackCover(),
            ),
          ),
          title: Text(
            playlist.name,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            playlist.description.isEmpty
                ? '${playlist.songIds.length} songs'
                : playlist.description,
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      child: const Icon(Icons.queue_music_rounded, color: Colors.white),
    );
  }
}

class _PlaylistSongsScreen extends StatelessWidget {
  const _PlaylistSongsScreen({required this.playlist, required this.songs});

  final PlaylistSummary playlist;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(playlist.name), backgroundColor: Colors.black),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                'This playlist has no valid song IDs.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  onTap: () {
                    final session = PlayerSession.instance;
                    session.setQueue(songs, currentSong: song);
                    session.playSong(song);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(song: song),
                      ),
                    );
                  },
                  title: Text(
                    song.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${song.artist} • ${song.album}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                );
              },
            ),
    );
  }
}
