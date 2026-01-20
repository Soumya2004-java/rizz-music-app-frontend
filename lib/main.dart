import 'package:flutter/material.dart';
import 'package:rizzmusicapp/naviogations/tabbar.dart';
import 'package:rizzmusicapp/pages/login_page.dart';
import 'package:rizzmusicapp/pages/sign_up_page.dart';
import 'package:rizzmusicapp/views/player/player_scrreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlayerScreen(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}