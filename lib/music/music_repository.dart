import 'package:cloud_firestore/cloud_firestore.dart';

import '../songs/songs.dart';
import '../songs/songs_api.dart';

class ArtistSummary {
  final String name;
  final String imageUrl;
  final int songCount;

  const ArtistSummary({
    required this.name,
    required this.imageUrl,
    required this.songCount,
  });
}

class AlbumSummary {
  final String title;
  final String artist;
  final String imageUrl;
  final int trackCount;

  const AlbumSummary({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.trackCount,
  });
}

class PlaylistSummary {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> songIds;

  const PlaylistSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.songIds,
  });

  factory PlaylistSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawSongIds = data['songIds'];
    return PlaylistSummary(
      id: doc.id,
      name: _asText(data['name']) ?? 'Untitled Playlist',
      imageUrl: _asText(data['imageUrl']) ?? '',
      description: _asText(data['description']) ?? '',
      songIds: rawSongIds is List
          ? rawSongIds
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : const <String>[],
    );
  }
}

class LibraryStats {
  final int songs;
  final int albums;
  final int artists;
  final int playlists;

  const LibraryStats({
    required this.songs,
    required this.albums,
    required this.artists,
    required this.playlists,
  });
}

class MusicRepository {
  MusicRepository._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<Song>> fetchSongs() => SongApi.fetchSongs();

  static Future<List<Song>> searchSongs(String query) =>
      SongApi.searchSongs(query);

  static Future<List<ArtistSummary>> fetchArtists() async {
    final songs = await fetchSongs();
    final map = <String, _ArtistAccumulator>{};

    for (final song in songs) {
      final artist = song.artist.trim();
      if (artist.isEmpty) continue;
      map.putIfAbsent(artist, _ArtistAccumulator.new).addSong(song);
    }

    final artists =
        map.entries
            .map(
              (entry) => ArtistSummary(
                name: entry.key,
                imageUrl: entry.value.imageUrl,
                songCount: entry.value.songCount,
              ),
            )
            .toList()
          ..sort((a, b) => b.songCount.compareTo(a.songCount));

    return artists;
  }

  static Future<List<AlbumSummary>> fetchAlbums() async {
    final songs = await fetchSongs();
    final map = <String, _AlbumAccumulator>{};

    for (final song in songs) {
      final album = song.album.trim().isEmpty
          ? 'Unknown Album'
          : song.album.trim();
      final artist = song.artist.trim().isEmpty
          ? 'Unknown Artist'
          : song.artist.trim();
      final key = '$artist|$album';
      map
          .putIfAbsent(
            key,
            () => _AlbumAccumulator(album: album, artist: artist),
          )
          .addSong(song);
    }

    final albums =
        map.values
            .map(
              (album) => AlbumSummary(
                title: album.album,
                artist: album.artist,
                imageUrl: album.imageUrl,
                trackCount: album.trackCount,
              ),
            )
            .toList()
          ..sort((a, b) => b.trackCount.compareTo(a.trackCount));

    return albums;
  }

  static Future<List<PlaylistSummary>> fetchPlaylists() async {
    try {
      final snapshot = await _db.collectionGroup('playlists').get();
      final playlists =
          snapshot.docs.map(PlaylistSummary.fromFirestore).toList()..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
      return playlists;
    } catch (_) {
      return const <PlaylistSummary>[];
    }
  }

  static Future<List<Song>> fetchSongsForPlaylist(
    PlaylistSummary playlist,
  ) async {
    if (playlist.songIds.isEmpty) return const <Song>[];

    final songs = await fetchSongs();
    final byId = {for (final song in songs) song.id: song};
    final result = <Song>[];

    for (final id in playlist.songIds) {
      final song = byId[id];
      if (song != null) result.add(song);
    }

    return result;
  }

  static Future<LibraryStats> fetchLibraryStats() async {
    final songs = await fetchSongs();
    final albums = <String>{};
    final artists = <String>{};

    for (final song in songs) {
      final album = song.album.trim().toLowerCase();
      final artist = song.artist.trim().toLowerCase();
      if (album.isNotEmpty) albums.add(album);
      if (artist.isNotEmpty) artists.add(artist);
    }

    final playlists = await fetchPlaylists();

    return LibraryStats(
      songs: songs.length,
      albums: albums.length,
      artists: artists.length,
      playlists: playlists.length,
    );
  }
}

class _ArtistAccumulator {
  int songCount = 0;
  String imageUrl = '';

  void addSong(Song song) {
    songCount += 1;
    if (imageUrl.isEmpty) {
      imageUrl = song.imageUrl?.trim() ?? '';
    }
  }
}

class _AlbumAccumulator {
  final String album;
  final String artist;
  int trackCount = 0;
  String imageUrl = '';

  _AlbumAccumulator({required this.album, required this.artist});

  void addSong(Song song) {
    trackCount += 1;
    if (imageUrl.isEmpty) {
      imageUrl = song.imageUrl?.trim() ?? '';
    }
  }
}

String? _asText(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
