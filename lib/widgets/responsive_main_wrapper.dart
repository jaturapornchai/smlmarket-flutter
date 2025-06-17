import 'package:flutter/material.dart';
import '../pages/misc/search_page.dart';
import '../pages/dashboard/home_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
import '../widgets/responsive_navigation.dart';

class ResponsiveMainWrapper extends StatefulWidget {
  final int initialIndex;

  const ResponsiveMainWrapper({super.key, this.initialIndex = 0});

  @override
  State<ResponsiveMainWrapper> createState() => _ResponsiveMainWrapperState();
}

class _ResponsiveMainWrapperState extends State<ResponsiveMainWrapper> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _pages = const [
    SearchPage(),
    HomePage(),
    ProfilePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigationWrapper(
      currentIndex: _currentIndex,
      onDestinationSelected: _onDestinationSelected,
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
    );
  }
}
