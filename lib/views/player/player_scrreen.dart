import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../songs/songs.dart';
import 'player_session.dart';

class PlayerScreen extends StatefulWidget {
  final Song? song;

  const PlayerScreen({super.key, this.song});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin
{
  final PlayerSession _session = PlayerSession.instance;
  late final AnimationController _discController;
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

    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    _sessionSub = _session.stream.listen((_) {
      if (!mounted) return;
      _syncDiscRotation();
      setState(() {});
    });

    _syncDiscRotation();
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _discController.dispose();
    super.dispose();
  }

  void _syncDiscRotation() {
    if (_session.isPlaying) {
      if (!_discController.isAnimating) {
        _discController.repeat(min: _discController.value);
      }
      return;
    }
    if (_discController.isAnimating) {
      _discController.stop(canceled: false);
    }
  }

  void _minimizePlayer() {
    _session.minimize();
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _openLyricsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LyricsFullPage(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          elevation: 0,
          content: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
          ),
        ),
      );
  }

  Future<void> _openMoreActionsSheet() async {
    final song = _session.currentSong ?? widget.song;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        const Color(0xFFB8D3F0).withValues(alpha: 0.16),
                        const Color(0xFF9DB5D6).withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.34),
                      width: 1.05,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 4,
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          _session.isCurrentSongLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.white,
                        ),
                        title: Text(
                          _session.isCurrentSongLiked
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          _session.toggleLikeCurrentSong();
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.library_music_rounded,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'View album',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          song?.album ?? 'Unknown album',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.66),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.close_rounded, color: Colors.white),
                        title: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDevicesSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        const Color(0xFFB8D3F0).withValues(alpha: 0.16),
                        const Color(0xFF9DB5D6).withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.34),
                      width: 1.05,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 4,
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      ..._session.availableDevices.map((device) {
                        final selected = _session.activeDevice == device;
                        return ListTile(
                          leading: Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? const Color(0xFF39D98A)
                                : Colors.white.withValues(alpha: 0.8),
                          ),
                          title: Text(
                            device,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _session.setActiveDevice(device);
                            Navigator.pop(context);
                            _showSnack('Output switched to $device');
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _repeatIcon(RepeatMode mode) {
    if (mode == RepeatMode.one) {
      return Icons.repeat_one_rounded;
    }
    return Icons.repeat_rounded;
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  ImageProvider<Object> _songArtwork(Song? song) {
    final imageUrl = song?.imageUrl?.trim() ?? '';
    if (imageUrl.isNotEmpty) return NetworkImage(imageUrl);
    return const AssetImage(
      'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
    );
  }

  Widget _buildRetroDisc(ImageProvider<Object> artwork, double size) {
    final spindleSize = size * 0.16;

    return RotationTransition(
      turns: _discController,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.18, -0.22),
            radius: 0.95,
            colors: [
              Color(0xFF4A4E57),
              Color(0xFF22262E),
              Color(0xFF11141A),
              Color(0xFF050608),
            ],
            stops: [0.02, 0.32, 0.68, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.48),
              blurRadius: 38,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Image(
                image: artwork,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.28),
                  ],
                  stops: const [0.45, 0.74, 1.0],
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                size: Size.square(size),
                painter: _DiscGroovePainter(),
              ),
            ),
            Container(
              width: spindleSize,
              height: spindleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0E1117),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: spindleSize * 0.34,
                  height: spindleSize * 0.34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC5CAD1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetroTurntable(ImageProvider<Object> artwork, double discSize) {
    return SizedBox(
      width: discSize,
      height: discSize + 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildRetroDisc(artwork, discSize),
          ),
          Positioned(
            top: 2,
            right: 14,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _session.isPlaying ? 0.16 : -0.04),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (context, angle, child) {
                return Transform.rotate(angle: angle, child: child);
              },
              child: SizedBox(
                width: discSize * 0.32,
                height: discSize * 0.44,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Positioned(
                      top: 0,
                      right: discSize * 0.06,
                      child: Container(
                        width: discSize * 0.105,
                        height: discSize * 0.105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0A0C10),
                          border: Border.all(
                            color: const Color(0xFF2E333B),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: discSize * 0.03,
                            height: discSize * 0.03,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF656B74),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: discSize * 0.055,
                      right: discSize * 0.098,
                      child: Container(
                        width: discSize * 0.028,
                        height: discSize * 0.24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF272C33),
                              Color(0xFF13171D),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: discSize * 0.27,
                      right: discSize * 0.088,
                      child: Container(
                        width: discSize * 0.048,
                        height: discSize * 0.075,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: const Color(0xFF0E1116),
                          border: Border.all(
                            color: const Color(0xFF343941),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: discSize * 0.337,
                      right: discSize * 0.09,
                      child: Transform.rotate(
                        angle: 0.22,
                        child: Container(
                          width: discSize * 0.018,
                          height: discSize * 0.028,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFF8A9098),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final song = _session.currentSong ?? widget.song;
    final artwork = _songArtwork(song);
    final title = song?.title ?? 'Unknown Song';
    final artist = song?.artist ?? 'Unknown Artist';
    final position = _session.position;
    final duration = _session.duration;
    final isLiked = _session.isCurrentSongLiked;
    final isShuffleOn = _session.isShuffleEnabled;
    final repeatMode = _session.repeatMode;
    final canGoNext = _session.hasNextTrack;
    final canGoPrevious = _session.hasPreviousTrack || position > const Duration(seconds: 3);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _session.minimize();
        }
      },
      child: Scaffold(
        body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: artwork, fit: BoxFit.cover),
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
                final artSize = math.min(
                  constraints.maxWidth - (sidePadding * 2),
                  360.0,
                );
                final discSize = artSize * 0.84;
                final devicesCardWidth = math.min(
                  constraints.maxWidth * 0.72,
                  270.0,
                );

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
                            onPressed: _openMoreActionsSheet,
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(44, 44),
                            ),
                            icon: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.28),
                                        const Color(
                                          0xFFB8D3F0,
                                        ).withValues(alpha: 0.18),
                                        const Color(
                                          0xFF9DB5D6,
                                        ).withValues(alpha: 0.14),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.34),
                                      width: 1.05,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRetroTurntable(artwork, discSize),
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
                          IconButton(
                            onPressed: _session.toggleLikeCurrentSong,
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isLiked
                                  ? const Color(0xFFFF5A7A)
                                  : Colors.white.withValues(alpha: 0.9),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          trackHeight: 3,
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.32,
                          ),
                          activeTrackColor: Colors.white,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: position.inMilliseconds.toDouble().clamp(
                            0,
                            duration.inMilliseconds.toDouble(),
                          ),
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            _session.seek(
                              Duration(milliseconds: value.round()),
                            );
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
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
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
                            onPressed: _session.toggleShuffle,
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color: isShuffleOn
                                  ? const Color(0xFF39D98A)
                                  : Colors.white,
                              size: 26,
                            ),
                          ),
                          IconButton(
                            onPressed: canGoPrevious ? _session.playPrevious : null,
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: canGoPrevious
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.35),
                              size: 36,
                            ),
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
                            onPressed: canGoNext ? _session.playNext : null,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: canGoNext
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.35),
                              size: 36,
                            ),
                          ),
                          IconButton(
                            onPressed: _session.cycleRepeatMode,
                            icon: Icon(
                              _repeatIcon(repeatMode),
                              color: repeatMode == RepeatMode.off
                                  ? Colors.white
                                  : const Color(0xFF39D98A),
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: devicesCardWidth,
                          child: OutlinedButton.icon(
                            onPressed: _openDevicesSheet,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(
                              Icons.speaker_group_rounded,
                              size: 18,
                            ),
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Devices Connected'),
                                Text(
                                  _session.activeDevice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
      ),
    );
  }
}

class _DiscGroovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.14);

    for (double r = radius * 0.26; r < radius * 0.98; r += radius * 0.055) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
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
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                18,
                                20,
                                18,
                              ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.48,
                                              ),
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
