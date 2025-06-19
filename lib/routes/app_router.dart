import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Customer/User pages
import '../pages/misc/search_page.dart';
import '../pages/misc/cart_page.dart';
import '../pages/misc/history_page.dart';
import '../pages/misc/product_detail_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
// Admin/Staff pages
import '../pages/dashboard/dashboard_page.dart';
import '../pages/products/products_page.dart';
import '../pages/orders/orders_page.dart';
import '../pages/reports/reports_page.dart';
import '../pages/admin/admin_management_page.dart';
import '../pages/admin/database_management_page.dart';
import '../pages/customers/customer_management_page.dart';
import '../pages/employees/employee_management_page.dart';
import 'app_routes.dart';

class AppRouter {
  static late final GoRouter _router;

  static GoRouter get router => _router;

  static void initialize() {
    _router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        // 🏠 ระบบลูกค้า - Customer System with Bottom Navigation
        ShellRoute(
          builder: (context, state, child) {
            return CustomerNavigationShell(child: child);
          },
          routes: [
            // หน้าหลัก
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.homeRoute,
              builder: (context, state) => const HomePage(),
            ),
            // ค้นหาสินค้า
            GoRoute(
              path: AppRoutes.search,
              name: AppRoutes.searchRoute,
              builder: (context, state) => const SearchPage(),
            ),
            // ตระกร้าสินค้า
            GoRoute(
              path: AppRoutes.cart,
              name: AppRoutes.cartRoute,
              builder: (context, state) => const CartPage(),
            ),
            // ประวัติ
            GoRoute(
              path: AppRoutes.history,
              name: AppRoutes.historyRoute,
              builder: (context, state) => const HistoryPage(),
            ),
            // โปรไฟล์
            GoRoute(
              path: AppRoutes.profile,
              name: AppRoutes.profileRoute,
              builder: (context, state) => const ProfilePage(),
            ),
            // รายละเอียดสินค้า (มี Bottom Navigation)
            GoRoute(
              path: AppRoutes.productDetail,
              name: AppRoutes.productDetailRoute,
              builder: (context, state) {
                final productId = state.pathParameters['id']!;
                return ProductDetailPage(productId: productId);
              },
            ),
          ],
        ),

        // 👨‍💼 ระบบผู้ดูแล - Admin System with Navigation
        ShellRoute(
          builder: (context, state, child) {
            return AdminNavigationShell(child: child);
          },
          routes: [
            // Admin Dashboard
            GoRoute(
              path: AppRoutes.adminDashboard,
              name: AppRoutes.adminDashboardRoute,
              builder: (context, state) => const DashboardPage(),
            ),
            // จัดการสินค้า
            GoRoute(
              path: AppRoutes.adminProducts,
              name: AppRoutes.adminProductsRoute,
              builder: (context, state) => const ProductsPage(),
            ),
            // จัดการคำสั่งซื้อ
            GoRoute(
              path: AppRoutes.adminOrders,
              name: AppRoutes.adminOrdersRoute,
              builder: (context, state) => const OrdersPage(),
            ),
            // จัดการลูกค้า
            GoRoute(
              path: AppRoutes.adminCustomers,
              name: AppRoutes.adminCustomersRoute,
              builder: (context, state) => const CustomerManagementPage(),
            ),
            // จัดการพนักงาน
            GoRoute(
              path: AppRoutes.adminEmployees,
              name: AppRoutes.adminEmployeesRoute,
              builder: (context, state) => const EmployeeManagementPage(),
            ),
            // รายงาน
            GoRoute(
              path: AppRoutes.adminReports,
              name: AppRoutes.adminReportsRoute,
              builder: (context, state) => const ReportsPage(),
            ),
            // ตั้งค่าระบบ
            GoRoute(
              path: AppRoutes.adminSettings,
              name: AppRoutes.adminSettingsRoute,
              builder: (context, state) => const AdminManagementPage(),
            ),
            // จัดการฐานข้อมูล
            GoRoute(
              path: AppRoutes.adminDatabase,
              name: AppRoutes.adminDatabaseRoute,
              builder: (context, state) => const DatabaseManagementPage(),
            ),
          ],
        ),

        // 🔐 หน้าแยกต่างหาก - Standalone Pages (ไม่มี Navigation)
        // ชำระเงิน
        GoRoute(
          path: AppRoutes.checkout,
          name: AppRoutes.checkoutRoute,
          builder: (context, state) => const CheckoutPage(),
        ),
        // สำเร็จ
        GoRoute(
          path: AppRoutes.orderSuccess,
          name: AppRoutes.orderSuccessRoute,
          builder: (context, state) => const OrderSuccessPage(),
        ),
        // เข้าสู่ระบบ
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginRoute,
          builder: (context, state) => const LoginPage(),
        ),
        // สมัครสมาชิก
        GoRoute(
          path: AppRoutes.register,
          name: AppRoutes.registerRoute,
          builder: (context, state) => const RegisterPage(),
        ),
        // ลืมรหัสผ่าน
        GoRoute(
          path: AppRoutes.forgot,
          name: AppRoutes.forgotRoute,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        // ตั้งค่า
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settingsRoute,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
  }
}

// 🏠 Customer Navigation Shell - เมนูลูกค้าแบบ Bottom Navigation
class CustomerNavigationShell extends StatelessWidget {
  final Widget child;

