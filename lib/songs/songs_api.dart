import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rizzmusicapp/songs/songs.dart';


const String baseUrl = "http://10.0.2.2:8080";

class SongApi {

  static Future<List<Song>> fetchSongs() async {
    final response = await http.get(Uri.parse("$baseUrl/songs"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['content']; // pagination content

      return list.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load songs");
    }
  }

  static Future<List<Song>> searchSongs(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/songs/search?query=$query"),
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

}
