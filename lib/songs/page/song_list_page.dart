import 'package:flutter/material.dart';

import '../songs.dart';
import '../songs_api.dart';


class SongListPage extends StatelessWidget {
  const SongListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎵 Rizz Music")),
      body: FutureBuilder<List<Song>>(
        future: SongApi.fetchSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final songs = snapshot.data!;

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist),
                trailing: Text(song.album),
              );
            },
          );
        },
      ),
    );
  }
}
