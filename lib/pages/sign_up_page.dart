import 'package:flutter/material.dart';
import 'package:rizzmusicapp/animations/animated_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
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

    fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(curve: Curves.easeIn, parent: _controller),
    );

    slideUp = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(curve: Curves.easeOut, parent: _controller),
    );

    scaleIn = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(curve: Curves.elasticOut, parent: _controller),
    );

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
                // ⭐ Title
                SlideTransition(
                  position: slideUp,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "REGISTER",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "NOW",
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

                // ⭐ MAIN WHITE CONTAINER
                Expanded(
                  child: SlideTransition(
                    position: slideUp,
                    child: Container(
                      margin: const EdgeInsets.only(top: 40),
                      decoration: const BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),

                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),

                            // ⭐ Logo
                            Image.asset(
                              "assets/images/PlaygroundImage-removebg-preview.png",
                              width: 110,
                            ),

                            const SizedBox(height: 25),

                            SlideTransition(
                              position: slideUp,
                              child: Container(
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
                                      icon: Icons.person,
                                      hint: "Enter Full Name",
                                    ),
                                    SizedBox(height: 20),

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
                                    SizedBox(height: 20),

                                    AnimatedTextField(
                                      icon: Icons.lock_outline,
                                      hint: "Confirm Password",
                                      obscure: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // ⭐ SIGNUP BUTTON
                            ScaleTransition(
                              scale: scaleIn,
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(horizontal: 50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  color: Colors.orange.shade900,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
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

