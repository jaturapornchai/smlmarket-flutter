import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';
import '../../widgets/responsive_layout.dart';
import '../../routes/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              _showSwitchToCustomerDialog(context);
            },
            tooltip: 'สลับโหมดลูกค้า',
          ),
        ],
      ),
      body: ResponsiveLayout(
        fullWidth: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
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
                    const Icon(Icons.dashboard, color: Colors.white, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'แดชบอร์ดพนักงาน',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'จัดการระบบและดูข้อมูลภาพรวม',
                      style: TextStyle(
                        color: Color(
                          0xE6FFFFFF,
                        ), // Colors.white with 90% opacity
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Stats Cards
              Text(
                'สถิติวันนี้',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    'คำสั่งซื้อใหม่',
                    '25',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    'รายได้วันนี้',
                    '฿12,500',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'สินค้าขายดี',
                    '45',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    'ลูกค้าใหม่',
                    '8',
                    Icons.person_add,
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Quick Actions
              Text(
                'การจัดการด่วน',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    context,
                    'จัดการสินค้า',
                    'เพิ่ม แก้ไข ลบสินค้า',
                    Icons.inventory,
                    Colors.blue,
                    () => _navigateToProducts(context),
                  ),
                  _buildActionCard(
                    context,
                    'คำสั่งซื้อ',
                    'ดูและจัดการคำสั่งซื้อ',
                    Icons.list_alt,
                    Colors.green,
                    () => _navigateToOrders(context),
                  ),
                  _buildActionCard(
                    context,
                    'รายงาน',
                    'ดูรายงานและสถิติ',
                    Icons.bar_chart,
                    Colors.orange,
                    () => _navigateToReports(context),
                  ),
                  _buildActionCard(
                    context,
                    'ตั้งค่า',
                    'ตั้งค่าระบบ',
                    Icons.settings,
                    Colors.grey,
                    () => _navigateToSettings(context),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Recent Orders
              Text(
                'คำสั่งซื้อล่าสุด',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),

              GlassmorphismCard(
                child: Column(
                  children: [
                    ...List.generate(
                      3,
                      (index) => _buildOrderItem(
                        context,
                        'ORD${(100 + index).toString().padLeft(3, '0')}',
                        'ลูกค้า ${index + 1}',
                        '฿${(1500 + index * 250)}',
                        index == 0
                            ? 'รอดำเนินการ'
                            : index == 1
                            ? 'กำลังเตรียม'
                            : 'จัดส่งแล้ว',
                        index == 0
                            ? Colors.orange
                            : index == 1
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Color.fromARGB(
                  51,
                  (color.r * 255).round(),
                  (color.g * 255).round(),
                  (color.b * 255).round(),
                ), // 20% opacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassmorphismCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    51,
                    (color.r * 255).round(),
                    (color.g * 255).round(),
                    (color.b * 255).round(),
                  ), // 20% opacity
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    String orderId,
    String customer,
    String amount,
    String status,
    Color statusColor,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0x1A1976D2), // Light blue with 10% opacity
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.shopping_bag,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(orderId, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(customer),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color.fromARGB(
                51,
                (statusColor.r * 255).round(),
                (statusColor.g * 255).round(),
                (statusColor.b * 255).round(),
              ), // 20% opacity
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProducts(BuildContext context) {
    Navigator.pushNamed(context, '/products');
  }

  void _navigateToOrders(BuildContext context) {
    Navigator.pushNamed(context, '/orders');
  }

  void _navigateToReports(BuildContext context) {
    Navigator.pushNamed(context, '/reports');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/admin-settings');
  }

  static void _showSwitchToCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยนเป็นโหมดลูกค้า'),
        content: const Text(
          'คุณต้องการออกจากระบบจัดการและกลับเป็นลูกค้าหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.search);
            },
            child: const Text('เปลี่ยนโหมด'),
          ),
        ],
      ),
    );
  }
}
