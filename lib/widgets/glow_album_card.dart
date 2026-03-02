import 'package:flutter/material.dart';

class GlowAlbumCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const GlowAlbumCard({
    super.key,
    required this.image,
    required this.title,
    this.onTap,
    this.margin = const EdgeInsets.only(right: 16),
  });

  @override
  Widget build(BuildContext context) {
    final imageSizePx = (160 * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        margin: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Glow + Image
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.28),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  cacheWidth: imageSizePx,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.music_note,
                        size: 48,
                        color: Colors.black54,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🎵 Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
