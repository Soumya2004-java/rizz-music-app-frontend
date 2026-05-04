import 'package:flutter/material.dart';

class AppSkeletonBox extends StatefulWidget {
  const AppSkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 12,
    this.margin,
  });

  final double height;
  final double? width;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  State<AppSkeletonBox> createState() => _AppSkeletonBoxState();
}

class _AppSkeletonBoxState extends State<AppSkeletonBox>
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
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final glow = scheme.surfaceContainerHighest.withValues(alpha: 0.92);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, Color.lerp(base, glow, _controller.value)!, base],
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
    return ListView(
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
    );
  }
}

class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18, top + 20, 18, 24),
      children: const [
        AppSkeletonBox(height: 34, width: 210, radius: 10),
        SizedBox(height: 8),
        AppSkeletonBox(height: 14, width: 180, radius: 8),
        SizedBox(height: 16),
        AppSkeletonBox(height: 206, radius: 20),
        SizedBox(height: 18),
        AppSkeletonBox(height: 22, width: 160, radius: 8),
        SizedBox(height: 8),
        AppSkeletonBox(height: 12, width: 220, radius: 8),
        SizedBox(height: 8),
        AppSkeletonBox(height: 224, radius: 18),
        SizedBox(height: 14),
        AppSkeletonBox(height: 22, width: 180, radius: 8),
        SizedBox(height: 8),
        AppSkeletonBox(height: 12, width: 230, radius: 8),
        SizedBox(height: 8),
        AppSkeletonBox(height: 224, radius: 18),
      ],
    );
  }
}

class GridPageSkeleton extends StatelessWidget {
  const GridPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: const [
        AppSkeletonBox(height: 42, radius: 12),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AppSkeletonBox(height: 206, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: AppSkeletonBox(height: 206, radius: 16)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AppSkeletonBox(height: 206, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: AppSkeletonBox(height: 206, radius: 16)),
          ],
        ),
      ],
    );
  }
}

class ListPageSkeleton extends StatelessWidget {
  const ListPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }
}

class SearchPageSkeleton extends StatelessWidget {
  const SearchPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ListView(
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
    );
  }
}

class FormPageSkeleton extends StatelessWidget {
  const FormPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ListView(
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
    );
  }
}
