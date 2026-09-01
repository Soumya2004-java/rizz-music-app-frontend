import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class YouTubePlaylistItem {
  const YouTubePlaylistItem({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
}

class YouTubePlaylistService {
  YouTubePlaylistService._();

  static const playlistId = 'PLP8yOli8L_-M';
  static const _apiKey = String.fromEnvironment('YOUTUBE_API_KEY');
  static const _iosBundleId = 'com.example.rizzmusicapp';

  static Future<List<YouTubePlaylistItem>> fetchAll(String playlistId) async {
    if (_apiKey.isEmpty) {
      throw StateError(
        'Start the app with YOUTUBE_API_KEY to load song names.',
      );
    }

    final items = <YouTubePlaylistItem>[];
    String? pageToken;

    do {
      final uri = Uri.https('www.googleapis.com', '/youtube/v3/playlistItems', {
        'part': 'snippet',
        'playlistId': playlistId,
        'maxResults': '50',
        'key': _apiKey,
        if (pageToken != null) 'pageToken': pageToken,
      });
      final response = await http.get(
        uri,
        headers: switch (defaultTargetPlatform) {
          TargetPlatform.iOS => const {'X-Ios-Bundle-Identifier': _iosBundleId},
          _ => const {},
        },
      );
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = (error['error'] as Map<String, dynamic>?)?['message']
            ?.toString();
        throw StateError(
          'YouTube could not load this playlist (${response.statusCode})'
          '${message == null ? '' : ': $message'}',
        );
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final rawItems = payload['items'] as List<dynamic>? ?? const [];
      for (final rawItem in rawItems) {
        final snippet =
            (rawItem as Map<String, dynamic>)['snippet']
                as Map<String, dynamic>?;
        if (snippet == null) continue;
        final resource = snippet['resourceId'] as Map<String, dynamic>?;
        final videoId = resource?['videoId']?.toString() ?? '';
        if (videoId.isEmpty) continue;
        final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
        final thumbnail =
            (thumbnails?['medium'] ?? thumbnails?['default'])
                as Map<String, dynamic>?;
        items.add(
          YouTubePlaylistItem(
            videoId: videoId,
            title: snippet['title']?.toString() ?? 'Untitled video',
            channelTitle:
                snippet['videoOwnerChannelTitle']?.toString() ??
                snippet['channelTitle']?.toString() ??
                'YouTube',
            thumbnailUrl: thumbnail?['url']?.toString() ?? '',
          ),
        );
      }
      pageToken = payload['nextPageToken']?.toString();
    } while (pageToken != null && pageToken.isNotEmpty);

    return items;
  }
}
