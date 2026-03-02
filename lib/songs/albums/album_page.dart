import 'dart:ui';

import 'package:flutter/material.dart';

import '../../background/gradient_mesh_background.dart';
import '../../views/player/player_scrreen.dart';
import '../../views/player/player_session.dart';
import '../songs.dart';
import '../songs_api.dart';

class AlbumPage extends StatelessWidget {
  final String artist;

  const AlbumPage({super.key, required this.artist});

  Future<List<Song>> _loadSongs() {
    final q = artist.trim();
    if (q.isEmpty) return SongApi.fetchSongs();
    return SongApi.searchSongs(q);
  }

  String _artistName(List<Song> songs) {
    final q = artist.trim();
    if (q.isNotEmpty) return q;
    if (songs.isNotEmpty && songs.first.artist.trim().isNotEmpty) {
      return songs.first.artist;
    }
    return 'Various Artists';
  }

  String _albumName(List<Song> songs) {
    if (songs.isNotEmpty && songs.first.album.trim().isNotEmpty) {
      return songs.first.album;
    }
    return 'Album Collection';
  }

  String _songCountText(int count) => count == 1 ? '1 Song' : '$count Songs';

  Widget _heroCover() {
    return Container(
      width: 214,
      height: 214,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff7ec6ff), Color(0xffa88cff), Color(0xffff9dc6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66323a64),
            blurRadius: 28,
            spreadRadius: 2,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.34),
                    ],
                  ),
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.album_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _songTile(BuildContext context, Song song, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                PlayerSession.instance.playSong(song);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xff7ec6ff),
                            Color(0xffa88cff),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            snapshot.error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final songs = snapshot.data ?? <Song>[];
    final artistLabel = _artistName(songs);
    final albumLabel = _albumName(songs);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 390,
          elevation: 0,
          backgroundColor: Colors.black.withValues(alpha: 0.18),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(start: 18, bottom: 12),
            title: Text(
              albumLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            background: Stack(
              children: [
                const GradientMeshBackground(),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.52),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: const SizedBox.expand(),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.72),
                  child: _heroCover(),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artistLabel,
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.2,
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _songCountText(songs.length),
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _actionButton(Icons.play_arrow_rounded, 'Play'),
                    const SizedBox(width: 12),
                    _actionButton(Icons.shuffle_rounded, 'Shuffle'),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Tracks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (songs.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    child: const Text(
                      'No songs found for this album.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _songTile(context, songs[index], index),
              childCount: songs.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.46),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<List<Song>>(
            future: _loadSongs(),
            builder: _buildContent,
          ),
        ],
      ),
    );
  }
}
