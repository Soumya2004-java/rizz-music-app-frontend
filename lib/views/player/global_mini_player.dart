import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rizzmusicapp/services/app_navigator.dart';
import 'package:rizzmusicapp/services/tabbar_visibility.dart';

import '../../songs/songs.dart';
import 'player_scrreen.dart';
import 'player_session.dart';

class GlobalMiniPlayerOverlay extends StatelessWidget {
  const GlobalMiniPlayerOverlay({super.key});

  ImageProvider<Object> _songArtwork(String? imageUrl) {
    final normalized = imageUrl?.trim() ?? '';
    if (normalized.isNotEmpty) return NetworkImage(normalized);
    return const AssetImage(
      'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
    );
  }

  void _openPlayer(BuildContext context, PlayerSession session, Song song) {
    session.expand();
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
    );
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
        final isVisible = song != null && data.isMinimized;

        if (song == null) {
          return const SizedBox.shrink();
        }

        final artwork = _songArtwork(song.imageUrl);
        return ValueListenableBuilder<bool>(
          valueListenable: tabBarVisibleNotifier,
          builder: (context, isTabBarVisible, _) {
            final bottomOffset = isTabBarVisible ? 88.0 : 16.0;
            final horizontalInset = isTabBarVisible ? 26.0 : 22.0;
            return AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: isVisible ? Offset.zero : const Offset(0, 1.08),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: isVisible ? 1 : 0,
                child: Material(
                  type: MaterialType.transparency,
                  child: IgnorePointer(
                    ignoring: !isVisible,
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.fromLTRB(
                        horizontalInset,
                        0,
                        horizontalInset,
                        bottomOffset,
                      ),
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.28),
                                    const Color(0xFFB8D3F0).withValues(alpha: 0.18),
                                    const Color(0xFF9DB5D6).withValues(alpha: 0.14),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.36),
                                  width: 1.1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -30,
                                    right: -12,
                                    child: Container(
                                      width: 120,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.34),
                                            Colors.white.withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _openPlayer(context, session, song),
                                          onVerticalDragEnd: (details) {
                                            if (details.primaryVelocity != null &&
                                                details.primaryVelocity! < -420) {
                                              _openPlayer(context, session, song);
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(
                                                  999,
                                                ),
                                                child: SizedBox(
                                                  width: 38,
                                                  height: 38,
                                                  child: Image(
                                                    image: artwork,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      song.title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color(0xFF12141A),
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.2,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      '${song.artist} • ${song.album}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF12141A,
                                                        ).withValues(alpha: 0.64),
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: data.hasPreviousTrack
                                            ? session.playPrevious
                                            : null,
                                        icon: Icon(
                                          Icons.skip_previous_rounded,
                                          color: data.hasPreviousTrack
                                              ? const Color(0xFF12141A)
                                              : const Color(
                                                  0xFF12141A,
                                                ).withValues(alpha: 0.35),
                                          size: 24,
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(
                                          minWidth: 30,
                                          minHeight: 30,
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: session.togglePlayPause,
                                        icon: Icon(
                                          data.isPlaying
                                              ? Icons.pause_circle_filled_rounded
                                              : Icons.play_circle_fill_rounded,
                                          color: const Color(0xFF12141A),
                                          size: 32,
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: data.hasNextTrack
                                            ? session.playNext
                                            : null,
                                        icon: Icon(
                                          Icons.skip_next_rounded,
                                          color: data.hasNextTrack
                                              ? const Color(0xFF12141A)
                                              : const Color(
                                                  0xFF12141A,
                                                ).withValues(alpha: 0.35),
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
