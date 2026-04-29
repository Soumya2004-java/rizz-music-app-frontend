import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rizzmusicapp/firebase_options.dart';
import 'package:rizzmusicapp/naviogations/tabbar.dart';
import 'package:rizzmusicapp/pages/Login_page.dart';
import 'package:rizzmusicapp/pages/sign_in_or_sign_up_page.dart';
import 'package:rizzmusicapp/pages/sign_up_page.dart';
import 'package:rizzmusicapp/services/app_navigator.dart';
import 'package:rizzmusicapp/services/auth_store.dart';
import 'package:rizzmusicapp/theme/app_theme.dart';
import 'package:rizzmusicapp/views/player/global_mini_player.dart';
import 'package:rizzmusicapp/views/profile/settings/profile_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AuthStore.initialize();
  ProfileStore.initialize();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.rizzmusicapp.channel.audio',
    androidNotificationChannelName: 'Music Playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      navigatorObservers: [appRouteObserver],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: ValueListenableBuilder<UserAccount?>(
        valueListenable: AuthStore.currentUser,
        builder: (context, user, _) {
          if (user != null) return const Tabbars();
          return const SignInOrSignUp();
        },
      ),
      builder: (context, child) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final globalTextColor = isLight
            ? Colors.black54
            : const Color(0xFFB7BFCE);
        return Stack(
          children: [
            DefaultTextStyle.merge(
              style: TextStyle(color: globalTextColor),
              child: child ?? const SizedBox.shrink(),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: RepaintBoundary(child: GlobalMiniPlayerOverlay()),
            ),
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
