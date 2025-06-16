import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class ResponsiveNavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const ResponsiveNavigationWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
  });
  @override
  Widget build(BuildContext context) {
    final shouldUseRail = ResponsiveUtils.isDesktop(context);
    final isWideScreen = ResponsiveUtils.isDesktop(context);

    if (shouldUseRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: isWideScreen,
              backgroundColor: AppColors.surface,
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: isWideScreen
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.search),
                  label: Text('ค้นหา'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('โปรไฟล์'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('ตั้งค่า'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getContentMaxWidth(context),
                ),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    // Default bottom navigation for mobile/tablet
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: AppColors.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'ค้นหา',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }
}
