import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../services/youtube_playlist_service.dart';

class YouTubePlaylistScreen extends StatefulWidget {
  const YouTubePlaylistScreen({
    super.key,
    this.initialVideoId,
    this.initialIndex,
  });

  final String? initialVideoId;
  final int? initialIndex;

  @override
  State<YouTubePlaylistScreen> createState() => _YouTubePlaylistScreenState();
}

class _YouTubePlaylistScreenState extends State<YouTubePlaylistScreen> {
  late final WebViewController _controller;
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
    _loadPlayer(videoId: widget.initialVideoId, index: widget.initialIndex);
  }

  void _loadPlayer({String? videoId, int? index}) {
    final youtubePage = Uri.https('m.youtube.com', '/watch', {
      if (videoId != null) 'v': videoId,
      'list': YouTubePlaylistService.playlistId,
      if (index != null) 'index': index.toString(),
    });
    _controller.loadRequest(youtubePage);
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
      // The official mobile YouTube page fills this route. Songs remain
      // browsable from the Home rail, while this view retains YouTube's own
      // controls, playlist panel, and navigation.
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_webError == null)
              WebViewWidget(controller: _controller)
            else
              _PlayerError(message: _webError!, onRetry: _reloadPlayer),
            if (_progress < 100)
              Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 2,
                  color: const Color(0xFFFF0033),
                  backgroundColor: Colors.white12,
                ),
              ),
          ],
        ),
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
