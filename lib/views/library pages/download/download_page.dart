import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../background/gradient_mesh_background.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  static const List<Map<String, String>> _downloadedAlbums = [
    {
      'title': 'Hits of Arijit',
      'artist': 'Arijit Singh',
      'cover': 'assets/albums/ab67616d0000b273627b5b17cb48f6e6956b842e.jpeg',
      'tracks': '24 tracks',
      'size': '162 MB',
    },
    {
      'title': 'Hits of Sonu',
      'artist': 'Sonu Nigam',
      'cover':
          'assets/albums/Sonu-Nigam-Love-Stories-Hindi-2021-20210721001549-500x500.jpg',
      'tracks': '18 tracks',
      'size': '128 MB',
    },
    {
      'title': 'Shreya Essentials',
      'artist': 'Shreya Ghoshal',
      'cover':
          'assets/albums/Celebrating-Shreya-Ghoshal-Hindi-2020-20200309113133-500x500.jpg',
      'tracks': '20 tracks',
      'size': '141 MB',
    },
    {
      'title': 'Jubin Love Stories',
      'artist': 'Jubin Nautiyal',
      'cover':
          'assets/albums/Best-Of-Jubin-Nautiyal-Hindi-2023-20230704125346-500x500.jpg',
      'tracks': '16 tracks',
      'size': '109 MB',
    },
  ];

  Widget _summaryCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              _statItem('Albums', _downloadedAlbums.length.toString()),
              _divider(),
              _statItem(
                'Tracks',
                _downloadedAlbums
                    .map(
                      (e) => int.tryParse(e['tracks']!.split(' ').first) ?? 0,
                    )
                    .fold<int>(0, (a, b) => a + b)
                    .toString(),
              ),
              _divider(),
              _statItem('Offline', 'Ready'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }

  Widget _albumCard(Map<String, String> album) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.17)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    album['cover']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white.withValues(alpha: 0.16),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                album['title']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                album['artist']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: _metaPill(Icons.sd_storage_rounded, album['size']!),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _metaPill(
                      Icons.library_music_rounded,
                      album['tracks']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.82)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
                expandedHeight: 172,
                backgroundColor: Colors.black.withValues(alpha: 0.16),
                elevation: 0,
                title: const Text(
                  'Downloads',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 86, 16, 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _summaryCard(),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Downloaded Albums',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.56,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _albumCard(_downloadedAlbums[index]),
                    childCount: _downloadedAlbums.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }
}
