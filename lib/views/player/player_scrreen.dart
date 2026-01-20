import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rizzmusicapp/naviogations/tabbar.dart';
import '../../songs/songs.dart';

class PlayerScreen extends StatefulWidget {
  final Song? song;

  const PlayerScreen({super.key, this.song});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer(); // URL loading removed
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.song?.title ?? "Unknown Song";
    final artist = widget.song?.artist ?? "Unknown Artist";

    String fmt(Duration d) {
      String two(int n) => n.toString().padLeft(2, '0');
      final m = two(d.inMinutes.remainder(60));
      final s = two(d.inSeconds.remainder(60));
      return "$m:$s";
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 32),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Tabbars()),
                          (route) => false,
                    );
                  },
                ),

                const Spacer(),

                Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                Slider(
                  value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                  max: _duration.inSeconds.toDouble() == 0 ? 1 : _duration.inSeconds.toDouble(),
                  onChanged: (value) {},
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fmt(_position),
                          style: const TextStyle(color: Colors.white70)),
                      Text(fmt(_duration),
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white, size: 36),
                      onPressed: () {},
                    ),

                    const SizedBox(width: 22),

                    GestureDetector(
                      onTap: () async {

                        setState(() => isPlaying = !isPlaying);
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(width: 22),

                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          color: Colors.white, size: 36),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
