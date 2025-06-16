import 'package:flutter/material.dart';
import '../routes/navigation_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../utils/responsive_utils.dart';
import '../widgets/responsive_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        elevation: 0,
      ),
      body: ResponsiveLayout(
        fullWidth: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สวัสดี! 👋',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'ยินดีต้อนรับสู่ Dashboard 📊',
                      style: const TextStyle(
                        color: Color(
                          0xE6FFFFFF,
                        ), // Colors.white.withOpacity(0.9)
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Dashboard Cards
              Text(
                'เมนูหลัก',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: _dashboardItems.length,
                itemBuilder: (context, index) {
                  return _buildDashboardCard(context, _dashboardItems[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, DashboardItem item) {
    return GlassmorphismCard(
      onTap: () => item.onTap(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0x331976D2), // Light blue with 20% opacity
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 32, color: item.color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Function(BuildContext) onTap;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

final List<DashboardItem> _dashboardItems = [
  DashboardItem(
    title: 'ค้นหาสินค้า',
    subtitle: 'ค้นหาและเรียกดูสินค้า',
    icon: Icons.search,
    color: AppColors.primary,
    onTap: (context) => NavigationHelper.goToSearch(context),
  ),
  DashboardItem(
    title: 'โปรไฟล์',
    subtitle: 'ข้อมูลส่วนตัว',
    icon: Icons.person,
    color: Colors.blue,
    onTap: (context) => NavigationHelper.goToProfile(context),
  ),
  DashboardItem(
    title: 'การตั้งค่า',
    subtitle: 'ปรับแต่งแอปพลิเคชัน',
    icon: Icons.settings,
    color: Colors.orange,
    onTap: (context) => NavigationHelper.goToSettings(context),
  ),
  DashboardItem(
    title: 'Log Viewer',
    subtitle: 'ดูบันทึกระบบ',
    icon: Icons.list_alt,
    color: Colors.green,
    onTap: (context) => Navigator.pushNamed(context, '/log-viewer'),
  ),
];
