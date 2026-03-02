import 'dart:ui';
import 'package:flutter/material.dart';

import '../views/home.dart';
import '../views/library pages/library.dart';
import '../views/profile/profile.dart';
import '../views/search.dart';

class Tabbars extends StatefulWidget {
  const Tabbars({super.key});

  @override
  State<Tabbars> createState() => _TabbarsState();
}

class _TabbarsState extends State<Tabbars> {
  int _currentIndex = 0;
  int _searchTabTapCount = 0;
  bool _isTabAnimating = false;
  late final PageController _pageController;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const HomePage(),
      SearchPage(key: ValueKey(_searchTabTapCount)),
      const LibraryPage(),
      const ProfilePage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = (MediaQuery.of(context).size.width - 28 - 24) / 4;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),

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
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, 0, itemWidth),
                  _navItem(Icons.search, 1, itemWidth),
                  _navItem(Icons.library_music, 2, itemWidth),
                  _navItem(Icons.person, 3, itemWidth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, double itemWidth) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () async {
        if (_isTabAnimating && index != _currentIndex) return;

        if (index == 1 && _currentIndex == 1) {
          setState(() {
            _searchTabTapCount++;
            _screens[1] = SearchPage(key: ValueKey(_searchTabTapCount));
          });
          _pageController.jumpToPage(1);
          return;
        }

        if (index == _currentIndex) return;

        final distance = (index - _currentIndex).abs();
        if (distance > 1) {
          _pageController.jumpToPage(index);
          return;
        }

        setState(() => _isTabAnimating = true);
        await _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
        if (!mounted) return;
        setState(() => _isTabAnimating = false);
      },
      child: SizedBox(
        width: itemWidth,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: itemWidth,
            height: 54,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              size: 26,
              color: isSelected
                  ? Colors.black87
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
