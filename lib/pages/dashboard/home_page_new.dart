import 'package:flutter/material.dart';
import '../../widgets/responsive_navigation.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../misc/search_page.dart';
import '../misc/cart_page.dart';
import '../misc/history_page.dart';
import '../profile/profile_page.dart';
import '../settings/settings_page.dart';
import '../customers/customer_search_page.dart';
import 'dashboard_page.dart';
import '../admin/admin_management_page.dart';
import '../products/products_page.dart';
import '../reports/reports_page.dart';
import '../customers/customer_management_page.dart';
import '../employees/employee_management_page.dart';
import '../admin/database_management_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    _authService.userStream.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          // Reset to first page when role changes
          _currentIndex = 0;
        });
      }
    });
  }

  // Customer pages
  List<Widget> get _customerPages => const [
    SearchPage(),
    CartPage(),
    HistoryPage(),
    ProfilePage(),
    SettingsPage(),
  ];
  // Employee pages
  List<Widget> get _employeePages => const [
    CustomerSearchPage(),
    SearchPage(),
    CartPage(),
    DashboardPage(),
    ProductsPage(),
  ]; // Admin pages
  List<Widget> get _adminPages => const [
    AdminManagementPage(),
    ProductsPage(),
    CustomerManagementPage(),
    EmployeeManagementPage(),
    DatabaseManagementPage(),
    ReportsPage(),
  ];

  List<Widget> get _currentPages {
    if (_currentUser?.isAdmin == true) {
      return _adminPages;
    } else if (_currentUser?.isEmployee == true) {
      return _employeePages;
    }
    return _customerPages;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure current index doesn't exceed available pages
    if (_currentIndex >= _currentPages.length) {
      _currentIndex = 0;
    }

    return ResponsiveNavigationWrapper(
      currentIndex: _currentIndex,
      onDestinationSelected: _onDestinationSelected,
      child: _currentPages[_currentIndex],
    );
  }
}
