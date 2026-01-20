import 'dart:ui';
import 'package:flutter/material.dart';

class SongsPage extends StatelessWidget {
  final String albumName;
  final String artistName;
  final String year;
  final String coverUrl;
  final List<Map<String, String>> tracks;

  const SongsPage({
    super.key,
    required this.albumName,
    required this.artistName,
    required this.year,
    required this.coverUrl,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [

          // HEADER
          SliverAppBar(
            pinned: true,
            expandedHeight: 330,
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0.25),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                albumName,
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
                          Color(0xff1a1a1a),
                          Color(0xff000000),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          coverUrl,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // INFO + ACTIONS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),
                  Text(
                    artistName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    year,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      glassCircularButton(Icons.play_arrow),
                      const SizedBox(width: 12),
                      glassCircularButton(Icons.shuffle),
                    ],
                  ),

                  const SizedBox(height: 26),
                  Text(
                    "Tracks",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // TRACK LIST
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                final track = tracks[i];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                      title: Text(
                        track["title"]!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        track["duration"] ?? "",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                      trailing: Icon(Icons.more_horiz,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ],
                );
              },
              childCount: tracks.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget glassCircularButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
