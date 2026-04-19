import 'dart:ui';

import 'package:flutter/material.dart';

import '../background/gradient_mesh_background.dart';
import '../music/music_repository.dart';
import '../songs/albums/album_page.dart';
import '../songs/songs.dart';
import '../views/player/player_scrreen.dart';
import '../views/player/player_session.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()
      ..addListener(() {
        setState(() {
          _query = _controller.text.trim();
        });
      });
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _searchBar(),
                ),
                Expanded(
                  child: FutureBuilder<List<Song>>(
                    future: _query.isEmpty
                        ? MusicRepository.fetchSongs()
                        : MusicRepository.searchSongs(_query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Search failed: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }

                      final songs = snapshot.data ?? const <Song>[];
                      final artists = _extractArtists(songs);
                      final albums = _extractAlbums(songs);

                      if (songs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No matching songs found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _sectionHeader('Songs', '${songs.length}'),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            sliver: SliverList.builder(
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _songRow(song, songs),
                                );
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _sectionHeader(
                              'Artists',
                              '${artists.length}',
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 78,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final artist = artists[index];
                                  return _pill(
                                    label: artist,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AlbumPage(artist: artist),
                                        ),
                                      );
                                    },
                                  );
                                },
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemCount: artists.length,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _sectionHeader('Albums', '${albums.length}'),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            sliver: SliverList.builder(
                              itemCount: albums.length,
                              itemBuilder: (context, index) {
                                final album = albums[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _albumRow(context, album.$1, album.$2),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white.withValues(alpha: 0.86)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search songs, artists, albums',
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                IconButton(
                  onPressed: _controller.clear,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(count, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _songRow(Song song, List<Song> queue) {
    final image = song.imageUrl?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            onTap: () {
              final session = PlayerSession.instance;
              session.setQueue(queue, currentSong: song);
              session.playSong(song);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: image.startsWith('http')
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            title: Text(
              song.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${song.artist} • ${song.album}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }

  Widget _albumRow(BuildContext context, String album, String artist) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ListTile(
          tileColor: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          ),
          title: Text(album, style: const TextStyle(color: Colors.white)),
          subtitle: Text(artist, style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlbumPage(artist: artist, albumTitle: album),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _pill({required String label, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.14),
      child: const Icon(Icons.music_note_rounded, color: Colors.white),
    );
  }
}

List<String> _extractArtists(List<Song> songs) {
  final set = <String>{};
  for (final song in songs) {
    final artist = song.artist.trim();
    if (artist.isNotEmpty) set.add(artist);
  }
  return set.toList()..sort();
}

List<(String, String)> _extractAlbums(List<Song> songs) {
  final set = <(String, String)>{};
  for (final song in songs) {
    final album = song.album.trim();
    final artist = song.artist.trim();
    if (album.isNotEmpty) {
      set.add((album, artist.isEmpty ? 'Unknown Artist' : artist));
    }
  }
  final list = set.toList();
  list.sort((a, b) => a.$1.toLowerCase().compareTo(b.$1.toLowerCase()));
  return list;
}
