import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({
    super.key,
    this.title = 'All Songs',
    this.tracks = const [],
  });

  final String title;
  final List<Map<String, String>> tracks;

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  static const List<String> _filters = [
    'All',
    'Trending',
    'Recently Added',
    'Favorites',
  ];

  static const List<Map<String, String>> _fallbackTracks = [
    {
      'title': 'Kesariya',
      'artist': 'Arijit Singh',
      'duration': '4:28',
      'cover': 'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
      'tag': 'Trending',
    },
    {
      'title': 'Raataan Lambiyan',
      'artist': 'Jubin Nautiyal',
      'duration': '3:51',
      'cover':
          'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
      'tag': 'Trending',
    },
    {
      'title': 'Mere Mehboob Qayamat Hogi',
      'artist': 'Kishore Kumar',
      'duration': '3:47',
      'cover':
          'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
      'tag': 'Favorites',
    },
    {
      'title': 'Piya Tu Ab To Aaja',
      'artist': 'Asha Bhosle',
      'duration': '5:26',
      'cover':
          'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
      'tag': 'Recently Added',
    },
    {
      'title': 'Chura Ke Dil Mera',
      'artist': 'Alka Yagnik',
      'duration': '4:41',
      'cover':
          'assets/albums/Best-Of-Alka-Yagnik-Hindi-2020-20200506121339-500x500.jpg',
      'tag': 'Favorites',
    },
    {
      'title': 'Tum Hi Ho Bandhu',
      'artist': 'Neeraj Shridhar',
      'duration': '4:43',
      'cover': 'assets/albums/51TCww-h17L._UF1000,1000_QL80_.jpg',
      'tag': 'Recently Added',
    },
  ];

  int _selectedFilter = 0;

  List<Map<String, String>> get _sourceTracks {
    if (widget.tracks.isNotEmpty) return widget.tracks;
    return _fallbackTracks;
  }

  List<Map<String, String>> get _visibleTracks {
    if (_selectedFilter == 0) return _sourceTracks;
    final selected = _filters[_selectedFilter];
    return _sourceTracks.where((song) => song['tag'] == selected).toList();
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
                expandedHeight: 210,
                elevation: 0,
                backgroundColor: Colors.black.withValues(alpha: 0.16),
                title: Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 86, 16, 14),
                    child: _glassPanel(
                      borderRadius: 22,
                      child: Row(
                        children: [
                          _summaryStat(
                            icon: Icons.library_music_rounded,
                            label: 'Songs',
                            value: _sourceTracks.length.toString(),
                          ),
                          _summaryDivider(),
                          _summaryStat(
                            icon: Icons.trending_up_rounded,
                            label: 'Trending',
                            value: _sourceTracks
                                .where((song) => song['tag'] == 'Trending')
                                .length
                                .toString(),
                          ),
                          _summaryDivider(),
                          _summaryStat(
                            icon: Icons.favorite_rounded,
                            label: 'Favorites',
                            value: _sourceTracks
                                .where((song) => song['tag'] == 'Favorites')
                                .length
                                .toString(),
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
                  child: Row(
                    children: [
                      _actionButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Play All',
                        accent: const Color(0xFF6EB8FF),
                      ),
                      const SizedBox(width: 10),
                      _actionButton(
                        icon: Icons.shuffle_rounded,
                        label: 'Shuffle',
                        accent: const Color(0xFFFFA870),
                      ),
                    ],
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
              if (_visibleTracks.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No songs in this category',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: _visibleTracks.length,
                    itemBuilder: (context, index) {
                      final song = _visibleTracks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _songCard(index + 1, song),
                      );
                    },
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Expanded(
      child: _glassPanel(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _songCard(int index, Map<String, String> song) {
    final cover = song['cover'] ?? '';
    final tag = song['tag'] ?? 'All';

    return _glassPanel(
      borderRadius: 26,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 26,
            alignment: Alignment.centerLeft,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 54,
              height: 54,
              child: cover.startsWith('assets/')
                  ? Image.asset(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackCover(),
                    )
                  : _fallbackCover(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['title'] ?? 'Unknown Song',
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
                  song['artist'] ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
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
              const SizedBox(height: 7),
              Text(
                song['duration'] ?? '--:--',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz_rounded,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover() {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
