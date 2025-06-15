import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../utils/responsive_utils.dart';
import '../widgets/responsive_layout.dart';
import '../routes/navigation_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = ResponsiveUtils.getAppBarHeight(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveLayout(
        fullWidth: true, // ใช้ full width สำหรับหน้า Profile
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverAppBar(
              expandedHeight: appBarHeight,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary, // เพิ่ม background color
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'ผู้ใช้งาน',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'user@smlmarket.com',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ), // Profile Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedListItem(
                        index: 0,
                        child: GlassmorphismCard(
                          child: Column(
                            children: [
                              Text(
                                '12',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'สินค้า',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AnimatedListItem(
                        index: 1,
                        child: GlassmorphismCard(
                          child: Column(
                            children: [
                              Text(
                                '4.8',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'คะแนน',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AnimatedListItem(
                        index: 2,
                        child: GlassmorphismCard(
                          child: Column(
                            children: [
                              Text(
                                '₿ 2.5',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'คะแนนสะสม',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ...List.generate(
                    _menuItems.length,
                    (index) => AnimatedListItem(
                      index: index + 3,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: GlassmorphismCard(
                          onTap: () {
                            if (_menuItems[index]['title'] == 'ตั้งค่า') {
                              NavigationHelper.goToSettings(context);
                            }
                          },
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient:
                                    _menuItems[index]['gradient']
                                        as LinearGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _menuItems[index]['icon'] as IconData,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              _menuItems[index]['title'] as String,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              _menuItems[index]['subtitle'] as String,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ), // Logout Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: GradientButton(
                  text: 'ออกจากระบบ',
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
            },
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _menuItems => [
    {
      'icon': Icons.inventory_2_outlined,
      'title': 'สินค้าของฉัน',
      'subtitle': 'จัดการสินค้าในร้าน',
      'gradient': AppColors.primaryGradient,
    },
    {
      'icon': Icons.shopping_cart_outlined,
      'title': 'ประวัติการสั่งซื้อ',
      'subtitle': 'ดูรายการสั่งซื้อทั้งหมด',
      'gradient': const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
      ),
    },
    {
      'icon': Icons.favorite_outline,
      'title': 'รายการโปรด',
      'subtitle': 'สินค้าที่คุณชื่นชอบ',
      'gradient': const LinearGradient(
        colors: [Colors.pink, Colors.pinkAccent],
      ),
    },
    {
      'icon': Icons.notifications_outlined,
      'title': 'การแจ้งเตือน',
      'subtitle': 'ข้อความและการแจ้งเตือน',
      'gradient': const LinearGradient(
        colors: [Colors.orange, Colors.deepOrange],
      ),
    },
    {
      'icon': Icons.help_outline,
      'title': 'ช่วยเหลือ',
      'subtitle': 'คำถามที่พบบ่อย',
      'gradient': const LinearGradient(
        colors: [Colors.green, Colors.lightGreen],
      ),
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'ตั้งค่า',
      'subtitle': 'การตั้งค่าบัญชีและแอป',
      'gradient': const LinearGradient(
        colors: [Color(0xFFC0C0C0), Color(0xFFE5E5E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];
}
