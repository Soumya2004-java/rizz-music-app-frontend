import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rizzmusicapp/naviogations/tabbar.dart';

import '../../songs/songs.dart';
import 'player_session.dart';

class PlayerScreen extends StatefulWidget {
  final Song? song;

  const PlayerScreen({super.key, this.song});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  final PlayerSession _session = PlayerSession.instance;
  late final AnimationController _visualizerController;
  StreamSubscription<PlayerSnapshot>? _sessionSub;

  @override
  void initState() {
    super.initState();
    final incomingSong = widget.song;
    if (incomingSong != null) {
      if (_session.currentSong?.id != incomingSong.id) {
        _session.playSong(incomingSong);
      } else {
        _session.expand();
      }
    }

    _visualizerController = AnimationController(
      vsync: this,
      duration: _visualizerPeriod(_session.bpm),
    );

    _sessionSub = _session.stream.listen((_) {
      if (!mounted) return;
      _syncVisualizer();
      setState(() {});
    });

    _syncVisualizer();
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _visualizerController.dispose();
    super.dispose();
  }

  Duration _visualizerPeriod(double bpm) {
    final beatMs = (60000 / bpm).round();
    return Duration(milliseconds: beatMs * 4);
  }

  void _syncVisualizer() {
    _visualizerController.duration = _visualizerPeriod(_session.bpm);
    if (_session.isPlaying) {
      if (!_visualizerController.isAnimating) {
        _visualizerController.repeat();
      }
    } else {
      _visualizerController.stop();
    }
  }

  void _minimizePlayer() {
    _session.minimize();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Tabbars()),
    );
  }

  void _openLyricsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LyricsFullPage(),
        fullscreenDialog: true,
      ),
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final song = _session.currentSong ?? widget.song;
    final title = song?.title ?? 'Unknown Song';
    final artist = song?.artist ?? 'Unknown Artist';
    final position = _session.position;
    final duration = _session.duration;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x9911141A),
                  Color(0xF213141B),
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(color: Colors.black.withValues(alpha: 0.18)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sidePadding = constraints.maxWidth < 380 ? 16.0 : 24.0;
                final artSize =
                    math.min(constraints.maxWidth - (sidePadding * 2), 360.0);

                return Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _minimizePlayer,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'PLAYING FROM',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 10,
                                  letterSpacing: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'RizzMusic',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: artSize,
                        height: artSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.42),
                              blurRadius: 36,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 34,
                        child: AnimatedBuilder(
                          animation: _visualizerController,
                          builder: (context, child) {
                            final t = _visualizerController.value;
                            final beatPulse =
                                math.max(0.0, math.sin(t * math.pi * 8));
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(34, (index) {
                                final wave = math.sin(
                                  (t * math.pi * 10) + (index * 0.62),
                                );
                                final phaseBoost = (index % 4 == 0) ? 1.1 : 0.8;
                                final barBeat = beatPulse * 10 * phaseBoost;
                                final motion = _session.isPlaying
                                    ? (wave.abs() * 12) + barBeat
                                    : 0;
                                final barHeight = 4 + motion;
                                return Container(
                                  width: 3,
                                  height:
                                      barHeight.clamp(4.0, 30.0).toDouble(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 12),
                          trackHeight: 3,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.32),
                          activeTrackColor: Colors.white,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: position.inMilliseconds
                              .toDouble()
                              .clamp(0, duration.inMilliseconds.toDouble()),
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            _session.seek(Duration(milliseconds: value.round()));
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fmt(position),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _fmt(duration),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _openLyricsPage,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.5)),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            icon: const Icon(Icons.lyrics_rounded, size: 18),
                            label: const Text('Lyrics'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.shuffle_rounded,
                                color: Colors.white, size: 26),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_previous_rounded,
                                color: Colors.white, size: 36),
                          ),
                          GestureDetector(
                            onTap: _session.togglePlayPause,
                            child: Container(
                              height: 84,
                              width: 84,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                _session.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 52,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_next_rounded,
                                color: Colors.white, size: 36),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.repeat_rounded,
                                color: Colors.white, size: 26),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LyricsFullPage extends StatelessWidget {
  const LyricsFullPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = PlayerSession.instance;

    return StreamBuilder<PlayerSnapshot>(
      stream: session.stream,
      initialData: session.snapshot,
      builder: (context, snapshot) {
        final data = snapshot.data ?? session.snapshot;
        final song = data.currentSong;
        final title = song?.title ?? 'Unknown Song';
        final artist = song?.artist ?? 'Unknown Artist';
        final lyrics = session.lyricsForCurrentSong();
        final active = session.activeLyricIndex(lyrics, data.position);

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2E3340),
                      Color(0xFF1D212B),
                      Color(0xFF141821),
                    ],
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: Container(color: Colors.black.withValues(alpha: 0.26)),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.white, size: 32),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.74),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: lyrics.length,
                                itemBuilder: (context, index) {
                                  final isActive = index == active;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.48),
                                        fontSize: isActive ? 28 : 24,
                                        fontWeight: isActive
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        height: 1.24,
                                      ),
                                      child: Text(lyrics[index].text),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
