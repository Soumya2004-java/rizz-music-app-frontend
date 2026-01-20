import 'dart:ui';
import 'package:flutter/material.dart';

class ArtistPage extends StatelessWidget {
  final String artistName;
  final String imageUrl;
  final String listeners;
  final List<Map<String, String>> popularSongs;

  const ArtistPage({
    super.key,
    required this.artistName,
    required this.imageUrl,
    required this.listeners,
    required this.popularSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [

          // Artist Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 330,
            backgroundColor: Colors.black.withOpacity(0.2),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                artistName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff0f0f0f),
                          Color(0xff181818),
                          Color(0xff000000),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Artist image
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artist Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 10),
                  Text(
                    listeners,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Play + Shuffle Buttons (Glass)
                  Row(
                    children: [
                      glassButton(
                        Icons.play_arrow,
                        Colors.white,
                      ),
                      const SizedBox(width: 12),
                      glassButton(
                        Icons.shuffle,
                        Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Text(
                    "Popular Songs",
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

          // Popular Songs List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final song = popularSongs[index];

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          song["thumb"]!,
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        song["title"]!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        song["playCount"] ?? "",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      trailing:
                      Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.8)),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ],
                );
              },
              childCount: popularSongs.length,
            ),
          ),
        ],
      ),
    );
  }

  // Glass Button Widget
  Widget glassButton(IconData icon, Color color) {
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
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}
