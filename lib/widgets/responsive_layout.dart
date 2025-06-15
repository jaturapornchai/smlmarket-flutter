import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool useNavigationRail;
  final bool fullWidth; // เพิ่มตัวเลือกสำหรับ full width

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.useNavigationRail = false,
    this.fullWidth = false, // default เป็น false
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 900;

        if (isLargeScreen && useNavigationRail) {
          return Row(
            children: [
              // Navigation Rail for large screens
              NavigationRail(
                extended: constraints.maxWidth >= 1200,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.search),
                    label: Text('ค้นหา'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    label: Text('โปรไฟล์'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('ตั้งค่า'),
                  ),
                ],
                selectedIndex: 0,
                onDestinationSelected: (index) {
                  // Handle navigation
                },
              ),
              const VerticalDivider(thickness: 1, width: 1), // Main content
              Expanded(
                child: Container(
                  constraints: fullWidth
                      ? const BoxConstraints()
                      : BoxConstraints(
                          maxWidth: ResponsiveUtils.getContentMaxWidth(context),
                        ),
                  child: child,
                ),
              ),
            ],
          );
        } // Default layout for mobile/tablet
        return Container(
          constraints: fullWidth
              ? const BoxConstraints()
              : BoxConstraints(
                  maxWidth: ResponsiveUtils.getContentMaxWidth(context),
                ),
          child: child,
        );
      },
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getScreenPadding(context),
      child: child,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isTitle;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = isTitle
        ? ResponsiveUtils.getTitleFontSize(context)
        : ResponsiveUtils.getBodyFontSize(context);

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
    );
  }
}
