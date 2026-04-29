import 'dart:ui';

import 'package:flutter/material.dart';

import '../background/gradient_mesh_background.dart';
import '../music/music_repository.dart';
import '../songs/albums/album_page.dart';
import '../songs/songs.dart';
import '../views/player/player_scrreen.dart';
import '../views/player/player_session.dart';
import '../widgets/app_loading_animation.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const double _sidePadding = 16;

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  String _selectedMood = 'Trending';
  final List<String> _recentSearches = [
    'Arijit songs',
    'Late night chill',
    'Romantic 90s',
    'Gym mix',
  ];

  final List<String> _moods = const [
    'Trending',
    'New Releases',
    'Party',
    'Chill',
    'Workout',
    'Romance',
    'Focus Mode',
  ];

  final List<Map<String, dynamic>> _genres = const [
    {
      'title': 'Desi Pop',
      'icon': Icons.music_note_rounded,
      'start': Color(0xFFFF5E73),
      'end': Color(0xFFFFA657),
    },
    {
      'title': 'Retro',
      'icon': Icons.graphic_eq_rounded,
      'start': Color(0xFF5D75FF),
      'end': Color(0xFF48C6FF),
    },
    {
      'title': 'Indie',
      'icon': Icons.bolt_rounded,
      'start': Color(0xFF18A87C),
      'end': Color(0xFF62DFA8),
    },
    {
      'title': 'Lo-Fi',
      'icon': Icons.nights_stay_rounded,
      'start': Color(0xFFA45DFF),
      'end': Color(0xFFFF76C4),
    },
  ];

  bool get _showSearchResults => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_refreshState);
    _searchFocusNode = FocusNode()..addListener(_refreshState);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshState)
      ..dispose();
    _searchFocusNode
      ..removeListener(_refreshState)
      ..dispose();
    super.dispose();
  }

  void _refreshState() {
    if (mounted) setState(() {});
  }

  void _onSubmit(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 7) {
        _recentSearches.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

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
          Positioned(
            top: -90,
            right: -70,
            child: _ambientOrb(size: 300, color: const Color(0x66FF7448)),
          ),
          Positioned(
            top: 140,
            left: -90,
            child: _ambientOrb(size: 250, color: const Color(0x664A86FF)),
          ),
          IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _searchFocusNode.hasFocus ? 1 : 0,
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withValues(alpha: 0.14)),
              ),
            ),
          ),
          SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: false,
            child: FutureBuilder<List<Song>>(
              future: MusicRepository.fetchSongs(),
              builder: (context, allSongsSnapshot) {
                if (allSongsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: AppLoadingAnimation());
                }

                if (allSongsSnapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load songs: ${allSongsSnapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                final allSongs = allSongsSnapshot.data ?? const <Song>[];
                final trendingSongs = allSongs.take(8).toList();
                final quickPicks = allSongs.take(6).toList();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: topInset + 12)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        _sidePadding,
                        0,
                        _sidePadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(child: _buildHeader()),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        _sidePadding,
                        16,
                        _sidePadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(child: _buildSearchBar()),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        _sidePadding,
                        16,
                        _sidePadding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(child: _buildMoodRow()),
                    ),
                    if (_showSearchResults)
                      _buildSearchResultsSliver()
                    else ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          _sidePadding,
                          20,
                          _sidePadding,
                          8,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _sectionTitle('Trending This Week'),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildQuickPicks(quickPicks)),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          _sidePadding,
                          24,
                          _sidePadding,
                          10,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _sectionTitle('Browse All'),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sidePadding,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.05,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final genre = _genres[index];
                            return _buildGenreCard(genre);
                          }, childCount: _genres.length),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          _sidePadding,
                          22,
                          _sidePadding,
                          10,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _sectionTitle('Recent Searches'),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _sidePadding,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _buildRecentSearches(),
                        ),
                      ),
                      if (trendingSongs.isNotEmpty) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            _sidePadding,
                            22,
                            _sidePadding,
                            10,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _sectionTitle('Online Albums'),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _sidePadding,
                          ),
                          sliver: SliverList.separated(
                            itemCount: trendingSongs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final song = trendingSongs[index];
                              return _buildOnlineAlbumTile(song);
                            },
                          ),
                        ),
                      ],
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSliver() {
    return SliverFillRemaining(
      hasScrollBody: true,
      child: FutureBuilder<List<Song>>(
        future: MusicRepository.searchSongs(_searchController.text.trim()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoadingAnimation());
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
          if (songs.isEmpty) {
            return const Center(
              child: Text(
                'No matching songs found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              _sidePadding,
              12,
              _sidePadding,
              0,
            ),
            itemCount: songs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _buildResultTile(songs[index], songs),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white.withValues(alpha: 0.98),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Find songs, artists, albums, and your vibe',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.09),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white.withValues(alpha: 0.82)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSubmitted: _onSubmit,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Try "Arijit", "Lo-Fi", "Retro"...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                child: _searchController.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        key: const ValueKey('clear_btn'),
                        onPressed: _searchController.clear,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodRow() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final tag = _moods[index];
          final isSelected = tag == _selectedMood;
          return GestureDetector(
            onTap: () => setState(() => _selectedMood = tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF5E73), Color(0xFFFF9A57)],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.10),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _moods.length,
      ),
    );
  }

  Widget _buildQuickPicks(List<Song> songs) {
    if (songs.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No online songs available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return SizedBox(
      height: 176,
      child: ListView.separated(
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () => _openAlbumFromSong(song),
            child: Container(
              width: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A6AFF).withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _songImage(song.imageUrl),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.86),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.84),
                              fontSize: 12,
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
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: songs.length,
      ),
    );
  }

  Widget _buildGenreCard(Map<String, dynamic> genre) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [genre['start'] as Color, genre['end'] as Color],
        ),
        boxShadow: [
          BoxShadow(
            color: (genre['start'] as Color).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(genre['icon'] as IconData, color: Colors.white, size: 26),
          const Spacer(),
          Text(
            genre['title'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _recentSearches.map((query) {
        return GestureDetector(
          onTap: () {
            _searchController.text = query;
            _searchController.selection = TextSelection.collapsed(
              offset: query.length,
            );
            _searchFocusNode.requestFocus();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Text(
              query,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultTile(Song song, List<Song> queue) {
    return GestureDetector(
      onTap: () {
        _onSubmit(song.title);
        _searchFocusNode.unfocus();
        final session = PlayerSession.instance;
        session.setQueue(queue, currentSong: song);
        session.playSong(song);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: _songImage(song.imageUrl),
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${song.artist} • ${song.album}',
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
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineAlbumTile(Song song) {
    return GestureDetector(
      onTap: () => _openAlbumFromSong(song),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: _songImage(song.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.album,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _songImage(String? imageUrl) {
    final source = (imageUrl ?? '').trim();
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    if (source.isNotEmpty) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.white.withValues(alpha: 0.14),
      child: const Icon(Icons.music_note_rounded, color: Colors.white),
    );
  }

  Widget _sectionTitle(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.96),
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _ambientOrb({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }

  void _openAlbumFromSong(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumPage(
          artist: song.artist,
          albumTitle: song.album,
          albumCover: song.imageUrl,
        ),
      ),
    );
  }
}
