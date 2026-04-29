import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import 'songs.dart';

class SongApi {
  static const String _songsCatalogUrl = String.fromEnvironment(
    'SONGS_CATALOG_URL',
    defaultValue: '',
  );

  static Future<List<Song>> fetchSongs() async {
    if (_songsCatalogUrl.isNotEmpty) {
      return _fetchFromCatalog();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('songs')
          .get();
      final songs = await Future.wait(snapshot.docs.map(_songFromDoc));
      songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      return songs;
    } catch (e) {
      // Fallback to top-level songs collection.
      try {
        final fallback = await FirebaseFirestore.instance
            .collection('songs')
            .orderBy('title')
            .get();

        return Future.wait(fallback.docs.map(_songFromDoc));
      } catch (_) {
        return const <Song>[];
      }
    }
  }

  static Future<List<Song>> fetchSongsByAlbum(String albumTitle) async {
    final normalized = albumTitle.trim();
    if (normalized.isEmpty) return fetchSongs();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('songs')
          .where('album', isEqualTo: normalized)
          .get();

      final songs = await Future.wait(snapshot.docs.map(_songFromDoc));
      songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      return songs;
    } catch (_) {
      final allSongs = await fetchSongs();
      return allSongs
          .where((song) => song.album.toLowerCase() == normalized.toLowerCase())
          .toList();
    }
  }

  static Future<List<Song>> fetchSongsByArtist(String artistName) async {
    final normalized = artistName.trim();
    if (normalized.isEmpty) return fetchSongs();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('songs')
          .where('artist', isEqualTo: normalized)
          .get();

      final songs = await Future.wait(snapshot.docs.map(_songFromDoc));
      songs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );

      if (songs.isNotEmpty) return songs;

      final allSongs = await fetchSongs();
      return allSongs
          .where(
            (song) => song.artist.toLowerCase() == normalized.toLowerCase(),
          )
          .toList();
    } catch (_) {
      final allSongs = await fetchSongs();
      return allSongs
          .where(
            (song) => song.artist.toLowerCase() == normalized.toLowerCase(),
          )
          .toList();
    }
  }

  static Future<List<Song>> searchSongs(String query) async {
    final songs = await fetchSongs();
    final q = query.trim().toLowerCase();

    if (q.isEmpty) return songs;

    return songs.where((song) {
      return song.title.toLowerCase().contains(q) ||
          song.artist.toLowerCase().contains(q) ||
          song.album.toLowerCase().contains(q);
    }).toList();
  }

  static Future<List<Song>> _fetchFromCatalog() async {
    final response = await http.get(Uri.parse(_songsCatalogUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load songs catalog');
    }

    final decoded = jsonDecode(response.body);

    final rawList = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> ? decoded['content'] : null);

    if (rawList is! List) {
      throw Exception('Invalid catalog format');
    }

    return Future.wait(
      rawList.whereType<Map<String, dynamic>>().map((item) async {
        final data = Map<String, dynamic>.from(item);

        data['audioUrl'] = await _resolveStorageBackedUrl(
          data['audioUrl'],
          path: data['audioPath'],
        );

        data['imageUrl'] = await _resolveStorageBackedUrl(
          data['imageUrl'],
          path: data['imagePath'],
        );

        return Song.fromJson(data);
      }),
    );
  }

  static Future<String?> _resolveStorageBackedUrl(
    dynamic rawUrl, {
    dynamic path,
  }) async {
    final direct = _normalizedString(rawUrl);

    if (direct != null) {
      if (direct.startsWith('http')) return direct;

      if (direct.startsWith('gs://')) {
        try {
          return await FirebaseStorage.instance
              .refFromURL(direct)
              .getDownloadURL();
        } catch (_) {
          return direct;
        }
      }
    }

    final storagePath = _normalizedString(path);

    if (storagePath != null) {
      try {
        return await FirebaseStorage.instance.ref(storagePath).getDownloadURL();
      } catch (_) {
        return null;
      }
    }

    return direct;
  }

  static String? _normalizedString(dynamic value) {
    if (value == null) return null;
    final v = value.toString().trim();
    return v.isEmpty ? null : v;
  }

  static Future<Song> _songFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = data['id'] ?? doc.id;

    data['audioUrl'] = await _resolveStorageBackedUrl(
      data['audioUrl'],
      path: data['audioPath'],
    );

    data['imageUrl'] = await _resolveStorageBackedUrl(
      data['imageUrl'],
      path: data['imagePath'],
    );

    return Song.fromJson(data);
  }
}
