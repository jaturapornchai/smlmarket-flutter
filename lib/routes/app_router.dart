import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/misc/search_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/misc/history_page.dart';
import '../pages/misc/cart_page.dart';
import '../pages/dashboard/dashboard_page.dart';
import '../pages/products/products_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/reports/reports_page.dart';
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
              path: AppRoutes.cart,
              name: AppRoutes.cartRoute,
              builder: (context, state) => const CartPage(),
            ),
            GoRoute(
              path: AppRoutes.history,
              name: AppRoutes.historyRoute,
              builder: (context, state) => const HistoryPage(),
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
        // Admin/Staff shell route with admin navigation
        ShellRoute(
          builder: (context, state, child) {
            return AdminNavigationShell(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              name: AppRoutes.dashboardRoute,
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: AppRoutes.products,
              name: AppRoutes.productsRoute,
              builder: (context, state) => const ProductsPage(),
            ),
            GoRoute(
              path: AppRoutes.orders,
              name: AppRoutes.ordersRoute,
              builder: (context, state) => const OrdersPage(),
            ),
            GoRoute(
              path: AppRoutes.reports,
              name: AppRoutes.reportsRoute,
              builder: (context, state) => const ReportsPage(),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A9E9E9E), // Colors.grey.withOpacity(0.1)
            blurRadius: 10,
            offset: Offset(0, -3),
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
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'ตระกร้าสินค้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'ประวัติ',
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
      case AppRoutes.cart:
        return 1;
      case AppRoutes.history:
        return 2;
      case AppRoutes.profile:
        return 3;
      case AppRoutes.settings:
        return 4;
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
        context.go(AppRoutes.cart);
        break;
      case 2:
        context.go(AppRoutes.history);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
      case 4:
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

// Admin/Staff navigation shell
class AdminNavigationShell extends StatelessWidget {
  final Widget child;

  const AdminNavigationShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildAdminBottomNavigation(context),
    );
  }

  Widget _buildAdminBottomNavigation(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A9E9E9E), // Colors.grey.withOpacity(0.1)
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _getAdminCurrentIndex(location),
        onTap: (index) => _onAdminTabSelected(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange[600],
        unselectedItemColor: Colors.grey[500],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            activeIcon: Icon(Icons.inventory),
            label: 'รายการสินค้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'คำสั่งซื้อ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'รายงาน',
          ),
        ],
      ),
    );
  }

  int _getAdminCurrentIndex(String location) {
    switch (location) {
      case AppRoutes.dashboard:
        return 0;
      case AppRoutes.products:
        return 1;
      case AppRoutes.orders:
        return 2;
      case AppRoutes.reports:
        return 3;
      default:
        return 0;
    }
  }

  void _onAdminTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.products);
        break;
      case 2:
        context.go(AppRoutes.orders);
        break;
      case 3:
        context.go(AppRoutes.reports);
        break;
    }
  }
}
