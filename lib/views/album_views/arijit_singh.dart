import 'dart:ui';
import 'package:flutter/material.dart';

import '../../songs/data/arijit_songs.dart';

class ArijitSingh extends StatefulWidget {
  const ArijitSingh({super.key});

  @override
  State<ArijitSingh> createState() => _ArijitSinghState();
}

class _ArijitSinghState extends State<ArijitSingh> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          //  Background Album Image (Blurred)
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Global Blur Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [

                  const SizedBox(height: 40),

                  //  Album Art (Clean, Minimal)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                      width: size.width - 120,
                      height: size.width - 120,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 30),

                  //  Glass Info Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [

                              Text(
                                "Arijit Singh",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🎵 Song List Placeholder (Glass Blocks)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: arijitSongs.map((song) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: GestureDetector(
                            onTap: () {
                              // playSong(song.audioPath);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                child: Container(
                                  height: 65,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                 child:  Row(
                                    children: [

                                      //  Album Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Image.asset(
                                          'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      // 🎵 Song Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Album name
                                            Text(
                                              song.album,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),

                                            const SizedBox(height: 2),

                                            // Song title
                                            Text(
                                              song.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10,),

                                      // ▶️ Play icon
                                      const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ],
                                  ),

                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
