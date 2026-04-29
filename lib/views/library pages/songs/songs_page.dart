import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';
import '../../../music/music_repository.dart';
import '../../../songs/songs.dart';
import '../../../widgets/app_loading_animation.dart';
import '../../player/player_scrreen.dart';
import '../../player/player_session.dart';

class SongsPage extends StatelessWidget {
  const SongsPage({super.key, this.title = 'All Songs', this.songsOverride});

  final String title;
  final List<Song>? songsOverride;

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
          FutureBuilder<List<Song>>(
            future: songsOverride != null
                ? Future.value(songsOverride!)
                : MusicRepository.fetchSongs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AppLoadingAnimation());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Failed to load songs: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              final songs = snapshot.data ?? const <Song>[];

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.black.withValues(alpha: 0.16),
                    title: Text(title),
                  ),
                  if (songs.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No songs found in Firestore',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      sliver: SliverList.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _songTile(context, song, songs),
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

  Widget _songTile(BuildContext context, Song song, List<Song> queue) {
    final image = song.imageUrl?.trim() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: ListTile(
            onTap: () {
              final session = PlayerSession.instance;
              session.setQueue(queue, currentSong: song);
              session.playSong(song);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 46,
                height: 46,
                child: image.startsWith('http')
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackCover(),
                      )
                    : _fallbackCover(),
              ),
            ),
            title: Text(
              song.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${song.artist} • ${song.album}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      child: const Icon(Icons.music_note_rounded, color: Colors.white),
    );
  }
}
