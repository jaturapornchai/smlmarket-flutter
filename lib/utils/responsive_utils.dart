import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1200.0;

  // Screen type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 2; // Mobile: 2 columns
    } else if (width < tabletBreakpoint) {
      return 3; // Tablet: 3 columns
    } else if (width < desktopBreakpoint) {
      return 4; // Small desktop: 4 columns
    } else {
      return 5; // Large desktop: 5 columns
    }
  }

  // Content max width
  static double getContentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return width;
    } else if (width < tabletBreakpoint) {
      return 800.0;
    } else {
      return 1200.0;
    }
  }

  // Screen padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Font sizes
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 18.0;
    } else if (isTablet(context)) {
      return 20.0;
    } else {
      return 22.0;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 14.0;
    } else if (isTablet(context)) {
      return 15.0;
    } else {
      return 16.0;
    }
  }
}
