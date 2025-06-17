import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../pages/auth/login_page.dart';

class ResponsiveNavigationWrapper extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const ResponsiveNavigationWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  State<ResponsiveNavigationWrapper> createState() =>
      _ResponsiveNavigationWrapperState();
}

class _ResponsiveNavigationWrapperState
    extends State<ResponsiveNavigationWrapper> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    _authService.userStream.listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  // เมนูสำหรับลูกค้า
  List<NavigationDestination> get _customerDestinations => const [
    NavigationDestination(
      icon: Icon(Icons.search),
      selectedIcon: Icon(Icons.search),
      label: 'ค้นหาสินค้า',
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: 'ตระกร้าสินค้า',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: 'ประวัติการสั่งซื้อ',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'โปรไฟล์',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'ตั้งค่า',
    ),
  ]; // เมนูสำหรับพนักงาน
  List<NavigationDestination> get _employeeDestinations => const [
    NavigationDestination(
      icon: Icon(Icons.person_search),
      selectedIcon: Icon(Icons.person_search),
      label: 'ค้นหาลูกค้า',
    ),
    NavigationDestination(
      icon: Icon(Icons.search),
      selectedIcon: Icon(Icons.search),
      label: 'ค้นหาสินค้า',
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: 'ตระกร้าสินค้า',
    ),
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_outlined),
      selectedIcon: Icon(Icons.inventory),
      label: 'รายการสินค้า',
    ),
  ];

  // เมนูสำหรับผู้ดูแลระบบ
  List<NavigationDestination> get _adminDestinations => const [
    NavigationDestination(
      icon: Icon(Icons.admin_panel_settings),
      selectedIcon: Icon(Icons.admin_panel_settings),
      label: 'จัดการระบบ',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_outlined),
      selectedIcon: Icon(Icons.inventory),
      label: 'รายการสินค้า',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: 'จัดการลูกค้า',
    ),
    NavigationDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: 'จัดการพนักงาน',
    ),
    NavigationDestination(
      icon: Icon(Icons.storage_outlined),
      selectedIcon: Icon(Icons.storage),
      label: 'จัดการฐานข้อมูล',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'รายงาน',
    ),
  ];

  List<NavigationDestination> get _currentDestinations {
    if (_currentUser?.isAdmin == true) {
      return _adminDestinations;
    } else if (_currentUser?.isEmployee == true) {
      return _employeeDestinations;
    }
    return _customerDestinations;
  }

  // เมนูสำหรับ NavigationRail (desktop)
  List<NavigationRailDestination> get _customerRailDestinations => const [
    NavigationRailDestination(
      icon: Icon(Icons.search),
      selectedIcon: Icon(Icons.search),
      label: Text('ค้นหาสินค้า'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: Text('ตระกร้าสินค้า'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: Text('ประวัติ'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('โปรไฟล์'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('ตั้งค่า'),
    ),
  ];
  List<NavigationRailDestination> get _employeeRailDestinations => const [
    NavigationRailDestination(
      icon: Icon(Icons.person_search),
      selectedIcon: Icon(Icons.person_search),
      label: Text('ค้นหาลูกค้า'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search),
      selectedIcon: Icon(Icons.search),
      label: Text('ค้นหาสินค้า'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart),
      label: Text('ตระกร้าสินค้า'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.inventory_outlined),
      selectedIcon: Icon(Icons.inventory),
      label: Text('รายการสินค้า'),
    ),
  ];
  List<NavigationRailDestination> get _adminRailDestinations => const [
    NavigationRailDestination(
      icon: Icon(Icons.admin_panel_settings),
      selectedIcon: Icon(Icons.admin_panel_settings),
      label: Text('จัดการระบบ'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.inventory_outlined),
      selectedIcon: Icon(Icons.inventory),
      label: Text('รายการสินค้า'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: Text('จัดการลูกค้า'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: Text('จัดการพนักงาน'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.storage_outlined),
      selectedIcon: Icon(Icons.storage),
      label: Text('จัดการฐานข้อมูล'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: Text('รายงาน'),
    ),
  ];

  List<NavigationRailDestination> get _currentRailDestinations {
    if (_currentUser?.isAdmin == true) {
      return _adminRailDestinations;
    } else if (_currentUser?.isEmployee == true) {
      return _employeeRailDestinations;
    }
    return _customerRailDestinations;
  }

  void _showLoginPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentUser != null) ...[
              ListTile(
                leading: Icon(Icons.person, color: AppColors.primary),
                title: Text(_currentUser!.name),
                subtitle: Text(
                  '${_currentUser!.roleDisplayName} • ${_currentUser!.email}',
                ),
              ),
              const Divider(), // ปุ่มสลับ Role สำหรับทดสอบ
              ListTile(
                leading: Icon(Icons.swap_horiz, color: AppColors.primary),
                title: Text(_getRoleSwitchText()),
                subtitle: const Text('สำหรับทดสอบ'),
                onTap: () {
                  _authService.switchRole();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('ออกจากระบบ'),
                onTap: () {
                  _authService.logout();
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getRoleSwitchText() {
    if (_currentUser == null) return '';

    switch (_currentUser!.role) {
      case UserRole.customer:
        return 'สลับเป็น พนักงาน';
      case UserRole.employee:
        return 'สลับเป็น ผู้ดูแลระบบ';
      case UserRole.admin:
        return 'สลับเป็น ลูกค้า';
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldUseRail = ResponsiveUtils.isDesktop(context);
    final isWideScreen = ResponsiveUtils.isDesktop(context);

    if (shouldUseRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: isWideScreen,
              backgroundColor: AppColors.surface,
              selectedIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              labelType: isWideScreen
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              destinations: _currentRailDestinations,
              leading: _buildAuthButton(isVertical: true),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getContentMaxWidth(context),
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      );
    }

    // Default bottom navigation for mobile/tablet
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('SML Market'),
        actions: [_buildAuthButton(isVertical: false)],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.currentIndex,
        onDestinationSelected: widget.onDestinationSelected,
        backgroundColor: AppColors.surface,
        destinations: _currentDestinations,
      ),
    );
  }

  Widget _buildAuthButton({required bool isVertical}) {
    if (_currentUser?.isLoggedIn == true) {
      // แสดงชื่อผู้ใช้และ role
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: _showUserMenu,
          child: isVertical
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser!.name,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentUser!.roleDisplayName,
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser!.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currentUser!.roleDisplayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );
    } else {
      // แสดงปุ่ม Login
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: _showLoginPage,
          child: isVertical
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login, color: AppColors.primary),
                    const SizedBox(height: 4),
                    const Text('Login', style: TextStyle(fontSize: 10)),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Login'),
                  ],
                ),
        ),
      );
    }
  }
}
