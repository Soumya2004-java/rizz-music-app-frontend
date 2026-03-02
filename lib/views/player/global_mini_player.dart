import 'package:flutter/material.dart';

import 'player_scrreen.dart';
import 'player_session.dart';

class GlobalMiniPlayerOverlay extends StatelessWidget {
  const GlobalMiniPlayerOverlay({super.key});

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final session = PlayerSession.instance;
    return StreamBuilder<PlayerSnapshot>(
      stream: session.stream,
      initialData: session.snapshot,
      builder: (context, snapshot) {
        final data = snapshot.data ?? session.snapshot;
        final song = data.currentSong;

        if (song == null || !data.isMinimized) {
          return const SizedBox.shrink();
        }

        final bottomInset = MediaQuery.of(context).padding.bottom;
        return Positioned(
          left: 12,
          right: 12,
          bottom: bottomInset + 88,
          child: GestureDetector(
            onTap: () {
              session.expand();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E2430).withValues(alpha: 0.96),
                    const Color(0xFF171C26).withValues(alpha: 0.96),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          session.togglePlayPause();
                        },
                        icon: Icon(
                          data.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      value: data.duration.inMilliseconds == 0
                          ? 0
                          : data.position.inMilliseconds /
                              data.duration.inMilliseconds,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(data.position),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _fmt(data.duration),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
