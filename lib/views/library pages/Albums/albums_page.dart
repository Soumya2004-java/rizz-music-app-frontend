import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';

class PlaylistPage extends StatelessWidget {
  final String playlistName;
  final List<Map<String, String>> songs;

  const PlaylistPage({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260,
                elevation: 0,
                backgroundColor: Colors.black.withValues(alpha: 0.2),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    playlistName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  background: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff0f0f0f),
                              Color(0xff1b1b1b),
                              Color(0xff000000),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "https://i.pinimg.com/564x/6a/ad/b4/6aadb4c3e7301c2c1c62b4edfa5cb60c.jpg",
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      Text(
                        "${songs.length} songs",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shuffle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = songs[index];
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            if (song["thumb"] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  song["thumb"]!,
                                  height: 48,
                                  width: 48,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(Icons.music_note, color: Colors.white),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song["title"]!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    song["artist"] ?? "",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              Icons.more_horiz,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ],
                  );
                }, childCount: songs.length),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
