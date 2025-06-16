import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showEditProfileDialog(),
          ),
        ],
      ),
      body: ResponsiveLayout(
        fullWidth: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // User Name
                    Text(
                      'ผู้ใช้งาน',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // User Email
                    Text(
                      'user@example.com',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('คำสั่งซื้อ', '12'),
                        _buildStatCard('สินค้าโปรด', '24'),
                        _buildStatCard('คะแนน', '4.8'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Profile Menu
              _buildProfileMenu(),

              const SizedBox(height: AppSpacing.xl),

              // Account Actions
              _buildAccountActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    final menuItems = [
      ProfileMenuItem(
        icon: Icons.person_outline,
        title: 'ข้อมูลส่วนตัว',
        subtitle: 'แก้ไขข้อมูลผู้ใช้งาน',
        onTap: () => _showEditProfileDialog(),
      ),
      ProfileMenuItem(
        icon: Icons.shopping_bag_outlined,
        title: 'ประวัติการสั่งซื้อ',
        subtitle: 'ดูรายการสั่งซื้อทั้งหมด',
        onTap: () => _showOrderHistory(),
      ),
      ProfileMenuItem(
        icon: Icons.favorite_outline,
        title: 'สินค้าโปรด',
        subtitle: 'สินค้าที่คุณชื่นชอบ',
        onTap: () => _showFavorites(),
      ),
      ProfileMenuItem(
        icon: Icons.location_on_outlined,
        title: 'ที่อยู่จัดส่ง',
        subtitle: 'จัดการที่อยู่จัดส่ง',
        onTap: () => _showAddresses(),
      ),
      ProfileMenuItem(
        icon: Icons.payment_outlined,
        title: 'วิธีการชำระเงิน',
        subtitle: 'บัตรเครดิตและบัญชีธนาคาร',
        onTap: () => _showPaymentMethods(),
      ),
      ProfileMenuItem(
        icon: Icons.settings_outlined,
        title: 'การตั้งค่า',
        subtitle: 'ปรับแต่งการใช้งาน',
        onTap: () => NavigationHelper.goToSettings(context),
      ),
    ];

    return GlassmorphismCard(
      child: Column(
        children: menuItems.map((item) => _buildMenuTile(item)).toList(),
      ),
    );
  }

  Widget _buildMenuTile(ProfileMenuItem item) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(item.icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(item.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: item.onTap,
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout),
            label: const Text('ออกจากระบบ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Delete Account Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteAccountDialog(),
            icon: const Icon(Icons.delete_forever),
            label: const Text('ลบบัญชี'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขโปรไฟล์'),
        content: const Text('คุณต้องการแก้ไขข้อมูลโปรไฟล์หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('แก้ไข'),
          ),
        ],
      ),
    );
  }

  void _showOrderHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์ประวัติการสั่งซื้อยังไม่พร้อมใช้งาน'),
      ),
    );
  }

  void _showFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ฟีเจอร์สินค้าโปรดยังไม่พร้อมใช้งาน')),
    );
  }

  void _showAddresses() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ฟีเจอร์ที่อยู่จัดส่งยังไม่พร้อมใช้งาน')),
    );
  }

  void _showPaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ฟีเจอร์วิธีการชำระเงินยังไม่พร้อมใช้งาน')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              // Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ออกจากระบบเรียบร้อยแล้ว')),
              );
            },
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบบัญชี'),
        content: const Text(
          'การดำเนินการนี้ไม่สามารถยกเลิกได้ บัญชีและข้อมูลทั้งหมดจะถูกลบอย่างถาวร',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete account logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ลบบัญชีเรียบร้อยแล้ว')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบบัญชี'),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
