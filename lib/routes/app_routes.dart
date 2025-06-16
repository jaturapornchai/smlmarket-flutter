class AppRoutes {
  // ระบบฝั่งลูกค้า - Customer Side Main Menu
  static const String search = '/search'; // ค้นหา
  static const String cart = '/cart'; // ตระกร้าสินค้า
  static const String history = '/history'; // ประวัติ
  static const String profile = '/profile'; // โปรไฟล์
  static const String settings = '/settings'; // ตั้งค่า

  // ระบบฝั่งพนักงาน - Admin/Staff Side Main Menu
  static const String dashboard = '/dashboard'; // Dashboard
  static const String products = '/products'; // รายการสินค้า
  static const String orders = '/orders'; // คำสั่งซื้อ
  static const String reports = '/reports'; // รายงาน
  static const String adminProfile = '/admin-profile'; // โปรไฟล์ (Admin)
  static const String adminSettings = '/admin-settings'; // ตั้งค่า (Admin)
  // Additional routes
  static const String home = '/home';
  static const String productDetail = '/product/:id';
  static const String checkout = '/checkout';
  static const String login = '/login';
  static const String register = '/register';
  static const String orderHistory = '/order-history';

  // Route names for easy access - Customer Side
  static const String searchRoute = 'search';
  static const String cartRoute = 'cart';
  static const String historyRoute = 'history';
  static const String profileRoute = 'profile';
  static const String settingsRoute = 'settings';
  static const String homeRoute = 'home';

  // Route names for easy access - Admin Side
  static const String dashboardRoute = 'dashboard';
  static const String productsRoute = 'products';
  static const String ordersRoute = 'orders';
  static const String reportsRoute = 'reports';
  static const String adminProfileRoute = 'adminProfile';
  static const String adminSettingsRoute = 'adminSettings';

  // Additional route names
  static const String productDetailRoute = 'productDetail';
  static const String checkoutRoute = 'checkout';
  static const String loginRoute = 'login';
  static const String registerRoute = 'register';
  static const String orderHistoryRoute = 'orderHistory';
}
