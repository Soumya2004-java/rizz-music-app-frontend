import 'package:flutter/material.dart';


import '../../views/player/player_scrreen.dart';
import '../songs.dart';
import '../songs_api.dart';

class AlbumPage extends StatelessWidget {
  final String artist;

  const AlbumPage({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artist),
      ),
      body: FutureBuilder<List<Song>>(
        future: SongApi.searchSongs(artist),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            print(snapshot.data);
          }


          final songs = snapshot.data!;

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(song.title),
                subtitle: Text(song.artist),
                trailing: Text(song.album),

                // 🎵 PLAYER SCREEN OPEN HERE
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(song: song),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
