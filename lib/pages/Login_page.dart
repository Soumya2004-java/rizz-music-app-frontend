import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rizzmusicapp/animations/animated_text_field.dart'
    show AnimatedTextField;

import '../background/gradient_mesh_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> fadeIn;
  late Animation<Offset> slideUp;
  late Animation<double> scaleIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(curve: Curves.easeIn, parent: _controller));

    slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
      resizeToAvoidBottomInset: false,

      body: FadeTransition(
        opacity: fadeIn,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.purple.shade900,
                Colors.orange.shade800,
                Colors.pink.shade400,
              ],
            ),
          ),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            // ⭐ smooth keyboard animation
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideTransition(
                  position: slideUp,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SlideTransition(
                    position: slideUp,
                    child: Container(
                      margin: const EdgeInsets.only(top: 50),
                      decoration: const BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),

                      child: SingleChildScrollView(
                        // ⭐ FIX 2 — scroll with keyboard
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),

                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Image.asset(
                              "assets/images/PlaygroundImage-removebg-preview.png",
                              width: 110,
                            ),
                            // ⭐ Animated Inputs
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.white54,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(225, 95, 27, 0.3),
                                    blurRadius: 60,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),

                              child: Column(
                                children: const [
                                  AnimatedTextField(
                                    icon: Icons.email_outlined,
                                    hint: "Enter Email",
                                  ),
                                  SizedBox(height: 20),
                                  AnimatedTextField(
                                    icon: Icons.lock_outline,
                                    hint: "Enter Password",
                                    obscure: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ⭐ Login Button
                            ScaleTransition(
                              scale: scaleIn,
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  color: Colors.orange.shade900,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            const Text("Or Continue With"),

                            const SizedBox(height: 30),

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.blue,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Facebook",
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                Expanded(
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white70,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/images/pngwing.com-3.png",
                                        height: 80,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
