import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rizzmusicapp/songs/songs.dart';
import 'package:rizzmusicapp/services/api_config.dart';

class SongApi {
  static const String _songsCatalogUrl = String.fromEnvironment(
    'SONGS_CATALOG_URL',
    defaultValue: '',
  );

  static Future<List<Song>> fetchSongs() async {
    if (_songsCatalogUrl.isNotEmpty) {
      return _fetchFromCatalog();
    }

    final response = await http.get(ApiConfig.uri('/songs'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['content']; // pagination content

      return list.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load songs");
    }
  }

  static Future<List<Song>> searchSongs(String query) async {
    if (_songsCatalogUrl.isNotEmpty) {
      final songs = await _fetchFromCatalog();
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return songs;
      return songs.where((song) {
        return song.title.toLowerCase().contains(q) ||
            song.artist.toLowerCase().contains(q) ||
            song.album.toLowerCase().contains(q);
      }).toList();
    }

    final response = await http.get(
      ApiConfig.uri('/songs/search', queryParameters: {'query': query}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // 👇 PAGINATION CONTENT
      final List list = decoded['content'];

      return list.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load songs");
    }
  }

  static Future<List<Song>> _fetchFromCatalog() async {
    final response = await http.get(Uri.parse(_songsCatalogUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load cloud songs catalog');
    }

    final decoded = jsonDecode(response.body);
    final rawList = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> ? decoded['content'] : null);

    if (rawList is! List) {
      throw Exception('Invalid songs catalog format');
    }


    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Song.fromJson)
        .toList();
  }
}
