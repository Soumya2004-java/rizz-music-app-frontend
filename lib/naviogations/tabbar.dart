import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rizzmusicapp/views/album_views/arijit_singh.dart';

import '../views/home.dart';
import '../views/library pages/library.dart';
import '../views/profile.dart';
import '../views/search.dart';

class Tabbars extends StatefulWidget {
  const Tabbars({super.key});

  @override
  State<Tabbars> createState() => _TabbarsState();
}

class _TabbarsState extends State<Tabbars> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    const SearchPage(),
     LibraryPage(),
    const ProfilePage(),
    const ArijitSingh()
  ];

  @override
  Widget build(BuildContext context) {
    final itemWidth =
        (MediaQuery.of(context).size.width - 28 - 24) / 4;

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              height: 72,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
              child: Stack(
                children: [
                  // 🔥 SLIDING PILL INDICATOR
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment(
                      -1 + (_currentIndex * 2 / 3),
                      0,
                    ),
                    child: Container(
                      width: itemWidth,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),

                  // 🔘 NAV ITEMS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home, 0),
                      _navItem(Icons.search, 1),
                      _navItem(Icons.library_music, 2),
                      _navItem(Icons.person, 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.18,
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: isSelected
                ? Colors.black87
                : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
