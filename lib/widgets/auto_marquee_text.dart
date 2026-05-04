import 'package:flutter/material.dart';

class AutoMarqueeText extends StatefulWidget {
  const AutoMarqueeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.pause = const Duration(milliseconds: 900),
    this.pixelsPerSecond = 36,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration pause;
  final double pixelsPerSecond;

  @override
  State<AutoMarqueeText> createState() => _AutoMarqueeTextState();
}

class _AutoMarqueeTextState extends State<AutoMarqueeText> {
  final ScrollController _controller = ScrollController();
  bool _loopRunning = false;
  bool _shouldScroll = false;
  double _lastMaxWidth = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AutoMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text.trim();
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final style = widget.style ?? DefaultTextStyle.of(context).style;
        final tp = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();
        final textWidth = tp.width;
        final availableWidth = constraints.maxWidth;
        final shouldScroll = textWidth > availableWidth + 2;

        if (_shouldScroll != shouldScroll || _lastMaxWidth != availableWidth) {
          _shouldScroll = shouldScroll;
          _lastMaxWidth = availableWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !_controller.hasClients) return;
            _controller.jumpTo(0);
            _startLoopIfNeeded();
          });
        }

        if (!shouldScroll) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: widget.textAlign,
            style: style,
          );
        }

        final lineHeight = (style.height ?? 1.2) * (style.fontSize ?? 14);
        return SizedBox(
          height: lineHeight + 2,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(text, maxLines: 1, textAlign: widget.textAlign, style: style),
            ),
          ),
        );
      },
    );
  }

  void _startLoopIfNeeded() {
    if (_loopRunning || !_shouldScroll) return;
    _loopRunning = true;
    _marqueeLoop();
  }

  Future<void> _marqueeLoop() async {
    while (mounted && _shouldScroll) {
      if (!_controller.hasClients) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        continue;
      }

      final maxExtent = _controller.position.maxScrollExtent;
      if (maxExtent <= 0) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        continue;
      }

      await Future<void>.delayed(widget.pause);
      if (!mounted || !_shouldScroll || !_controller.hasClients) break;

      final ms = (maxExtent / widget.pixelsPerSecond * 1000).round().clamp(
            300,
            12000,
          );
      final duration = Duration(milliseconds: ms);

      await _controller.animateTo(maxExtent, duration: duration, curve: Curves.linear);
      if (!mounted || !_shouldScroll || !_controller.hasClients) break;
      await Future<void>.delayed(widget.pause);
      if (!mounted || !_shouldScroll || !_controller.hasClients) break;
      await _controller.animateTo(0, duration: duration, curve: Curves.linear);
    }
    _loopRunning = false;
  }
}
