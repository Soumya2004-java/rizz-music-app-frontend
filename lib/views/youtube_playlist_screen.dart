import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../services/youtube_playlist_service.dart';

class YouTubePlaylistScreen extends StatefulWidget {
  const YouTubePlaylistScreen({super.key});

  @override
  State<YouTubePlaylistScreen> createState() => _YouTubePlaylistScreenState();
}

class _YouTubePlaylistScreenState extends State<YouTubePlaylistScreen> {
  static const _embedOrigin = 'https://rizzmusic-ff756.web.app';
  late final WebViewController _controller;
  late final Future<List<YouTubePlaylistItem>> _playlistFuture;
  int _progress = 0;
  String? _webError;

  @override
  void initState() {
    super.initState();
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            setState(() {
              _progress = 100;
              _webError = error.description;
            });
          },
        ),
      );
    _loadPlayer();
    _playlistFuture = YouTubePlaylistService.fetchAll(
      YouTubePlaylistService.playlistId,
    );
  }

  void _playTrack(YouTubePlaylistItem track, int index) {
    setState(() {
      _progress = 0;
      _webError = null;
    });
    _loadPlayer(videoId: track.videoId, index: index);
  }

  void _loadPlayer({String? videoId, int? index}) {
    final playerUri = Uri.https(
      'www.youtube.com',
      videoId == null ? '/embed' : '/embed/$videoId',
      {
        if (videoId == null) 'listType': 'playlist',
        'list': YouTubePlaylistService.playlistId,
        if (index != null) 'index': index.toString(),
        'playsinline': '1',
        'enablejsapi': '1',
        'origin': _embedOrigin,
        'widget_referrer': _embedOrigin,
      },
    );
    _controller.loadHtmlString(
      '''<!doctype html>
<html><head><meta name="referrer" content="strict-origin-when-cross-origin">
<style>html,body,iframe{margin:0;width:100%;height:100%;border:0;background:#000}</style>
</head><body><iframe src="$playerUri" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe></body></html>''',
      baseUrl: _embedOrigin,
    );
  }

  void _reloadPlayer() {
    setState(() {
      _progress = 0;
      _webError = null;
    });
    _loadPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('YouTube playlist'),
        actions: [
          IconButton(
            tooltip: 'Refresh playlist',
            onPressed: _reloadPlayer,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                if (_webError == null)
                  WebViewWidget(controller: _controller)
                else
                  _PlayerError(message: _webError!, onRetry: _reloadPlayer),
                if (_progress < 100)
                  LinearProgressIndicator(
                    value: _progress / 100,
                    minHeight: 2,
                    color: const Color(0xFFFF0033),
                    backgroundColor: Colors.white12,
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Playlist songs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<YouTubePlaylistItem>>(
              future: _playlistFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF0033)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }
                final tracks = snapshot.data ?? const <YouTubePlaylistItem>[];
                if (tracks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No playable videos found in this playlist.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: tracks.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.white12),
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 7),
                      onTap: () => _playTrack(track, index),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 76,
                          height: 48,
                          child: track.thumbnailUrl.isEmpty
                              ? const ColoredBox(color: Colors.white12)
                              : Image.network(
                                  track.thumbnailUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      title: Text(
                        track.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        track.channelTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60),
                      ),
                      trailing: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Color(0xFFFF0033),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111111),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white70),
              const SizedBox(height: 8),
              const Text(
                'YouTube player could not load.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
