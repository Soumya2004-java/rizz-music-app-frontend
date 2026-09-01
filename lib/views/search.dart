import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../background/gradient_mesh_background.dart';
import '../music/music_repository.dart';
import '../songs/albums/album_page.dart';
import '../songs/songs.dart';
import '../views/player/player_scrreen.dart';
import '../views/player/player_session.dart';
import '../widgets/app_cached_image.dart';
import '../widgets/app_skeletons.dart';
import '../widgets/neon_search_frame.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const double _sidePadding = 16;

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late Future<List<Song>> _allSongsFuture;
  double _scrollOffset = 0;

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

  bool get _showSearchResults => _searchController.text.trim().isNotEmpty;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    final nextOffset = notification.metrics.pixels.clamp(0.0, 1200.0);
    if ((nextOffset - _scrollOffset).abs() < 1) return false;

    if (!mounted) return false;
    setState(() {
      _scrollOffset = nextOffset;
    });
    return false;
  }

  double get _backgroundTintProgress => (_scrollOffset / 180).clamp(0.0, 1.0);

  Color get _backgroundTopColor => Color.lerp(
    const Color(0xFF111217).withValues(alpha: 0.18),
    const Color(0xFF050505).withValues(alpha: 0.95),
    _backgroundTintProgress,
  )!;

  Color get _backgroundBottomColor => Color.lerp(
    const Color(0xFF16181E).withValues(alpha: 0.32),
    const Color(0xFF000000).withValues(alpha: 1.0),
    _backgroundTintProgress,
  )!;

  double get _backgroundRadialOpacity => _backgroundTintProgress;

  bool get _isApplePlatform {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.macOS || platform == TargetPlatform.iOS;
  }

  ScrollBehavior get _searchScrollBehavior => const MaterialScrollBehavior()
      .copyWith(dragDevices: {...PointerDeviceKind.values});

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_refreshState);
    _searchFocusNode = FocusNode()..addListener(_refreshState);
    _allSongsFuture = MusicRepository.fetchSongs();
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

  Future<void> _refresh() async {
    MusicRepository.clearCaches();
    setState(() {
      _allSongsFuture = MusicRepository.fetchSongs();
    });
    await _allSongsFuture;
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

  void _focusSearchField() {
    if (!mounted) return;
    _searchFocusNode.requestFocus();
    _searchController.selection = TextSelection.collapsed(
      offset: _searchController.text.length,
    );
  }

  void _clearAndUnfocusSearchField() {
    if (!mounted) return;
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        SingleActivator(
          LogicalKeyboardKey.keyK,
          meta: _isApplePlatform,
          control: !_isApplePlatform,
        ): const _FocusSearchIntent(),
        const SingleActivator(LogicalKeyboardKey.escape):
            const _ClearSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
            onInvoke: (_) {
              _focusSearchField();
              return null;
            },
          ),
          _ClearSearchIntent: CallbackAction<_ClearSearchIntent>(
            onInvoke: (_) {
              _clearAndUnfocusSearchField();
              return null;
            },
          ),
        },
        child: Scaffold(
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
                      colors: [_backgroundTopColor, _backgroundBottomColor],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _backgroundRadialOpacity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.92, -0.82),
                          radius: 1.15,
                          colors: [
                            const Color(0xFF000000).withValues(alpha: 0.0),
                            Colors.transparent,
                          ],
                        ),
                      ),
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
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: false,
                child: ScrollConfiguration(
                  behavior: _searchScrollBehavior,
                  child: FutureBuilder<List<Song>>(
                    future: _allSongsFuture,
                    builder: (context, allSongsSnapshot) {
                      if (allSongsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SearchPageSkeleton();
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
                      final quickPicks = _weeklyTrendingSongs(
                        allSongs,
                      ).take(6).toList();

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: _handleScrollNotification,
                          child: CustomScrollView(
                            primary: true,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            slivers: [
                              SliverToBoxAdapter(
                                child: SizedBox(height: topInset + 12),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  _sidePadding,
                                  0,
                                  _sidePadding,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildHeader(),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  _sidePadding,
                                  16,
                                  _sidePadding,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildSearchBar(),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  _sidePadding,
                                  16,
                                  _sidePadding,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildMoodRow(),
                                ),
                              ),
                              if (_showSearchResults)
                                ..._buildSearchResultsSlivers(allSongs)
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
                                SliverToBoxAdapter(
                                  child: _buildQuickPicks(quickPicks),
                                ),
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
                                      return BrowseGenreTile(
                                        genre: browseGenres[index],
                                        songs: allSongs,
                                      );
                                    }, childCount: browseGenres.length),
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
                              ],
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 110),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSearchResultsSlivers(List<Song> allSongs) {
    final query = _normalizeQuery(_searchController.text);
    final songs = allSongs
        .where((song) => _matchesSearch(song, query))
        .toList();

    if (songs.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(_sidePadding, 40, _sidePadding, 0),
            child: Center(
              child: Text(
                'No matching songs found',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(_sidePadding, 12, _sidePadding, 0),
        sliver: SliverList.separated(
          itemCount: songs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _buildResultTile(songs[index], songs),
        ),
      ),
    ];
  }

  List<Song> _weeklyTrendingSongs(List<Song> songs) {
    final shuffled = List<Song>.of(songs);
    shuffled.shuffle(Random(_currentWeekSeed()));
    return shuffled;
  }

  int _currentWeekSeed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    return weekStart.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
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
    return NeonSearchFrame(
      height: 58,
      active: _searchFocusNode.hasFocus,
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withValues(alpha: 0.82)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: false,
              onSubmitted: _onSubmit,
              onTapOutside: (_) => _searchFocusNode.unfocus(),
              textInputAction: TextInputAction.search,
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
                    onPressed: () {
                      _searchController.clear();
                      _focusSearchField();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
          ),
        ],
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

  Widget _buildRecentSearches() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        primary: false,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _recentSearches.length,
        itemBuilder: (context, index) {
          final query = _recentSearches[index];
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
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
      ),
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

  Widget _songImage(String? imageUrl) {
    final source = (imageUrl ?? '').trim();
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return AppCachedImage(url: source, fit: BoxFit.cover);
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

  String _normalizeQuery(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesSearch(Song song, String query) {
    if (query.isEmpty) return true;
    final haystack = _normalizeQuery(
      '${song.title} ${song.artist} ${song.album}',
    );
    final tokens = query.split(' ').where((token) => token.isNotEmpty);
    return tokens.every(haystack.contains);
  }
}

class BrowseGenre {
  const BrowseGenre({
    required this.title,
    required this.icon,
    required this.start,
    required this.end,
    required this.imageAsset,
    this.imageAlignment = Alignment.centerRight,
  });

  final String title;
  final IconData icon;
  final Color start;
  final Color end;
  final String imageAsset;
  final Alignment imageAlignment;
}

const browseGenres = [
  BrowseGenre(
    title: 'Desi Pop',
    icon: Icons.music_note_rounded,
    start: Color(0xFFFF5E73),
    end: Color(0xFFFFA657),
    imageAsset: 'assets/images/mood_people/desi-pop.png',
  ),
  BrowseGenre(
    title: 'Hindi Love',
    icon: Icons.favorite_rounded,
    start: Color(0xFFFF5D8F),
    end: Color(0xFFFF8A5B),
    imageAsset: 'assets/images/mood_people/hindi-love.png',
  ),
  BrowseGenre(
    title: 'Sad Songs',
    icon: Icons.cloud_rounded,
    start: Color(0xFF5B6CFF),
    end: Color(0xFF8D9BFF),
    imageAsset: 'assets/images/mood_people/sad-songs.png',
  ),
  BrowseGenre(
    title: 'Punjabi',
    icon: Icons.music_video_rounded,
    start: Color(0xFFFFB347),
    end: Color(0xFFFF6F61),
    imageAsset: 'assets/images/mood_people/punjabi.png',
  ),
  BrowseGenre(
    title: 'Bengali',
    icon: Icons.palette_rounded,
    start: Color(0xFF18A87C),
    end: Color(0xFF62DFA8),
    imageAsset: 'assets/images/mood_people/bengali.png',
  ),
  BrowseGenre(
    title: 'Retro',
    icon: Icons.graphic_eq_rounded,
    start: Color(0xFF5D75FF),
    end: Color(0xFF48C6FF),
    imageAsset: 'assets/images/mood_people/retro.png',
  ),
  BrowseGenre(
    title: 'Indie',
    icon: Icons.bolt_rounded,
    start: Color(0xFFA45DFF),
    end: Color(0xFFFF76C4),
    imageAsset: 'assets/images/mood_people/indie.png',
  ),
  BrowseGenre(
    title: 'Lo-Fi',
    icon: Icons.nights_stay_rounded,
    start: Color(0xFF2D9CDB),
    end: Color(0xFF56CCF2),
    imageAsset: 'assets/images/mood_people/lofi.png',
  ),
  BrowseGenre(
    title: 'Dance',
    icon: Icons.sports_gymnastics_rounded,
    start: Color(0xFFFF7A18),
    end: Color(0xFFFFB347),
    imageAsset: 'assets/images/mood_people/dance.png',
  ),
  BrowseGenre(
    title: 'Devotional',
    icon: Icons.self_improvement_rounded,
    start: Color(0xFF6FCF97),
    end: Color(0xFF56CCF2),
    imageAsset: 'assets/images/mood_people/devotional.png',
  ),
  BrowseGenre(
    title: 'Hip Hop',
    icon: Icons.headphones_rounded,
    start: Color(0xFF3A7BD5),
    end: Color(0xFF00D2FF),
    imageAsset: 'assets/images/mood_people/hip-hop.png',
  ),
  BrowseGenre(
    title: 'Acoustic',
    icon: Icons.library_music_rounded,
    start: Color(0xFF8E8DFF),
    end: Color(0xFFB1A6FF),
    imageAsset: 'assets/images/mood_people/acoustic.png',
  ),
  BrowseGenre(
    title: 'Classics',
    icon: Icons.album_rounded,
    start: Color(0xFFB06AB3),
    end: Color(0xFFF9A1BC),
    imageAsset: 'assets/images/mood_people/classics.png',
  ),
];

class BrowseGenreTile extends StatelessWidget {
  const BrowseGenreTile({super.key, required this.genre, required this.songs});

  final BrowseGenre genre;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Browse ${genre.title}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BrowseCategoryPage(
                  title: genre.title,
                  icon: genre.icon,
                  start: genre.start,
                  end: genre.end,
                  songs: songs,
                ),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF121318),
                border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      genre.imageAsset,
                      fit: BoxFit.cover,
                      alignment: genre.imageAlignment,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x66000000),
                            Color(0x12000000),
                            Color(0x00000000),
                          ],
                          stops: [0, 0.58, 1],
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x26000000),
                            Color(0xE6000000),
                          ],
                          stops: [0, 0.40, 1],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Icon(
                            genre.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          genre.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Explore',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 15,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _ClearSearchIntent extends Intent {
  const _ClearSearchIntent();
}

