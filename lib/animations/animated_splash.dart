// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
//
// class AnimatedSplash extends StatefulWidget {
//   const AnimatedSplash({super.key});
//
//   @override
//   State<AnimatedSplash> createState() => _AnimatedSplashState();
// }
//
// class _AnimatedSplashState extends State<AnimatedSplash>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _controller;
//   late Animation<double> fade;
//   late Animation<double> scale;
//
//   int currentImage = 0;
//   Timer? _imageTimer;
//
//   final List<String> images = [
//     "assets/images/media-result-20251129-8b092d1d-c7e1-4662-86cf-d1f6247f528d.png",
//     "assets/images/media-result-20251129-ac8cebc4-3c95-44b2-94ac-a58c1ccfd089.png",
//     "assets/images/media-result-20251129-53ea8e63-e5a6-4715-b031-458fb487eec6.png",
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//
//     fade = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//
//     scale = Tween<double>(begin: 0.9, end: 1.05).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//
//     _startAnimationLoop();
//
//     Future.delayed(const Duration(seconds: 10), () {
//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/login');
//     });
//   }
//
//   void _startAnimationLoop() {
//     _controller.forward();
//
//     _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (!mounted) return;
//
//       _controller.reverse().then((_) {
//         if (!mounted) return;
//
//         setState(() {
//           currentImage = (currentImage + 1) % images.length;
//         });
//
//         _controller.forward();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _imageTimer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.purple.shade900,
//               Colors.orange.shade800,
//               Colors.yellow.shade400,
//             ],
//           ),
//         ),
//
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // ⭐ UPPER ANIMATED IMAGES
//             Expanded(
//               flex: 6,
//               child: Center(
//                 child: AnimatedBuilder(
//                   animation: _controller,
//                   builder: (context, child) {
//                     return Opacity(
//                       opacity: fade.value,
//                       child: Transform.scale(
//                         scale: scale.value,
//                         child: Image.asset(
//                           images[currentImage],
//                           width: 390,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//
//             // ⭐ LOTTIE BELOW IMAGES
//             SizedBox(
//               height: 100,
//               child: Lottie.asset(
//                 "assets/anim/Audio Wav.json",
//                 fit: BoxFit.contain,
//               ),
//             ),
//
//             // ⭐ STATIC LOGO
//             Expanded(
//               flex: 2,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Image.asset(
//                     "assets/images/PlaygroundImage-removebg-preview.png",
//                     width: 150,
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
