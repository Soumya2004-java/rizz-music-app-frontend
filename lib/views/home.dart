import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rizzmusicapp/views/album_views/Asha_bhosle.dart';
import 'package:rizzmusicapp/views/album_views/alka_yagnik.dart';
import 'package:rizzmusicapp/views/album_views/arijit_singh.dart';
import 'package:rizzmusicapp/views/album_views/jubin_nautiyal.dart';
import 'package:rizzmusicapp/views/album_views/kishor_kumar.dart';
import 'package:rizzmusicapp/widgets/floating_pill_glass_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _didPrecache = false;
  int _heroIndex = 0;
  Timer? _heroTimer;
  late final PageController _heroPageController;

  final List<_AlbumEntry> _topPicks = const [
    _AlbumEntry(
      title: 'Arijit Spotlight',
      subtitle: 'Soft romantic and soulful picks',
      imagePath: 'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
      pageBuilder: _arijitPage,
    ),
    _AlbumEntry(
      title: 'Asha Timeless',
      subtitle: 'Classics that never fade',
      imagePath:
          'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
      pageBuilder: _ashaPage,
    ),
    _AlbumEntry(
      title: 'Kishore Gold',
      subtitle: 'Golden era melodies',
      imagePath:
          'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
      pageBuilder: _kishorePage,
    ),
    _AlbumEntry(
      title: 'Jubin Nights',
      subtitle: 'Late night modern ballads',
      imagePath:
          'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
      pageBuilder: _jubinPage,
    ),
    _AlbumEntry(
      title: 'Alka Forever',
      subtitle: '90s and 2000s favorites',
      imagePath:
          'assets/albums/Best-Of-Alka-Yagnik-Hindi-2020-20200506121339-500x500.jpg',
      pageBuilder: _alkaPage,
    ),
  ];

  final List<_AlbumEntry> _trending = const [
    _AlbumEntry(
      title: 'Morning Boost',
      subtitle: 'Fresh, bright and uplifting',
      imagePath:
          'assets/albums/Celebrating-Shreya-Ghoshal-Hindi-2020-20200309113133-500x500.jpg',
      pageBuilder: _arijitPage,
    ),
    _AlbumEntry(
      title: 'Retro Drive',
      subtitle: 'Old-school road trip vibe',
      imagePath: 'assets/albums/51TCww-h17L._UF1000,1000_QL80_.jpg',
      pageBuilder: _kishorePage,
    ),
    _AlbumEntry(
      title: 'Love Loop',
      subtitle: 'Romantic songs for repeat',
      imagePath: 'assets/albums/ab67616d00001e026f39da36b20a464bdc28fd21.jpeg',
      pageBuilder: _jubinPage,
    ),
    _AlbumEntry(
      title: 'Chill Echoes',
      subtitle: 'Warm mellow listening',
      imagePath: 'assets/albums/images3.jpeg',
      pageBuilder: _ashaPage,
    ),
  ];

  final List<_AlbumEntry> _heroHighlights = const [
    _AlbumEntry(
      title: 'Arijit Spotlight',
      subtitle: 'Soft romantic and soulful picks',
      imagePath: 'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
      badge: 'Most Popular',
      pageBuilder: _arijitPage,
    ),
    _AlbumEntry(
      title: 'Kishore Gold',
      subtitle: 'Golden era melodies',
      imagePath:
          'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
      badge: 'Most Trending',
      pageBuilder: _kishorePage,
    ),
    _AlbumEntry(
      title: 'Jubin Nights',
      subtitle: 'Late night modern ballads',
      imagePath:
          'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
      badge: 'Top Chartbuster',
      pageBuilder: _jubinPage,
    ),
    _AlbumEntry(
      title: 'Asha Timeless',
      subtitle: 'Classics that never fade',
      imagePath:
          'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
      badge: 'Trending Classic',
      pageBuilder: _ashaPage,
    ),
    _AlbumEntry(
      title: 'Alka Forever',
      subtitle: '90s and 2000s favorites',
      imagePath:
          'assets/albums/Best-Of-Alka-Yagnik-Hindi-2020-20200506121339-500x500.jpg',
      badge: 'Fan Favorite',
      pageBuilder: _alkaPage,
    ),
  ];

  final List<_CategoryEntry> _categories = const [
    _CategoryEntry(
      title: 'Chill Lounge',
      subtitle: 'Lo-fi, mellow beats and soft textures',
      icon: Icons.nights_stay_rounded,
      colors: [Color(0xFF4F7BFF), Color(0xFF6E5BFF)],
    ),
    _CategoryEntry(
      title: 'Party Heat',
      subtitle: 'High energy drops for night drives',
      icon: Icons.local_fire_department_rounded,
      colors: [Color(0xFFFF7A59), Color(0xFFFFB257)],
    ),
    _CategoryEntry(
      title: 'Indie Fresh',
      subtitle: 'New voices and modern Indian indie',
      icon: Icons.auto_awesome_rounded,
      colors: [Color(0xFF2FB9A8), Color(0xFF6AE391)],
    ),
    _CategoryEntry(
      title: 'Retro Classics',
      subtitle: 'Timeless old songs and golden melodies',
      icon: Icons.radio_rounded,
      colors: [Color(0xFFE86A8A), Color(0xFFF3A45F)],
    ),
  ];

  final List<_AlbumEntry> _moreAlbums = const [
    _AlbumEntry(
      title: 'Arijit Spotlight',
      subtitle: 'Soft romantic and soulful picks',
      imagePath: 'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
      pageBuilder: _arijitPage,
    ),
    _AlbumEntry(
      title: 'Kishore Gold',
      subtitle: 'Golden era melodies',
      imagePath:
          'assets/albums/Best-Of-Kishore-Kumar-Hindi-1958-20240711103710-500x500.jpg',
      pageBuilder: _kishorePage,
    ),
    _AlbumEntry(
      title: 'Asha Timeless',
      subtitle: 'Classics that never fade',
      imagePath:
          'assets/albums/Asha-A-Brand-New-Album-Hindi-2018-20180514-500x500.jpg',
      pageBuilder: _ashaPage,
    ),
    _AlbumEntry(
      title: 'Jubin Nights',
      subtitle: 'Late night modern ballads',
      imagePath:
          'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
      pageBuilder: _jubinPage,
    ),
    _AlbumEntry(
      title: 'Alka Forever',
      subtitle: '90s and 2000s favorites',
      imagePath:
          'assets/albums/Best-Of-Alka-Yagnik-Hindi-2020-20200506121339-500x500.jpg',
      pageBuilder: _alkaPage,
    ),
    _AlbumEntry(
      title: 'Morning Boost',
      subtitle: 'Fresh, bright and uplifting',
      imagePath:
          'assets/albums/Celebrating-Shreya-Ghoshal-Hindi-2020-20200309113133-500x500.jpg',
      pageBuilder: _arijitPage,
    ),
    _AlbumEntry(
      title: 'Retro Drive',
      subtitle: 'Old-school road trip vibe',
      imagePath: 'assets/albums/51TCww-h17L._UF1000,1000_QL80_.jpg',
      pageBuilder: _kishorePage,
    ),
    _AlbumEntry(
      title: 'Love Loop',
      subtitle: 'Romantic songs for repeat',
      imagePath: 'assets/albums/ab67616d00001e026f39da36b20a464bdc28fd21.jpeg',
      pageBuilder: _jubinPage,
    ),
    _AlbumEntry(
      title: 'Chill Echoes',
      subtitle: 'Warm mellow listening',
      imagePath: 'assets/albums/images3.jpeg',
      pageBuilder: _ashaPage,
    ),
    _AlbumEntry(
      title: 'Rhythm Theory',
      subtitle: 'Melodic hooks with modern production',
      imagePath: 'assets/albums/images.jpeg',
      pageBuilder: _arijitPage,
    ),
    _AlbumEntry(
      title: 'Night Shift',
      subtitle: 'Moody soundscape for after-hours',
      imagePath: 'assets/albums/R-9721965-1563261058-3386.jpg',
      pageBuilder: _jubinPage,
    ),
    _AlbumEntry(
      title: 'Acoustic Breeze',
      subtitle: 'Gentle unplugged favorites',
      imagePath: 'assets/albums/images2.jpeg',
      pageBuilder: _alkaPage,
    ),
  ];

  static Widget _arijitPage() => const ArijitSingh();
  static Widget _ashaPage() => const AshaBhosle();
  static Widget _kishorePage() => const KishorKumar();
  static Widget _jubinPage() => const JubinNautiyal();
  static Widget _alkaPage() => const AlkaYagnik();

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController();
    _startHeroAutoRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    for (final album in [
      ..._topPicks,
      ..._trending,
      ..._heroHighlights,
      ..._moreAlbums,
    ]) {
      precacheImage(AssetImage(album.imagePath), context);
    }
    _didPrecache = true;
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

  void _startHeroAutoRotation() {
    if (_heroHighlights.length < 2) return;
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_heroPageController.hasClients) return;
      final nextIndex = (_heroIndex + 1) % _heroHighlights.length;
      _heroPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topInset + 12)),
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildHero(context)),
              SliverToBoxAdapter(child: _sectionTitle('Top Picks For You')),
              SliverToBoxAdapter(child: _buildTopPicks(context)),
              SliverToBoxAdapter(child: _sectionTitle('Mood Filters')),
              SliverToBoxAdapter(child: _buildMoodRow()),
              SliverToBoxAdapter(child: _sectionTitle('Trending Right Now')),
              SliverToBoxAdapter(child: _buildTrendingCapsules()),
              SliverToBoxAdapter(child: _sectionTitle('Explore Categories')),
              SliverToBoxAdapter(child: _buildCategoryShowcase()),
              SliverToBoxAdapter(child: _sectionTitle('More Albums')),
              SliverToBoxAdapter(child: _buildAppleMusicAlbumRows(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              'assets/images/PlaygroundImage-removebg-preview.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Good evening',
            style: TextStyle(
              color: Color(0xFFD8DCEB),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Find your next favorite track',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final heroAlbum = _heroHighlights[_heroIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      child: SizedBox(
        height: 196,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: PageView.builder(
                  controller: _heroPageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _heroHighlights.length,
                  onPageChanged: (index) {
                    if (!mounted || _heroIndex == index) return;
                    setState(() => _heroIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final album = _heroHighlights[index];
                    return Image.asset(
                      album.imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Column(
                        key: ValueKey(heroAlbum.title),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heroAlbum.badge ?? 'Editor\'s Spotlight',
                            style: const TextStyle(
                              color: Color(0xFFE5E8F2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            heroAlbum.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_heroHighlights.length, (index) {
                      final isActive = index == _heroIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 5),
                        width: isActive ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _openArtist(heroAlbum),
                    child: Ink(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 34,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTopPicks(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 6, 4),
        itemBuilder: (context, index) {
          final album = _topPicks[index];
          return FloatingPillGlassCard(
            image: album.imagePath,
            title: album.title,
            onTap: () => _openArtist(album),
          );
        },
        itemCount: _topPicks.length,
      ),
    );
  }

  Widget _buildMoodRow() {
    const moods = [
      ('Workout', Icons.bolt_rounded, Color(0xFFFF845F)),
      ('Focus', Icons.headset_rounded, Color(0xFF58B8FF)),
      ('Road Trip', Icons.directions_car_rounded, Color(0xFFFFC85A)),
      ('Romantic', Icons.favorite_rounded, Color(0xFFF784A9)),
      ('Retro', Icons.videocam_rounded, Color(0xFF89E2B2)),
    ];

    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final mood = moods[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF1C243F).withValues(alpha: 0.76),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(mood.$2, size: 17, color: mood.$3),
                const SizedBox(width: 8),
                Text(
                  mood.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: moods.length,
      ),
    );
  }

  Widget _buildTrendingCapsules() {
    return SizedBox(
      height: 78,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 6, 4),
        itemCount: _trending.length,
        itemBuilder: (context, index) {
          final album = _trending[index];
          return FloatingPillGlassCard(
            image: album.imagePath,
            title: album.title,
            onTap: () => _openArtist(album),
          );
        },
      ),
    );
  }

  Widget _buildCategoryShowcase() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {},
            child: Ink(
              width: 154,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 154,
                    height: 154,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          category.colors.first.withValues(alpha: 0.95),
                          category.colors.last.withValues(alpha: 0.82),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: category.colors.last.withValues(alpha: 0.3),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -18,
                          top: -18,
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              category.icon,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Text(
                            category.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppleMusicAlbumRows(BuildContext context) {
    final columnCount = (_moreAlbums.length / 3).ceil();
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        itemCount: columnCount,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, columnIndex) {
          final start = columnIndex * 3;
          final end = math.min(start + 3, _moreAlbums.length);
          final group = _moreAlbums.sublist(start, end);
          return Container(
            width: 308,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF12192B).withValues(alpha: 0.65),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: List.generate(group.length, (index) {
                final album = group[index];
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _openArtist(album),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                album.imagePath,
                                width: 62,
                                height: 62,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    album.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    album.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                      fontSize: 12.5,
                                      height: 1.2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 22,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index != group.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.12),
                          height: 1,
                          thickness: 1,
                        ),
                      ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  void _openArtist(_AlbumEntry album) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => album.pageBuilder()),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1327), Color(0xFF090B14)],
        ),
      ),
      child: Stack(
        children: [
          _blurOrb(
            alignment: const Alignment(-1.1, -0.95),
            color: const Color(0xFF59A2FF),
            size: 300,
          ),
          _blurOrb(
            alignment: const Alignment(1.05, -0.72),
            color: const Color(0xFFFF8B6A),
            size: 250,
          ),
          _blurOrb(
            alignment: const Alignment(0.8, 0.85),
            color: const Color(0xFF7F6CFF),
            size: 260,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(color: Colors.black.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb({
    required Alignment alignment,
    required Color color,
    required double size,
  }) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: math.pi / 6,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlbumEntry {
  const _AlbumEntry({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.badge,
    required this.pageBuilder,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String? badge;
  final Widget Function() pageBuilder;
}

class _CategoryEntry {
  const _CategoryEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}
