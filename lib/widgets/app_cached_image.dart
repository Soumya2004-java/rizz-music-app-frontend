import 'package:flutter/material.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final normalized = url.trim();
    if (normalized.isEmpty) return const SizedBox.shrink();

    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = width == null ? null : (width! * dpr).round();
    final targetHeight = height == null ? null : (height! * dpr).round();

    final provider = ResizeImage.resizeIfNeeded(
      targetWidth,
      targetHeight,
      NetworkImage(normalized),
    );

    final image = Image(
      image: provider,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.low,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        );
      },
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  static void prefetchUrls(BuildContext context, Iterable<String> urls) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    for (final raw in urls) {
      final url = raw.trim();
      if (!url.startsWith('http')) continue;
      final provider = ResizeImage.resizeIfNeeded(
        (220 * dpr).round(),
        (220 * dpr).round(),
        NetworkImage(url),
      );
      precacheImage(provider, context);
    }
  }
}
