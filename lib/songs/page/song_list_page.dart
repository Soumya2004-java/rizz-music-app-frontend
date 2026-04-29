import 'dart:ui';

import 'package:flutter/material.dart';

import '../../background/gradient_mesh_background.dart';
import '../../views/player/player_scrreen.dart';
import '../../views/player/player_session.dart';
import '../../widgets/app_loading_animation.dart';
import '../songs.dart';
import '../songs_api.dart';

class SongListPage extends StatelessWidget {
  const SongListPage({super.key});

  ImageProvider<Object> _songArtwork(String? imageUrl) {
    final normalized = imageUrl?.trim() ?? '';
    if (normalized.isNotEmpty) return NetworkImage(normalized);
    return const AssetImage(
      'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          SafeArea(
            child: FutureBuilder<List<Song>>(
              future: SongApi.fetchSongs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AppLoadingAnimation());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final songs = snapshot.data!;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.black.withValues(alpha: 0.16),
                      title: const Text('Rizz Music'),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                      sliver: SliverList.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 14,
                                  sigmaY: 14,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () {
                                      final session = PlayerSession.instance;
                                      session.setQueue(
                                        songs,
                                        currentSong: song,
                                      );
                                      session.playSong(song);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PlayerScreen(song: song),
                                        ),
                                      );
                                    },
                                    leading: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: _songArtwork(song.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      song.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      song.artist,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                      ),
                                    ),
                                    trailing: Text(
                                      song.album,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
}