class BrowseCategoryPage extends StatelessWidget {
  const BrowseCategoryPage({
    super.key,
    required this.title,
    required this.icon,
    required this.start,
    required this.end,
    required this.songs,
  });

  final String title;
  final IconData icon;
  final Color start;
  final Color end;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    final categorySongs = _categorySongs();
    final heroSong = categorySongs.isNotEmpty ? categorySongs.first : null;

    return Scaffold(
      backgroundColor: Colors.black,
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
                    start.withValues(alpha: 0.42),
                    Colors.black.withValues(alpha: 0.82),
                    Colors.black,
                  ],
                  stops: const [0, 0.38, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  expandedHeight: 280,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHero(context, categorySongs, heroSong),
                  ),
                ),
                if (categorySongs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No songs available for this category yet.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                    sliver: SliverList.separated(
                      itemCount: categorySongs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _CategorySongTile(
                          song: categorySongs[index],
                          queue: categorySongs,
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

  Widget _buildHero(
    BuildContext context,
    List<Song> categorySongs,
    Song? song,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (song != null) _songImage(song.imageUrl) else _fallbackImage(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.12),
                start.withValues(alpha: 0.54),
                Colors.black.withValues(alpha: 0.92),
              ],
              stops: const [0, 0.48, 1],
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [start, end]),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 25),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${categorySongs.length} tracks picked for this vibe',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (categorySongs.isNotEmpty)
                FilledButton.icon(
                  onPressed: () =>
                      _playSong(context, categorySongs.first, categorySongs),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Play',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Song> _categorySongs() {
    final keywords = _keywordsForTitle(title);
    final matched = songs.where((song) {
      final text = _normalizeCategoryText(
        '${song.title} ${song.artist} ${song.album}',
      );
      return keywords.any(text.contains);
    }).toList();

    if (matched.isNotEmpty) return matched.take(40).toList();

    final fallback = List<Song>.of(songs);
    fallback.shuffle(Random(title.hashCode));
    return fallback.take(30).toList();
  }

  List<String> _keywordsForTitle(String title) {
    switch (_normalizeCategoryText(title)) {
      case 'hindi love':
        return const ['love', 'romance', 'romantic', 'dil', 'pyaar', 'ishq'];
      case 'sad songs':
        return const ['sad', 'dard', 'alone', 'heartbreak', 'judai', 'bewafa'];
      case 'punjabi':
        return const ['punjabi', 'punjab', 'sidhu', 'diljit', 'ap dhillon'];
      case 'bengali':
        return const ['bengali', 'bangla', 'kolkata', 'rabindra'];
      case 'retro':
        return const ['retro', 'old', 'classic', 'kishore', 'asha', 'r d'];
      case 'lo fi':
        return const ['lofi', 'lo fi', 'chill', 'slowed', 'reverb'];
      case 'devotional':
        return const ['bhajan', 'devotional', 'krishna', 'shiv', 'ram'];
      case 'hip hop':
        return const ['hip hop', 'rap', 'rapper', 'gully'];
      case 'acoustic':
        return const ['acoustic', 'unplugged', 'guitar'];
      case 'classics':
        return const ['classic', 'golden', 'kishore', 'lata', 'mohammed'];
      case 'dance':
        return const ['dance', 'party', 'club', 'remix', 'beat'];
      case 'indie':
        return const ['indie', 'independent', 'prateek', 'local train'];
      case 'desi pop':
        return const ['desi', 'pop', 'bollywood', 'hindi'];
      default:
        return _normalizeCategoryText(title).split(' ');
    }
  }

  String _normalizeCategoryText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Widget _songImage(String? imageUrl) {
    final source = (imageUrl ?? '').trim();
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return AppCachedImage(url: source, fit: BoxFit.cover);
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
      child: Icon(icon, color: Colors.white, size: 64),
    );
  }

  void _playSong(BuildContext context, Song song, List<Song> queue) {
    final session = PlayerSession.instance;
    session.setQueue(queue, currentSong: song);
    session.playSong(song);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
    );
  }
}

class _CategorySongTile extends StatelessWidget {
  const _CategorySongTile({required this.song, required this.queue});

  final Song song;
  final List<Song> queue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _play(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${song.artist} • ${song.album}',
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
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
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
      return AppCachedImage(url: source, fit: BoxFit.cover);
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
      color: Colors.white.withValues(alpha: 0.13),
      child: const Icon(Icons.music_note_rounded, color: Colors.white),
    );
  }

  void _play(BuildContext context) {
    final session = PlayerSession.instance;
    session.setQueue(queue, currentSong: song);
    session.playSong(song);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: song)),
    );
  }
}
