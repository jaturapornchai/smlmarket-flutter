import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double wideScreenBreakpoint = 1600;

  // Device Type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isWideScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= wideScreenBreakpoint;

  // Grid Columns
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= wideScreenBreakpoint) return 4;
    if (width >= desktopBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 3;
    if (width >= mobileBreakpoint) return 2;
    return 2;
  }

  // Padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    } else if (width >= tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    } else if (width >= mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  } // Content Max Width

  static double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= wideScreenBreakpoint) return 1400;
    if (width >= desktopBreakpoint) return 1200;
    if (width >= tabletBreakpoint) return 900;
    return double.infinity;
  }

  // Card Height
  static double getCardHeight(BuildContext context) {
    if (isMobile(context)) return 120;
    if (isTablet(context)) return 140;
    return 160;
  }

  // Font Sizes
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 24;
    return 28;
  }

  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 16;
    return 18;
  }

  // App Bar Height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) return 200;
    if (isTablet(context)) return 250;
    return 300;
  }

  // Search Bar Height
  static double getSearchBarHeight(BuildContext context) {
    if (isMobile(context)) return 90;
    if (isTablet(context)) return 100;
    return 110;
  }

  // Icon Sizes
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 24;
    if (isTablet(context)) return 28;
    return 32;
  }

  // Product Card Layout
  static double getProductImageSize(BuildContext context) {
    if (isMobile(context)) return 80;
    if (isTablet(context)) return 100;
    return 120;
  }

  // Bottom Navigation
  static bool shouldUseRail(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Adaptive Layout
  static Widget adaptiveContainer({
    required Widget child,
    required BuildContext context,
  }) {
    final maxWidth = getContentMaxWidth(context);
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }

  // Responsive Widget Builder
  static Widget responsive({
    required BuildContext context,
    Widget? mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? wideScreen,
  }) {
    if (isWideScreen(context) && wideScreen != null) return wideScreen;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile ?? Container();
  }
}
