import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/app_navigator.dart';
import '../services/tabbar_visibility.dart';
import '../views/home.dart';
import '../views/library pages/library.dart';
import '../views/profile/profile.dart';
import '../views/search.dart';

class Tabbars extends StatefulWidget {
  const Tabbars({super.key});

  @override
  State<Tabbars> createState() => _TabbarsState();
}

class _TabbarsState extends State<Tabbars> with RouteAware {
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
    tabBarVisibleNotifier.value = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
      tabBarVisibleNotifier.value = route.isCurrent;
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    tabBarVisibleNotifier.value = false;
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    tabBarVisibleNotifier.value = true;
  }

  @override
  void didPopNext() {
    tabBarVisibleNotifier.value = true;
  }

  @override
  void didPushNext() {
    tabBarVisibleNotifier.value = false;
  }

  @override
  void didPop() {
    tabBarVisibleNotifier.value = false;
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
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              height: 68,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    const Color(0xFFB8D3F0).withValues(alpha: 0.18),
                    const Color(0xFF9DB5D6).withValues(alpha: 0.14),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.36),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -12,
                    child: Container(
                      width: 120,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.34),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(Icons.home, 0, itemWidth),
                      _navItem(Icons.search, 1, itemWidth),
                      _navItem(Icons.library_music, 2, itemWidth),
                      _navItem(Icons.person, 3, itemWidth),
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
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.38)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: isSelected
                  ? Border.all(color: Colors.white.withValues(alpha: 0.42))
                  : null,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF10151D)
                  : Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}
