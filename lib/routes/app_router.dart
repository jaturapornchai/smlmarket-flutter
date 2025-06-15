import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import 'app_routes.dart';

class AppRouter {
  static late final GoRouter _router;

  static GoRouter get router => _router;

  static void initialize() {
    _router = GoRouter(
      initialLocation: AppRoutes.search,
      routes: [
        // Main shell route with bottom navigation
        ShellRoute(
          builder: (context, state, child) {
            return MainNavigationShell(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.search,
              name: AppRoutes.searchRoute,
              builder: (context, state) => const SearchPage(),
            ),
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.homeRoute,
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              name: AppRoutes.profileRoute,
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: AppRoutes.settings,
              name: AppRoutes.settingsRoute,
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
        // Additional routes that need to be outside the main shell
        GoRoute(
          path: '/product/:id',
          name: AppRoutes.productDetailRoute,
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductDetailPage(productId: productId);
          },
        ),
        GoRoute(
          path: AppRoutes.cart,
          name: AppRoutes.cartRoute,
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: AppRoutes.checkout,
          name: AppRoutes.checkoutRoute,
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: AppRoutes.orderHistory,
          name: AppRoutes.orderHistoryRoute,
          builder: (context, state) => const OrderHistoryPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginRoute,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: AppRoutes.registerRoute,
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    );
  }
}

// Shell widget for main navigation
class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _getCurrentIndex(location),
        onTap: (index) => _onTabSelected(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[500],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'ค้นหา',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(String location) {
    switch (location) {
      case AppRoutes.search:
        return 0;
      case AppRoutes.home:
        return 1;
      case AppRoutes.profile:
        return 2;
      case AppRoutes.settings:
        return 3;
      default:
        return 0;
    }
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.search);
        break;
      case 1:
        context.go(AppRoutes.home);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }
}

// Placeholder pages - you'll need to create these if they don't exist
class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({required this.productId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สินค้า $productId')),
      body: Center(child: Text('รายละเอียดสินค้า ID: $productId')),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตรวจสอบคำสั่งซื้อ')),
      body: const Center(child: Text('หน้าตะกร้าสินค้า')),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ชำระเงิน')),
      body: const Center(child: Text('หน้าชำระเงิน')),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติการสั่งซื้อ')),
      body: const Center(child: Text('หน้าประวัติการสั่งซื้อ')),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: const Center(child: Text('หน้าเข้าสู่ระบบ')),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมัครสมาชิก')),
      body: const Center(child: Text('หน้าสมัครสมาชิก')),
    );
  }
}
