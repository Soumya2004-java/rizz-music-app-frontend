import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rizzmusicapp/views/album_views/alka_yagnik.dart';

import '../background/gradient_mesh_background.dart';
import '../widgets/glow_album_card.dart';

import 'album_views/Asha_bhosle.dart';
import 'album_views/arijit_singh.dart';
import 'album_views/kishor_kumar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          const GradientMeshBackground(),

          // ✨ Soft blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),


          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // 🔍 Title
                    Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔍 Search Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          height: 52,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    hintText:
                                    "Artists, Songs, Albums",
                                    hintStyle: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.6),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 🎵 Section title
                    Text(
                      "Browse Categories",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),
                    
                    Padding(
                      padding: const EdgeInsets.only(left :10.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 5,
                          childAspectRatio:0.80,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          final albums = [
                            {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Best Mode',
                              'page': const ArijitSingh(),
                            },
                            {
                              'image':
                              'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                              'title': 'Trance Vibes',
                              'page': const AshaBhosle(),
                            },
                            {
                              'image':
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                              'title': 'Calm Waves',
                              'page': const KishorKumar(),
                            },
                            {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Night Beats',
                              'page': const AlkaYagnik(),
                            },
                            {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Best Mode',
                              'page': const ArijitSingh(),
                            },
                            {
                              'image':
                              'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                              'title': 'Trance Vibes',
                              'page': const AshaBhosle(),
                            },
                            {
                              'image':
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                              'title': 'Calm Waves',
                              'page': const KishorKumar(),
                            },
                            {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Night Beats',
                              'page': null,
                            },
                            {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Best Mode',
                              'page': const ArijitSingh(),
                            },
                            {
                              'image':
                              'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                              'title': 'Trance Vibes',
                              'page': const AshaBhosle(),
                            },
                            {
                              'image':
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                              'title': 'Calm Waves',
                              'page': const KishorKumar(),
                            },
                            {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Night Beats',
                              'page': null,
                            }, {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Best Mode',
                              'page': const ArijitSingh(),
                            },
                            {
                              'image':
                              'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                              'title': 'Trance Vibes',
                              'page': const AshaBhosle(),
                            },
                            {
                              'image':
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                              'title': 'Calm Waves',
                              'page': const KishorKumar(),
                            },
                            {
                              'image':
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                              'title': 'Night Beats',
                              'page': null,
                            },

                          ];

                          return GlowAlbumCard(
                            image: albums[index]['image'] as String,
                            title: albums[index]['title'] as String,
                            onTap: () {
                              final page = albums[index]['page'];
                              if (page != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => page as Widget,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 👇 Future vertical sections
                    Text(
                      "More For You",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
