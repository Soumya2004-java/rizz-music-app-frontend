import 'dart:ui';

import 'package:flutter/material.dart';

import '../../background/gradient_mesh_background.dart';
import '../songs.dart';
import '../songs_api.dart';

class SongListPage extends StatelessWidget {
  const SongListPage({super.key});

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
                  return const Center(child: CircularProgressIndicator());
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
