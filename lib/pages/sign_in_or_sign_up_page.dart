import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class SignInOrSignUp extends StatefulWidget {
  const SignInOrSignUp({super.key});

  @override
  State<SignInOrSignUp> createState() => _SignInOrSignUpState();
}

class _SignInOrSignUpState extends State<SignInOrSignUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeIn;
  late Animation<Offset> slideUp;
  late Animation<double> scaleIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(curve: Curves.easeIn, parent: _controller));

    slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(curve: Curves.easeOut, parent: _controller));

    scaleIn = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(curve: Curves.elasticOut, parent: _controller));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: fadeIn,
        child: Stack(
          children: [
            // ⭐ BACKGROUND GRADIENT
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    Colors.purple.shade900,
                    Colors.yellow.shade900,
                    Colors.red.shade200
                  ],
                ),
              ),
            ),

            // ⭐ FLOATING BLOBS ANIMATION
            const Positioned(
              right: 0,
              top: 50,
              bottom: 0,
              child: FloatingBlobs(),
            ),

            // ⭐ FLORAL DESIGN LAYER
            const Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: FloralDesign(),
            ),

            // ⭐ LOGO + TEXT
            Padding(
              padding: const EdgeInsets.only(left: 35, top: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransition(
                    position: slideUp,
                    child: const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SlideTransition(
                    position: slideUp,
                    child: const Text(
                      '"Rizz your soul with music"',
                      style: TextStyle(fontSize: 25, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            // ⭐ WHITE CONTAINER WITH BUTTONS
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: slideUp,   // 🔥 YAHI MAIN LINE HAI
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 430,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.18),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.6,
                        ),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),

                            Image.asset(
                              "assets/images/PlaygroundImage-removebg-preview.png",
                              width: 150,

                            ),

                            const SizedBox(height: 15),

                            const Text(
                              "MAKE YOUR CHOICE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 20),

                            GlowingButton(
                              text: "Login",
                              color: Colors.orange.shade900,
                              glowColor: Colors.orangeAccent,
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                            ),

                            const SizedBox(height: 25),

                            GlowingButton(
                              text: "Register",
                              color: Colors.purple.shade900,
                              glowColor: Colors.pinkAccent,
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FloralDesign extends StatelessWidget {
  const FloralDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FloralPainter(),
      child: const SizedBox(width: 200),
    );
  }
}

class FloralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.purple.shade900.withOpacity(0.4);
    canvas.drawCircle(Offset(size.width * .4, size.height * .2), 90, paint);

    paint.color = Colors.orange.shade800.withOpacity(0.4);
    canvas.drawCircle(Offset(size.width * .25, size.height * .45), 110, paint);

    paint.color = Colors.pink.shade400.withOpacity(0.4);
    canvas.drawCircle(Offset(size.width * .45, size.height * .7), 100, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FloatingBlobs extends StatefulWidget {
  const FloatingBlobs({super.key});

  @override
  State<FloatingBlobs> createState() => _FloatingBlobsState();
}

class _FloatingBlobsState extends State<FloatingBlobs>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BlobsPainter(controller.value),
          child: const SizedBox(width: 180, height: double.infinity),
        );
      },
    );
  }
}

class BlobsPainter extends CustomPainter {
  final double t;

  BlobsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = Colors.orange.withOpacity(0.25);
    canvas.drawCircle(
      Offset(
        size.width * (0.5 + 0.1 * sin(t * 2 * pi)),
        size.height * (0.3 + 0.1 * cos(t * 2 * pi)),
      ),
      80,
      paint,
    );

    paint.color = Colors.pink.withOpacity(0.25);
    canvas.drawCircle(
      Offset(
        size.width * (0.3 + 0.1 * cos(t * 2 * pi)),
        size.height * (0.6 + 0.1 * sin(t * 2 * pi)),
      ),
      70,
      paint,
    );

    paint.color = Colors.purple.withOpacity(0.25);
    canvas.drawCircle(
      Offset(
        size.width * (0.4 + 0.1 * sin(t * 2 * pi)),
        size.height * (0.8 + 0.1 * cos(t * 2 * pi)),
      ),
      90,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GlowingButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color glowColor;
  final VoidCallback onTap;

  const GlowingButton({
    super.key,
    required this.text,
    required this.color,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pressDown() => _controller.forward();

  void _pressUp() {
    _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressDown(),
      onTapUp: (_) => _pressUp(),
      onTapCancel: () => _controller.reverse(),

      child: ScaleTransition(
        scale: scale,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.7),
                blurRadius: 25,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),

          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
