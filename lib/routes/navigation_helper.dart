import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

class NavigationHelper {
  // Main navigation methods
  static void goToSearch(BuildContext context) {
    context.go(AppRoutes.search);
  }

  static void goToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void goToDashboard(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void goToProfile(BuildContext context) {
    context.go(AppRoutes.profile);
  }

  static void goToSettings(BuildContext context) {
    context.go(AppRoutes.settings);
  }

  // Additional navigation methods
  static void goToProductDetail(BuildContext context, String productId) {
    context.go('/product/$productId');
  }

  static void goToCart(BuildContext context) {
    context.go(AppRoutes.cart);
  }

  static void goToCheckout(BuildContext context) {
    context.go(AppRoutes.checkout);
  }

  static void goToOrderHistory(BuildContext context) {
    context.go(AppRoutes.orderHistory);
  }

  static void goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  static void goToRegister(BuildContext context) {
    context.go(AppRoutes.register);
  }

  // Push navigation (for modal/overlay navigation)
  static void pushToProductDetail(BuildContext context, String productId) {
    context.push('/product/$productId');
  }

  static void pushToCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void pushToCheckout(BuildContext context) {
    context.push(AppRoutes.checkout);
  }

  static void pushToOrderHistory(BuildContext context) {
    context.push(AppRoutes.orderHistory);
  }

  static void pushToLogin(BuildContext context) {
    context.push(AppRoutes.login);
  }

  static void pushToRegister(BuildContext context) {
    context.push(AppRoutes.register);
  }

  // Go back
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  // Check if can go back
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }

  // Get current location
  static String getCurrentLocation(BuildContext context) {
    return GoRouterState.of(context).uri.toString();
  }

  // Check if current route matches
  static bool isCurrentRoute(BuildContext context, String route) {
    return getCurrentLocation(context) == route;
  }
}
