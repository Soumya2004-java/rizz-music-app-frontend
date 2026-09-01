import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../background/gradient_mesh_background.dart';
import '../music/music_repository.dart';
import '../songs/albums/album_page.dart';
import '../songs/songs.dart';
import '../services/song_download_service.dart';
import '../services/youtube_playlist_service.dart';
import '../views/library pages/download/download_page.dart';
import '../views/library pages/Albums/albums_page.dart';
import '../views/library pages/Artsts/artists_page.dart';
import '../views/profile/profile.dart';
import '../views/search.dart';
import '../views/player/player_scrreen.dart';
import '../views/player/player_session.dart';
import '../views/youtube_playlist_screen.dart';
import '../widgets/app_cached_image.dart';
import '../widgets/app_skeletons.dart';
import '../widgets/neon_search_frame.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _featuredArtists = <_CuratedArtist>[
    _CuratedArtist(
      name: 'Arijit Singh',
      portrait: 'assets/images/artists/arijit_singh.png',
    ),
    _CuratedArtist(
      name: 'Diljit Dosanjh',
      portrait: 'assets/images/artists/diljit_dosanjh.png',
    ),
    _CuratedArtist(
      name: 'Udit Narayan',
      portrait: 'assets/images/artists/udit_narayan.png',
    ),
    _CuratedArtist(
      name: 'Anuradha Paudwal',
      portrait: 'assets/images/artists/anuradha_paudwal.png',
    ),
    _CuratedArtist(
      name: 'Shreya Ghoshal',
      portrait: 'assets/images/artists/shreya_ghoshal.png',
    ),
    _CuratedArtist(
      name: 'Kumar Sanu',
      portrait: 'assets/images/artists/kumar_sanu.png',
    ),
  ];

  late Future<_HomeData> _homeFuture;
  late Future<List<Song>> _browseSongsFuture;
  late Future<List<ArtistSummary>> _favoriteArtistsFuture;
  late Future<List<YouTubePlaylistItem>> _youtubePlaylistFuture;
  PageController? _featuredPageController;
  Timer? _featuredAutoPlayTimer;
  int _featuredPageIndex = 0;
  int _featuredItemCount = 0;
  int _featuredLoopStartPage = 0;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
    _browseSongsFuture = MusicRepository.fetchSongs();
    _favoriteArtistsFuture = MusicRepository.fetchArtists();
    _youtubePlaylistFuture = YouTubePlaylistService.fetchAll(
      YouTubePlaylistService.playlistId,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _homeFuture = _loadHomeData(forceRefresh: true);
      _browseSongsFuture = MusicRepository.fetchSongs();
      _favoriteArtistsFuture = MusicRepository.fetchArtists();
      _youtubePlaylistFuture = YouTubePlaylistService.fetchAll(
        YouTubePlaylistService.playlistId,
      );
    });
    await _homeFuture;
  }

  @override
  void dispose() {
    _featuredAutoPlayTimer?.cancel();
    _featuredPageController?.dispose();
    super.dispose();
  }

  Future<_HomeData> _loadHomeData({bool forceRefresh = false}) async {
    if (forceRefresh) {
      MusicRepository.clearCaches();
    }

    final isOnline = await _hasInternetConnection();
    if (!isOnline) {
      final downloads = await SongDownloadService.listDownloadedSongs();
      return _HomeData.offline(downloads);
    }

    final albums = (await MusicRepository.fetchAlbums())
        .where(_hasKnownAlbumTitle)
        .toList(growable: false);
    return _HomeData.online(albums);
  }

  bool _hasKnownAlbumTitle(AlbumSummary album) {
    final title = album.title.trim().toLowerCase();
    final normalized = title.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.isNotEmpty &&
        !const {
          'unknown',
          'unknownalbum',
          'untitled',
          'untitledalbum',
          'na',
          'none',
          'notavailable',
        }.contains(normalized);
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty &&
          result.any((address) => address.rawAddress.isNotEmpty);
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

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

  double get _backgroundTintProgress => (_scrollOffset / 260).clamp(0.0, 1.0);

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
                  colors: const [Colors.black, Colors.black],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _backgroundTintProgress,
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
          SafeArea(
            top: false,
            bottom: false,
            child: FutureBuilder<_HomeData>(
              future: _homeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _HomeHeader(
                        onProfileTap: () => _openProfile(context),
                        onNotificationsTap: () => _openNotifications(context),
                        onSearchTap: () => _openSearch(context),
                      ),
                      const Expanded(
                        child: HomePageSkeleton(showHeader: false),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Failed to load albums: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final homeData = snapshot.data;
                if (homeData == null) {
                  return const HomePageSkeleton();
                }

                if (homeData.isOffline) {
                  return _buildOfflineHome(
                    context: context,
                    downloads: homeData.downloads,
                  );
                }

                final albums = homeData.albums;
                if (albums.isEmpty) {
                  return const Center(
                    child: Text(
                      'No albums found in Firestore collection: songs',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final uniqueAlbums = _uniqueAlbums(albums);
                final featured = uniqueAlbums.take(8).toList();
                final madeForYou = uniqueAlbums.skip(8).take(10).toList();
                final trendingNow = uniqueAlbums.skip(18).take(10).toList();
                final discoverMore = uniqueAlbums.skip(28).toList();
                _syncFeaturedSlideshow(featured.length);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  AppCachedImage.prefetchUrls(
                    context,
                    albums.take(24).map((a) => a.imageUrl),
                  );
                });

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _handleScrollNotification,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _HomeHeader(
                            onProfileTap: () => _openProfile(context),
                            onNotificationsTap: () =>
                                _openNotifications(context),
                            onSearchTap: () => _openSearch(context),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _buildFeaturedSlideshow(context, featured),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate.fixed([
                            _browseSectionHeader(),
                            _buildBrowseAllGrid(),
                            const SizedBox(height: 10),
                            _youtubePlaylistEntry(context),
                            const SizedBox(height: 14),
                            _youtubePlaylistSongs(context),
                            const SizedBox(height: 14),
                            _buildFavoriteArtistsRow(),
                            const SizedBox(height: 14),
                            if (madeForYou.isNotEmpty) ...[
                              _horizontalSection(
                                context: context,
                                title: 'Made for you',
                                subtitle: 'Albums picked for your next listen',
                                albums: madeForYou,
                                onSeeAll: () => _openAllAlbums(context),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (trendingNow.isNotEmpty) ...[
                              _horizontalSection(
                                context: context,
                                title: 'Trending now',
                                subtitle: 'The albums everyone is replaying',
                                albums: trendingNow,
                                onSeeAll: () => _openAllAlbums(context),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (discoverMore.isNotEmpty)
                              _horizontalSection(
                                context: context,
                                title: 'From your favourite artists',
                                subtitle: 'More music from the voices you love',
                                albums: discoverMore,
                                onSeeAll: () => _openAllAlbums(context),
                              ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _syncFeaturedSlideshow(int itemCount) {
    if (itemCount <= 0) {
      _featuredItemCount = 0;
      _featuredPageIndex = 0;
      _featuredLoopStartPage = 0;
      _featuredAutoPlayTimer?.cancel();
      _featuredAutoPlayTimer = null;
      return;
    }

    final controller = _featuredPageController;
    if (_featuredItemCount != itemCount || controller == null) {
      _featuredItemCount = itemCount;
      _featuredPageIndex = 0;
      _featuredLoopStartPage = itemCount * 1000;
      _featuredAutoPlayTimer?.cancel();
      _featuredAutoPlayTimer = null;
      _featuredPageController?.dispose();
      _featuredPageController = PageController(
        initialPage: _featuredLoopStartPage,
        viewportFraction: 0.60,
      );
      _featuredAutoPlayTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => _advanceFeaturedSlide(),
      );
    }
  }

  List<AlbumSummary> _uniqueAlbums(List<AlbumSummary> albums) {
    final seen = <String>{};
    return albums
        .where((album) {
          final key =
              '${album.title.trim().toLowerCase()}::'
              '${album.artist.trim().toLowerCase()}';
          return seen.add(key);
        })
        .toList(growable: false);
  }

  void _advanceFeaturedSlide() {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return;

    final controller = _featuredPageController;
    if (controller == null ||
        !controller.hasClients ||
        _featuredItemCount < 2) {
      return;
    }

    final currentPage = controller.page?.round() ?? _featuredPageIndex;
    // The builder is infinite, so advancing is always one page forward. This
    // avoids the long reverse animation from the last album back to page zero.
    final nextPage = currentPage + 1;
    controller.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeInOutQuart,
    );
  }

  Widget _buildFeaturedSlideshow(
    BuildContext context,
    List<AlbumSummary> featured,
  ) {
    if (featured.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 326,
          child: PageView.builder(
            controller: _featuredPageController,
            padEnds: true,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() => _featuredPageIndex = index % featured.length);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _featuredPageController!,
                child: _staggerReveal(
                  index: index % featured.length,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 26, 8, 24),
                    child: _featuredTile(
                      context,
                      featured[index % featured.length],
                    ),
                  ),
                ),
                builder: (context, child) {
                  final controller = _featuredPageController!;
                  final page = controller.hasClients
                      ? (controller.page ?? _featuredPageIndex.toDouble())
                      : _featuredLoopStartPage.toDouble();
                  final offset = (page - index).clamp(-1.0, 1.0);
                  final distance = offset.abs();

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..translateByDouble(offset * 32.0, distance * 10.0, 0, 1)
                      ..rotateY(offset * 0.52)
                      ..scaleByDouble(
                        1 - (distance * 0.20),
                        1 - (distance * 0.20),
                        1,
                        1,
                      ),
                    child: Opacity(
                      opacity: 1 - (distance * 0.48),
                      child: child,
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        _featuredIndicator(featured.length),
      ],
    );
  }

  Widget _browseSectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore your mood',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Choose a vibe and let the music take over',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseAllGrid() {
    return FutureBuilder<List<Song>>(
      future: _browseSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final songs = snapshot.data!;
        final tileWidth = (MediaQuery.sizeOf(context).width - 44) / 2;
        final tileHeight = tileWidth / 1.05;
        return SizedBox(
          height: tileHeight + 20,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            primary: false,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 12,
              childAspectRatio: tileHeight / tileWidth,
            ),
            itemCount: 12,
            itemBuilder: (context, index) => _staggerReveal(
              index: index,
              child: BrowseGenreTile(genre: browseGenres[index], songs: songs),
            ),
          ),
        );
      },
    );
  }

  Widget _youtubePlaylistEntry(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: _PressScale(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const YouTubePlaylistScreen()),
        ),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B0A10), Color(0xFF10090E)],
            ),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF0033),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your YouTube playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Watch and play your saved mix',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _youtubePlaylistSongs(BuildContext context) {
    return FutureBuilder<List<YouTubePlaylistItem>>(
      future: _youtubePlaylistFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF0033)),
            ),
          );
        }

        final tracks = snapshot.data ?? const <YouTubePlaylistItem>[];
        if (tracks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your playlist songs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${tracks.length} songs from YouTube',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tracks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const YouTubePlaylistScreen(),
                        ),
                      ),
                      child: Ink(
                        height: 72,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: SizedBox(
                                width: 74,
                                height: 48,
                                child: track.thumbnailUrl.isEmpty
                                    ? const ColoredBox(color: Colors.white12)
                                    : Image.network(
                                        track.thumbnailUrl,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    track.channelTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Color(0xFFFF0033),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteArtistsRow() {
    return FutureBuilder<List<ArtistSummary>>(
      future: _favoriteArtistsFuture,
      builder: (context, snapshot) {
        final artistsByName = <String, ArtistSummary>{
          for (final artist in snapshot.data ?? const <ArtistSummary>[])
            artist.name.trim().toLowerCase(): artist,
        };
        final favourites = _featuredArtists
            .map(
              (artist) => ArtistSummary(
                name: artist.name,
                imageUrl: artist.portrait,
                songCount:
                    artistsByName[artist.name.toLowerCase()]?.songCount ?? 0,
              ),
            )
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your favourite artists',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Voices you love, all in one place',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ArtistPage()),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 148,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: favourites.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) =>
                    _favoriteArtistTile(context, favourites[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _favoriteArtistTile(BuildContext context, ArtistSummary artist) {
    return _PressScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumPage(artist: artist.name)),
      ),
      child: SizedBox(
        width: 94,
        child: Column(
          children: [
            Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFA5D5), Color(0xFF8BA8FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(child: _albumImage(artist.imageUrl)),
            ),
            const SizedBox(height: 7),
            Text(
              artist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (artist.songCount > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${artist.songCount} songs',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineHome({
    required BuildContext context,
    required List<DownloadedSong> downloads,
  }) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                onProfileTap: () => _openProfile(context),
                onNotificationsTap: () => _openNotifications(context),
                onSearchTap: () => _openSearch(context),
                statusLabel: 'Offline mode',
                statusSubtitle: 'Playing downloaded songs only',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                child: _offlineBanner(context, downloads.length),
              ),
            ),
            if (downloads.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No downloaded songs found on this device.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                sliver: SliverList.separated(
                  itemCount: downloads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _downloadedSongTile(
                      context,
                      downloads[index],
                      downloads,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _featuredTile(BuildContext context, AlbumSummary album) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return _PressScale(
      onTap: () => _openAlbum(context, album),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // This enlarged, blurred artwork sits behind the card, so every
          // slide gets a backlight that matches its own album colours.
          Positioned.fill(
            left: -12,
            top: -12,
            right: -12,
            bottom: -18,
            child: IgnorePointer(
              child: Opacity(
                opacity: isLight ? 0.50 : 0.70,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: _albumImage(album.imageUrl),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: _albumImage(album.imageUrl)),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.10),
                            Colors.black.withValues(alpha: 0.30),
                            Colors.black.withValues(alpha: 0.82),
                          ],
                          stops: const [0.0, 0.52, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: Row(
                      children: [
                        _tileBadge(
                          label: 'Featured',
                          icon: Icons.auto_awesome_rounded,
                        ),
                        const Spacer(),
                        _tileActionChip(
                          icon: Icons.play_arrow_rounded,
                          label: 'Play',
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isLight ? Colors.black : Colors.white,
                            fontSize: 23,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                album.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isLight
                                      ? Colors.black87
                                      : Colors.white.withValues(alpha: 0.88),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${album.trackCount} tracks',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
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
        ],
      ),
    );
  }

  Widget _featuredIndicator(int count) {
    if (count < 2) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _featuredPageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  Widget _modernAlbumTile(BuildContext context, AlbumSummary album) {
    return _PressScale(
      onTap: () => _openAlbum(context, album),
      child: RepaintBoundary(
        child: Container(
          width: 156,
          height: 212,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(child: _albumImage(album.imageUrl)),
                Positioned(
                  left: -22,
                  top: -30,
                  child: IgnorePointer(
                    child: Container(
                      width: 126,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.04),
                          Colors.black.withValues(alpha: 0.20),
                          Colors.black.withValues(alpha: 0.88),
                        ],
                        stops: const [0.0, 0.58, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _tileActionChip(
                    icon: Icons.album_rounded,
                    label: '${album.trackCount}',
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.35,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        album.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 11.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tileBadge({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileActionChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _horizontalSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<AlbumSummary> albums,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 232,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _staggerReveal(
                index: index,
                child: _modernAlbumTile(context, albums[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _offlineBanner(BuildContext context, int downloadCount) {
    final hasDownloads = downloadCount > 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasDownloads ? Icons.download_done_rounded : Icons.cloud_off,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Downloaded Songs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDownloads
                          ? '$downloadCount saved tracks are ready to play offline'
                          : 'No saved tracks yet. Download songs while you are online.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => _openDownloadedSongs(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Open'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _downloadedSongTile(
    BuildContext context,
    DownloadedSong song,
    List<DownloadedSong> downloads,
  ) {
    return _PressScale(
      onTap: () => _playDownloadedSong(context, song, downloads),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.08),
                  const Color(0xFF9BB7D7).withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: _downloadedCover(song),
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _miniPill(Icons.download_done_rounded, 'Downloaded'),
                          _miniPill(Icons.offline_bolt_rounded, 'Offline'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.24),
                        Colors.white.withValues(alpha: 0.10),
                      ],
                    ),
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

  Widget _miniPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.82)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadedCover(DownloadedSong song) {
    final localCoverPath = (song.localCoverPath ?? '').trim();
    if (localCoverPath.isNotEmpty &&
        !localCoverPath.startsWith('assets/') &&
        File(localCoverPath).existsSync()) {
      return Image.file(
        File(localCoverPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _downloadFallback(),
      );
    }

    if (localCoverPath.startsWith('assets/')) {
      return Image.asset(
        localCoverPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _downloadFallback(),
      );
    }

    final cover = (song.coverUrl ?? '').trim();
    if (cover.startsWith('http://') || cover.startsWith('https://')) {
      return Image.network(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _downloadFallback(),
      );
    }

    if (cover.isNotEmpty) {
      return Image.asset(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _downloadFallback(),
      );
    }

    return _downloadFallback();
  }

  Widget _downloadFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.download_done_rounded, color: Colors.white70),
    );
  }

  Widget _albumImage(String imageUrl) {
    final source = imageUrl.trim();

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return AppCachedImage(url: source, fit: BoxFit.cover);
    }

    if (source.isNotEmpty) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _albumFallback(),
      );
    }

    return _albumFallback();
  }

  Widget _albumFallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: const Icon(Icons.album_rounded, color: Colors.white70, size: 30),
    );
  }

  Widget _staggerReveal({required int index, required Widget child}) {
    final delay = (index * 40).clamp(0, 320);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, builtChild) {
        final t = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: builtChild,
          ),
        );
      },
      child: child,
    );
  }

  void _openAlbum(BuildContext context, AlbumSummary album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumPage(
          artist: album.artist,
          albumTitle: album.title,
          albumCover: album.imageUrl,
        ),
      ),
    );
  }

  void _openAllAlbums(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlbumsPage()),
    );
  }

  void _openDownloadedSongs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DownloadPage()),
    );
  }

  void _playDownloadedSong(
    BuildContext context,
    DownloadedSong song,
    List<DownloadedSong> downloads,
  ) {
    final queue = downloads
        .map(SongDownloadService.toPlayableSong)
        .toList(growable: false);
    final current = SongDownloadService.toPlayableSong(song);
    final session = PlayerSession.instance;
    session.setQueue(queue, currentSong: current);
    session.playSong(current);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(song: current)),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111318),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _notificationTile(
                  icon: Icons.new_releases_rounded,
                  title: 'New releases available',
                  subtitle: 'Fresh tracks were added to your library.',
                ),
                _notificationTile(
                  icon: Icons.album_rounded,
                  title: 'Albums updated',
                  subtitle: 'Some albums now include extra tracks.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _notificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _CuratedArtist {
  const _CuratedArtist({required this.name, required this.portrait});

  final String name;
  final String portrait;
}

class _HomeData {
  const _HomeData._({
    required this.isOffline,
    required this.albums,
    required this.downloads,
  });

  const _HomeData.online(List<AlbumSummary> albums)
    : this._(isOffline: false, albums: albums, downloads: const []);

  const _HomeData.offline(List<DownloadedSong> downloads)
    : this._(isOffline: true, albums: const [], downloads: downloads);

  final bool isOffline;
  final List<AlbumSummary> albums;
  final List<DownloadedSong> downloads;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onProfileTap,
    required this.onNotificationsTap,
    required this.onSearchTap,
    this.statusLabel,
    this.statusSubtitle,
  });

  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSearchTap;
  final String? statusLabel;
  final String? statusSubtitle;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topInset + 10, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${_greetingForNow()}  ✦',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.caveat(
                        color: Colors.white,
                        fontSize: 29,
                        height: 1.05,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statusSubtitle ?? 'Pick up where you left off',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    if (statusLabel != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Text(
                          statusLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _IconBubble(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationsTap,
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(999),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _HomeSearchBar(onTap: onSearchTap),
        ],
      ),
    );
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 22) return 'Good Evening';
    return 'Good Night';
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeonSearchFrame(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.5),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Colors.white),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Search songs, artists, albums',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
