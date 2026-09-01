import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';
import '../../../music/music_repository.dart';
import '../../../songs/albums/album_page.dart';
import '../../../widgets/app_cached_image.dart';
import '../../../widgets/app_skeletons.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({super.key, this.selectedArtists = const []});

  final List<Map<String, String>> selectedArtists;

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  static const _featuredArtists = <_CuratedArtist>[
    _CuratedArtist('Arijit Singh', 'assets/images/artists/arijit_singh.png'),
    _CuratedArtist(
      'Diljit Dosanjh',
      'assets/images/artists/diljit_dosanjh.png',
    ),
    _CuratedArtist('Udit Narayan', 'assets/images/artists/udit_narayan.png'),
    _CuratedArtist(
      'Anuradha Paudwal',
      'assets/images/artists/anuradha_paudwal.png',
    ),
    _CuratedArtist(
      'Shreya Ghoshal',
      'assets/images/artists/shreya_ghoshal.png',
    ),
    _CuratedArtist('Kumar Sanu', 'assets/images/artists/kumar_sanu.png'),
  ];

  late Future<List<ArtistSummary>> _artistsFuture;

  @override
  void initState() {
    super.initState();
    _artistsFuture = MusicRepository.fetchArtists();
  }

  Future<void> _refresh() async {
    MusicRepository.clearCaches();
    setState(() {
      _artistsFuture = MusicRepository.fetchArtists();
    });
    await _artistsFuture;
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
          FutureBuilder<List<ArtistSummary>>(
            future: _artistsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const GridPageSkeleton();
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Failed to load artists: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              final libraryArtists = snapshot.data ?? const <ArtistSummary>[];
              final artistsByName = <String, ArtistSummary>{
                for (final artist in libraryArtists)
                  artist.name.trim().toLowerCase(): artist,
              };
              final artists = [
                for (final artist in _featuredArtists)
                  ArtistSummary(
                    name: artist.name,
                    imageUrl: artist.portrait,
                    songCount:
                        artistsByName[artist.name.toLowerCase()]?.songCount ??
                        0,
                  ),
                ...libraryArtists.where(
                  (artist) => !_featuredArtists.any(
                    (featured) =>
                        featured.name.toLowerCase() ==
                        artist.name.trim().toLowerCase(),
                  ),
                ),
              ];

              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      surfaceTintColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      title: const Text('Artists'),
                    ),
                    if (artists.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No artists found in Firestore',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.78,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final artist = artists[index];
                            return _artistCard(context, artist);
                          }, childCount: artists.length),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _artistCard(BuildContext context, ArtistSummary artist) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AlbumPage(artist: artist.name)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: artist.imageUrl.startsWith('http')
                          ? AppCachedImage(url: artist.imageUrl)
                          : artist.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              artist.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallback(),
                            )
                          : _fallback(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isLight ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${artist.songCount} songs',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.12),
      child: const Icon(Icons.person_rounded, color: Colors.white),
    );
  }
}

class _CuratedArtist {
  const _CuratedArtist(this.name, this.portrait);

  final String name;
  final String portrait;
}
