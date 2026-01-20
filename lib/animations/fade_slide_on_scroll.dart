import 'package:flutter/cupertino.dart' show Widget, ScrollController, StatefulWidget, State, RenderBox, BuildContext, Offset, MediaQuery, Curves, AnimatedSlide, AnimatedOpacity, AnimatedBuilder, StatelessWidget, EdgeInsets, TextStyle, FontWeight, Text, Padding, Transform, Opacity;
import 'package:flutter/material.dart';

class ScrollFadeTitle extends StatelessWidget {
  final String title;
  final ScrollController controller;
  final double startFade; // scroll offset start
  final double endFade;   // scroll offset end

  const ScrollFadeTitle({
    super.key,
    required this.title,
    required this.controller,
    required this.startFade,
    required this.endFade,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double offset = controller.hasClients ? controller.offset : 0;

        double opacity = 1.0;
        double translateY = 0.0;

        if (offset > startFade) {
          opacity = 1 - ((offset - startFade) / (endFade - startFade));
          opacity = opacity.clamp(0.0, 1.0);
          translateY = -(offset - startFade) * 0.2;
        }

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
