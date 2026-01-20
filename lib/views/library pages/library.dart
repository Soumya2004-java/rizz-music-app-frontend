import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rizzmusicapp/songs/albums/album_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Artsts/artists_page.dart';
import 'package:rizzmusicapp/views/library%20pages/Playlists/playlist_page.dart';
import 'package:rizzmusicapp/views/library%20pages/songs/songs_page.dart';
import '../../background/gradient_mesh_background.dart';
import '../../widgets/library_items.dart';
import 'download/download_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          const GradientMeshBackground(),

          // ✨ Soft blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),


                  Text(
                    "Library",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),

                  const SizedBox(height: 30),

                  LibraryItem(
                    icon: Icons.queue_music,
                    title: "Playlists",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlaylistPage(playlistName: '', songs: [],))
                      );
                    },
                  ),
                  LibraryItem(
                    icon: Icons.person,
                    title: "Artists",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ArtistPage(artistName: '', imageUrl: '', listeners: '', popularSongs: [],))
                      );
                    },
                  ),
                  LibraryItem(
                    icon: Icons.album,
                    title: "Albums",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AlbumPage(artist: '',))
                      );
                    },
                  ),
                  LibraryItem(
                    icon: Icons.music_note,
                    title: "Songs",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SongsPage(albumName: '', artistName: '', year: '', coverUrl: '', tracks: [],))
                      );
                    },
                  ),
                  LibraryItem(
                    icon: Icons.download,
                    title: "Downloads",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DownloadPage()),
                      );
                    },
                  ),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