  const CustomerNavigationShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildCustomerBottomNavigation(context),
    );
  }

  Widget _buildCustomerBottomNavigation(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _getCustomerCurrentIndex(location),
        onTap: (index) => _onCustomerTabSelected(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 10,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'ค้นหา',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'ตระกร้า',
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
        ],
      ),
    );
  }

  int _getCustomerCurrentIndex(String location) {
    if (location == AppRoutes.home || location.startsWith('/product/'))
      return 0;
    if (location == AppRoutes.search) return 1;
    if (location == AppRoutes.cart) return 2;
    if (location == AppRoutes.history) return 3;
    if (location == AppRoutes.profile) return 4;
    return 0;
  }

  void _onCustomerTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.search);
        break;
      case 2:
        context.go(AppRoutes.cart);
        break;
      case 3:
        context.go(AppRoutes.history);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }
}

// 👨‍💼 Admin Navigation Shell - เมนู Admin แบบ Drawer + Bottom
class AdminNavigationShell extends StatelessWidget {
  final Widget child;

  const AdminNavigationShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ระบบผู้ดูแล'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(AppRoutes.home),
            tooltip: 'กลับสู่ระบบลูกค้า',
          ),
        ],
      ),
      drawer: _buildAdminDrawer(context),
      body: child,
      bottomNavigationBar: _buildAdminBottomNavigation(context),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange[600]),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  'ระบบผู้ดูแล',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'SML Market',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.dashboard,
            'Dashboard',
            AppRoutes.adminDashboard,
          ),
          _buildDrawerItem(
            context,
            Icons.inventory,
            'จัดการสินค้า',
            AppRoutes.adminProducts,
          ),
          _buildDrawerItem(
            context,
            Icons.receipt_long,
            'จัดการคำสั่งซื้อ',
            AppRoutes.adminOrders,
          ),
          _buildDrawerItem(
            context,
            Icons.people,
            'จัดการลูกค้า',
            AppRoutes.adminCustomers,
          ),
          _buildDrawerItem(
            context,
            Icons.group,
            'จัดการพนักงาน',
            AppRoutes.adminEmployees,
          ),
          _buildDrawerItem(
            context,
            Icons.bar_chart,
            'รายงาน',
            AppRoutes.adminReports,
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            Icons.settings,
            'ตั้งค่าระบบ',
            AppRoutes.adminSettings,
          ),
          _buildDrawerItem(
            context,
            Icons.storage,
            'จัดการฐานข้อมูล',
            AppRoutes.adminDatabase,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isSelected = currentLocation == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.orange[600] : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.orange[600] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.orange[50],
      onTap: () {
        Navigator.pop(context); // ปิด Drawer
        context.go(route);
      },
    );
  }

  Widget _buildAdminBottomNavigation(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _getAdminCurrentIndex(location),
        onTap: (index) => _onAdminTabSelected(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange[600],
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 11,
        unselectedFontSize: 9,
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
            label: 'สินค้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'คำสั่งซื้อ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'ลูกค้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'เพิ่มเติม',
          ),
        ],
      ),
    );
  }

  int _getAdminCurrentIndex(String location) {
    switch (location) {
      case AppRoutes.adminDashboard:
        return 0;
      case AppRoutes.adminProducts:
        return 1;
      case AppRoutes.adminOrders:
        return 2;
      case AppRoutes.adminCustomers:
        return 3;
      default:
        return 4; // เพิ่มเติม
    }
  }

  void _onAdminTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.adminDashboard);
        break;
      case 1:
        context.go(AppRoutes.adminProducts);
        break;
      case 2:
        context.go(AppRoutes.adminOrders);
        break;
      case 3:
        context.go(AppRoutes.adminCustomers);
        break;
      case 4:
        // เปิด Drawer สำหรับเมนูเพิ่มเติม
        Scaffold.of(context).openDrawer();
        break;
    }
  }
}

// 🏠 หน้าแรก - Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SML Market'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => context.go(AppRoutes.adminDashboard),
            tooltip: 'ระบบผู้ดูแล',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
            tooltip: 'ตั้งค่า',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ยินดีต้อนรับสู่',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Text(
                    'SML Market',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ค้นหาสินค้าคุณภาพดี ราคาเป็นกันเอง',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.search),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[600],
                    ),
                    child: const Text('เริ่มค้นหาสินค้า'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'เมนูหลัก',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  context,
                  Icons.search,
                  'ค้นหาสินค้า',
                  'ค้นหาสินค้าที่ต้องการ',
                  Colors.green,
                  () => context.go(AppRoutes.search),
                ),
                _buildQuickActionCard(
                  context,
                  Icons.shopping_cart,
                  'ตระกร้าสินค้า',
                  'ดูสินค้าในตระกร้า',
                  Colors.orange,
                  () => context.go(AppRoutes.cart),
                ),
                _buildQuickActionCard(
                  context,
                  Icons.history,
                  'ประวัติการซื้อ',
                  'ดูประวัติการซื้อ',
                  Colors.purple,
                  () => context.go(AppRoutes.history),
                ),
                _buildQuickActionCard(
                  context,
                  Icons.person,
                  'โปรไฟล์',
                  'จัดการข้อมูลส่วนตัว',
                  Colors.red,
                  () => context.go(AppRoutes.profile),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 📄 Placeholder Pages สำหรับหน้าที่ยังไม่มี
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงิน'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'หน้าชำระเงิน',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('อยู่ระหว่างการพัฒนา'),
          ],
        ),
      ),
    );
  }
}

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สำเร็จ'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'สั่งซื้อสำเร็จ!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('ขอบคุณที่ใช้บริการ'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('กลับหน้าหลัก'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'หน้าเข้าสู่ระบบ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('อยู่ระหว่างการพัฒนา'),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'หน้าสมัครสมาชิก',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('อยู่ระหว่างการพัฒนา'),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลืมรหัสผ่าน'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_reset, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'หน้าลืมรหัสผ่าน',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('อยู่ระหว่างการพัฒนา'),
          ],
        ),
      ),
    );
  }
}
