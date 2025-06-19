class AppRoutes {
  // 🏠 หน้าหลัก - Main Pages
  static const String home = '/'; // หน้าแรก
  static const String search = '/search'; // ค้นหาสินค้า
  static const String productDetail = '/product/:id'; // รายละเอียดสินค้า

  // 🛒 ระบบการซื้อ - Shopping System
  static const String cart = '/cart'; // ตระกร้าสินค้า
  static const String checkout = '/checkout'; // ชำระเงิน
  static const String orderSuccess = '/order-success'; // สำเร็จ

  // 📋 ประวัติและข้อมูล - History & Profile
  static const String history = '/history'; // ประวัติการซื้อ
  static const String orderHistory = '/order-history'; // ประวัติคำสั่งซื้อ
  static const String profile = '/profile'; // โปรไฟล์
  static const String settings = '/settings'; // ตั้งค่า

  // 🔐 ระบบสมาชิก - Authentication
  static const String login = '/login'; // เข้าสู่ระบบ
  static const String register = '/register'; // สมัครสมาชิก
  static const String forgot = '/forgot-password'; // ลืมรหัสผ่าน

  // 👨‍💼 ระบบผู้ดูแล - Admin System
  static const String admin = '/admin'; // หน้าหลัก Admin
  static const String adminDashboard = '/admin/dashboard'; // Dashboard
  static const String adminProducts = '/admin/products'; // จัดการสินค้า
  static const String adminOrders = '/admin/orders'; // จัดการคำสั่งซื้อ
  static const String adminCustomers = '/admin/customers'; // จัดการลูกค้า
  static const String adminEmployees = '/admin/employees'; // จัดการพนักงาน
  static const String adminReports = '/admin/reports'; // รายงาน
  static const String adminSettings = '/admin/settings'; // ตั้งค่าระบบ
  static const String adminDatabase = '/admin/database'; // จัดการฐานข้อมูล

  // 📱 Route Names สำหรับเรียกใช้ง่าย
  // Customer Routes
  static const String homeRoute = 'home';
  static const String searchRoute = 'search';
  static const String productDetailRoute = 'productDetail';
  static const String cartRoute = 'cart';
  static const String checkoutRoute = 'checkout';
  static const String orderSuccessRoute = 'orderSuccess';
  static const String historyRoute = 'history';
  static const String orderHistoryRoute = 'orderHistory';
  static const String profileRoute = 'profile';
  static const String settingsRoute = 'settings';
  static const String loginRoute = 'login';
  static const String registerRoute = 'register';
  static const String forgotRoute = 'forgot';

  // Admin Routes
  static const String adminRoute = 'admin';
  static const String adminDashboardRoute = 'adminDashboard';
  static const String adminProductsRoute = 'adminProducts';
  static const String adminOrdersRoute = 'adminOrders';
  static const String adminCustomersRoute = 'adminCustomers';
  static const String adminEmployeesRoute = 'adminEmployees';
  static const String adminReportsRoute = 'adminReports';
  static const String adminSettingsRoute = 'adminSettings';
  static const String adminDatabaseRoute = 'adminDatabase';
}
