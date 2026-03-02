import 'package:flutter/material.dart';
import 'package:rizzmusicapp/pages/Login_page.dart';
import 'package:rizzmusicapp/pages/sign_in_or_sign_up_page.dart';
import 'package:rizzmusicapp/pages/sign_up_page.dart';
import 'package:rizzmusicapp/services/auth_store.dart';
import 'package:rizzmusicapp/naviogations/tabbar.dart';
import 'package:rizzmusicapp/views/player/global_mini_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ValueListenableBuilder<UserAccount?>(
        valueListenable: AuthStore.currentUser,
        builder: (context, user, _) {
          if (user != null) return const Tabbars();
          return const SignInOrSignUp();
        },
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const RepaintBoundary(child: GlobalMiniPlayerOverlay()),
          ],
        );
      },
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
