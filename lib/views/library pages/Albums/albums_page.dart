import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';
import '../../../songs/albums/album_page.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key, this.selectedAlbums = const []});

  final List<Map<String, String>> selectedAlbums;

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  static const List<String> _filters = ['All', 'Trending', 'Modern', 'Legends'];

  static const List<Map<String, String>> _fallbackAlbums = [
    {
      'title': 'Aashiqui 2',
      'artist': 'Arijit Singh',
      'tracks': '24 tracks',
      'year': '2013',
      'image': 'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
      'tag': 'Trending',
      'group': 'Modern',
    },
    {
      'title': 'Best Of Jubin',
      'artist': 'Jubin Nautiyal',
      'tracks': '18 tracks',
      'year': '2023',
      'image':
          'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
      'tag': 'Trending',
      'group': 'Modern',
    },
    {
      'title': 'Best Of Kishore',
      'artist': 'Kishore Kumar',
      'tracks': '26 tracks',
      'year': '1958',
      'image':
          'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
      'tag': 'Classic',
      'group': 'Legends',
    },
    {
      'title': 'Asha: A Brand New Album',
      'artist': 'Asha Bhosle',
      'tracks': '17 tracks',
      'year': '2018',
      'image':
          'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
      'tag': 'Classic',
      'group': 'Legends',
    },
    {
      'title': 'Best Of Alka',
      'artist': 'Alka Yagnik',
      'tracks': '21 tracks',
      'year': '2020',
      'image':
          'assets/albums/Best-Of-Alka-Yagnik-Hindi-2020-20200506121339-500x500.jpg',
      'tag': 'Evergreen',
      'group': 'Legends',
    },
    {
      'title': 'Shreya Collection',
      'artist': 'Shreya Ghoshal',
      'tracks': '20 tracks',
      'year': '2020',
      'image':
          'assets/albums/Celebrating-Shreya-Ghoshal-Hindi-2020-20200309113133-500x500.jpg',
      'tag': 'Popular',
      'group': 'Modern',
    },
    {
      'title': 'Love Stories',
      'artist': 'Sonu Nigam',
      'tracks': '16 tracks',
      'year': '2021',
      'image':
          'assets/albums/Sonu-Nigam-Love-Stories-Hindi-2021-20210721001549-500x500.jpg',
      'tag': 'Top Picks',
      'group': 'Modern',
    },
    {
      'title': 'Best Of Udit',
      'artist': 'Udit Narayan',
      'tracks': '19 tracks',
      'year': '2019',
      'image':
          'assets/albums/The-Best-Of-Udit-Narayan-Hindi-2019-20191128094504-500x500.jpg',
      'tag': 'Throwback',
      'group': 'Legends',
    },
  ];

  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> get _albums {
    if (widget.selectedAlbums.isNotEmpty) {
      return widget.selectedAlbums;
    }
    return _fallbackAlbums;
  }

  List<Map<String, String>> get _visibleAlbums {
    List<Map<String, String>> filtered = _albums;
    if (_selectedFilter != 0) {
      final selected = _filters[_selectedFilter];
      if (selected == 'Trending') {
        filtered = filtered
            .where((album) => album['tag'] == 'Trending')
            .toList();
      } else {
        filtered = filtered
            .where((album) => album['group'] == selected)
            .toList();
      }
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return filtered;
    }

    return filtered.where((album) {
      final title = (album['title'] ?? '').toLowerCase();
      final artist = (album['artist'] ?? '').toLowerCase();
      final tag = (album['tag'] ?? '').toLowerCase();
      return title.contains(query) ||
          artist.contains(query) ||
          tag.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                elevation: 0,
                backgroundColor: Colors.black.withValues(alpha: 0.16),
                title: const Text(
                  'Albums',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 86, 16, 14),
                    child: _glassPanel(
                      borderRadius: 22,
                      child: Row(
                        children: [
                          _summaryStat(
                            icon: Icons.album_rounded,
                            label: 'Albums',
                            value: _albums.length.toString(),
                          ),
                          _summaryDivider(),
                          _summaryStat(
                            icon: Icons.trending_up_rounded,
                            label: 'Trending',
                            value: _albums
                                .where((album) => album['tag'] == 'Trending')
                                .length
                                .toString(),
                          ),
                          _summaryDivider(),
                          _summaryStat(
                            icon: Icons.music_note_rounded,
                            label: 'Tracks',
                            value: _totalTracks(_albums),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: _glassPanel(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.manage_search_rounded,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                        hintText: 'Find albums by name or artist',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w600,
                        ),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final selected = _selectedFilter == index;
                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setState(() => _selectedFilter = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: selected
                                ? Colors.white.withValues(alpha: 0.24)
                                : Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.38)
                                  : Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: selected ? 1 : 0.86,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _filters.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (_visibleAlbums.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No albums in this category',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.66,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final album = _visibleAlbums[index];
                      return _albumCard(context, album);
                    }, childCount: _visibleAlbums.length),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassPanel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    double borderRadius = 20,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _summaryStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.86), size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 42,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }

  Widget _albumCard(BuildContext context, Map<String, String> album) {
    final image = album['image'] ?? '';
    final title = album['title'] ?? 'Unknown Album';
    final artist = album['artist'] ?? 'Unknown Artist';
    final tracks = album['tracks'] ?? '';
    final year = album['year'] ?? '';
    final tag = album['tag'] ?? 'Album';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AlbumPage(artist: artist)),
        );
      },
      child: _glassPanel(
        borderRadius: 22,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: image.startsWith('assets/')
                    ? Image.asset(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackCover(),
                      )
                    : _fallbackCover(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withValues(alpha: 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$tracks • $year',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      child: const Icon(Icons.album_rounded, color: Colors.white, size: 28),
    );
  }

  String _totalTracks(List<Map<String, String>> albums) {
    int total = 0;
    for (final album in albums) {
      final raw = album['tracks'] ?? '';
      final number = int.tryParse(raw.split(' ').first) ?? 0;
      total += number;
    }
    return total.toString();
  }
}
