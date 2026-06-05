import 'package:flutter/material.dart';

class AppSkeletonScope extends StatefulWidget {
  const AppSkeletonScope({super.key, required this.child});

  final Widget child;

  @override
  State<AppSkeletonScope> createState() => _AppSkeletonScopeState();
}

class _AppSkeletonScopeState extends State<AppSkeletonScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppSkeletonTicker(
      animation: _controller,
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class _AppSkeletonTicker extends InheritedWidget {
  const _AppSkeletonTicker({required this.animation, required super.child});

  final Animation<double> animation;

  static Animation<double> maybeOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_AppSkeletonTicker>()
            ?.animation ??
        const AlwaysStoppedAnimation<double>(0.5);
  }

  @override
  bool updateShouldNotify(_AppSkeletonTicker oldWidget) {
    return animation != oldWidget.animation;
  }
}

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 12,
    this.margin,
    this.child,
  });

  final double height;
  final double? width;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final animation = _AppSkeletonTicker.maybeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final glow = scheme.surfaceContainerHighest.withValues(alpha: 0.92);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(animation.value);
        final dy = -2.5 + (t * 5.0);
        return Container(
          margin: margin,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    base,
                    Color.lerp(base, glow, animation.value)!,
                    base,
                  ],
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class AppPageSkeleton extends StatelessWidget {
  const AppPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonScope(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: const [
          AppSkeletonBox(height: 34, width: 140, radius: 10),
          SizedBox(height: 10),
          AppSkeletonBox(height: 14, width: 220, radius: 8),
          SizedBox(height: 18),
          AppSkeletonBox(height: 180, radius: 22),
          SizedBox(height: 16),
          AppSkeletonBox(height: 18, width: 120, radius: 8),
          SizedBox(height: 12),
          AppSkeletonBox(height: 74, radius: 18),
          SizedBox(height: 10),
          AppSkeletonBox(height: 74, radius: 18),
          SizedBox(height: 10),
          AppSkeletonBox(height: 74, radius: 18),
        ],
      ),
    );
  }
}

class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key, this.showHeader = true});

  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final headerSkeletons = <Widget>[
      const AppSkeletonBox(height: 34, width: 220, radius: 10),
      const SizedBox(height: 8),
      const AppSkeletonBox(height: 14, width: 190, radius: 8),
      const SizedBox(height: 16),
    ];

    return AppSkeletonScope(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18, showHeader ? top + 20 : 0, 18, 24),
        children: [
          if (showHeader) ...headerSkeletons,
          const _FeaturedAlbumSkeleton(),
          const SizedBox(height: 18),
          const AppSkeletonBox(height: 22, width: 170, radius: 8),
          const SizedBox(height: 8),
          const AppSkeletonBox(height: 12, width: 220, radius: 8),
          const SizedBox(height: 12),
          const _HorizontalAlbumRowSkeleton(),
          const SizedBox(height: 14),
          const AppSkeletonBox(height: 22, width: 180, radius: 8),
          const SizedBox(height: 8),
          const AppSkeletonBox(height: 12, width: 230, radius: 8),
          const SizedBox(height: 12),
          const _HorizontalAlbumRowSkeleton(),
        ],
      ),
    );
  }
}

class GridPageSkeleton extends StatelessWidget {
  const GridPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonScope(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: const [
          AppSkeletonBox(height: 42, radius: 12, width: 120),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _AlbumGridCardSkeleton()),
              SizedBox(width: 12),
              Expanded(child: _AlbumGridCardSkeleton()),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _AlbumGridCardSkeleton()),
              SizedBox(width: 12),
              Expanded(child: _AlbumGridCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedAlbumSkeleton extends StatelessWidget {
  const _FeaturedAlbumSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      height: 206,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 140, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppSkeletonBox(height: 20, width: 170, radius: 8),
            SizedBox(height: 6),
            AppSkeletonBox(height: 12, width: 120, radius: 8),
          ],
        ),
      ),
    );
  }
}

class _HorizontalAlbumRowSkeleton extends StatelessWidget {
  const _HorizontalAlbumRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 224,
      child: Row(
        children: [
          Expanded(child: _HorizontalAlbumCardSkeleton()),
          SizedBox(width: 12),
          Expanded(child: _HorizontalAlbumCardSkeleton()),
        ],
      ),
    );
  }
}

class _HorizontalAlbumCardSkeleton extends StatelessWidget {
  const _HorizontalAlbumCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      height: 224,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppSkeletonBox(height: 142, radius: 12),
            SizedBox(height: 10),
            AppSkeletonBox(height: 14, width: 110, radius: 8),
            SizedBox(height: 4),
            AppSkeletonBox(height: 12, width: 90, radius: 8),
            SizedBox(height: 8),
            AppSkeletonBox(height: 11, width: 70, radius: 8),
          ],
        ),
      ),
    );
  }
}

class _AlbumGridCardSkeleton extends StatelessWidget {
  const _AlbumGridCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      height: 206,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppSkeletonBox(height: 118, radius: 10),
            SizedBox(height: 8),
            AppSkeletonBox(height: 14, width: 86, radius: 8),
            SizedBox(height: 4),
            AppSkeletonBox(height: 12, width: 64, radius: 8),
            SizedBox(height: 8),
            AppSkeletonBox(height: 12, width: 72, radius: 8),
          ],
        ),
      ),
    );
  }
}

class ListPageSkeleton extends StatelessWidget {
  const ListPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonScope(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: const [
          AppSkeletonBox(height: 42, radius: 12),
          SizedBox(height: 12),
          AppSkeletonBox(height: 74, radius: 14),
          SizedBox(height: 10),
          AppSkeletonBox(height: 74, radius: 14),
          SizedBox(height: 10),
          AppSkeletonBox(height: 74, radius: 14),
          SizedBox(height: 10),
          AppSkeletonBox(height: 74, radius: 14),
          SizedBox(height: 10),
          AppSkeletonBox(height: 74, radius: 14),
        ],
      ),
    );
  }
}

class SearchPageSkeleton extends StatelessWidget {
  const SearchPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AppSkeletonScope(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, top + 12, 16, 24),
        children: const [
          AppSkeletonBox(height: 28, width: 160, radius: 10),
          SizedBox(height: 12),
          AppSkeletonBox(height: 52, radius: 16),
          SizedBox(height: 12),
          AppSkeletonBox(height: 34, radius: 999),
          SizedBox(height: 18),
          AppSkeletonBox(height: 20, width: 170, radius: 8),
          SizedBox(height: 10),
          AppSkeletonBox(height: 112, radius: 16),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppSkeletonBox(height: 116, radius: 16)),
              SizedBox(width: 12),
              Expanded(child: AppSkeletonBox(height: 116, radius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class FormPageSkeleton extends StatelessWidget {
  const FormPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AppSkeletonScope(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, top + 10, 16, 24),
        children: const [
          AppSkeletonBox(height: 42, radius: 12),
          SizedBox(height: 14),
          AppSkeletonBox(height: 52, radius: 12),
          SizedBox(height: 10),
          AppSkeletonBox(height: 52, radius: 12),
          SizedBox(height: 10),
          AppSkeletonBox(height: 140, radius: 12),
          SizedBox(height: 12),
          AppSkeletonBox(height: 48, radius: 12),
        ],
      ),
    );
  }
}
