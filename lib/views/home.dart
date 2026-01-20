import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rizzmusicapp/background/gradient_mesh_background.dart';
import 'package:rizzmusicapp/views/album_views/kishor_kumar.dart';
import '../widgets/floating_pill_glass_card.dart';
import '../widgets/glow_album_card.dart';
import 'album_views/Asha_bhosle.dart';
import 'album_views/alka_yagnik.dart';
import 'album_views/arijit_singh.dart';
import 'album_views/jubin_nautiyal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 🔥 GRADIENT MESH BACKGROUND
          const GradientMeshBackground(),

          // Optional soft blur layer (premium feel)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),

          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white60.withOpacity(0.15),
                  Colors.white.withOpacity(0.18),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Mostly Played",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        GlowAlbumCard(
                          image:
                          'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                          title: 'Calm Waves',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ArijitSingh(),
                              ),
                            );
                          },
                        ),

                        GlowAlbumCard(
                          image:
                          'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                          title: 'Calm Waves',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AshaBhosle(),
                              ),
                            );
                          },
                        ),
                        GlowAlbumCard(
                          image:
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                          title: 'Calm Waves',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const KishorKumar(),
                              ),
                            );
                          },
                        ),
                        GlowAlbumCard(
                          image:
                              'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
                          title: 'Calm Waves',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const JubinNautiyal(),
                              ),
                            );
                          },
                        ),
                        GlowAlbumCard(
                          image:
                              'assets/albums/Best-Of-Alka-Yagnik-Hindi-2020-20200506121339-500x500.jpg',
                          title: 'Calm Waves',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AlkaYagnik(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Good Vibes",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
                          title: 'Jubin Best',
                        ),
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/Best-Of-Alka-Yagnik-Hindi-2020-20200506121339-500x500.jpg',
                          title: 'Alka Classics',
                        ),
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/Celebrating-Shreya-Ghoshal-Hindi-2020-20200309113133-500x500.jpg',
                          title: 'Shreya Hits',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                          title: 'Best Mode',
                        ),
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                          title: 'Asha',
                        ),
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                          title: 'Kishore Hits',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/ab67616d00001e026f39da36b20a464bdc28fd21.jpeg',
                          title: 'Romantic Mix',
                        ),
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/51TCww-h17L._UF1000,1000_QL80_.jpg',
                          title: 'Retro Gold',
                        ),
                        FloatingPillGlassCard(
                          image:
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                          title: 'Mood Booster',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "90's Lovers",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: const [
                        GlowAlbumCard(
                          image:
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                          title: 'Best Mode',
                        ),
                        GlowAlbumCard(
                          image:
                              'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                          title: 'Trance Vibes',
                        ),
                        GlowAlbumCard(
                          image:
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                          title: 'Calm Waves',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "80's Lovers",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: const [
                        GlowAlbumCard(
                          image:
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                          title: 'Best Mode',
                        ),
                        GlowAlbumCard(
                          image:
                              'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
                          title: 'Trance Vibes',
                        ),
                        GlowAlbumCard(
                          image:
                              'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
                          title: 'Calm Waves',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
