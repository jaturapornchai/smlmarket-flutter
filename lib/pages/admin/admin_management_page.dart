import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'จัดการระบบ',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildManagementCard(
                      icon: Icons.inventory,
                      title: 'จัดการสินค้า',
                      subtitle: 'เพิ่ม แก้ไข ลบสินค้า',
                      onTap: () => _navigateToProducts(),
                    ),
                    _buildManagementCard(
                      icon: Icons.people,
                      title: 'จัดการลูกค้า',
                      subtitle: 'ข้อมูลและประวัติลูกค้า',
                      onTap: () => _navigateToCustomers(),
                    ),
                    _buildManagementCard(
                      icon: Icons.group,
                      title: 'จัดการพนักงาน',
                      subtitle: 'เพิ่ม แก้ไข สิทธิ์พนักงาน',
                      onTap: () => _navigateToEmployees(),
                    ),
                    _buildManagementCard(
                      icon: Icons.analytics,
                      title: 'รายงานและสถิติ',
                      subtitle: 'ข้อมูลการขายและรายงาน',
                      onTap: () => _navigateToReports(),
                    ),
                    _buildManagementCard(
                      icon: Icons.settings,
                      title: 'ตั้งค่าระบบ',
                      subtitle: 'การกำหนดค่าทั่วไป',
                      onTap: () => _navigateToSystemSettings(),
                    ),
                    _buildManagementCard(
                      icon: Icons.backup,
                      title: 'สำรองข้อมูล',
                      subtitle: 'การจัดการฐานข้อมูล',
                      onTap: () => _navigateToBackup(),
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

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProducts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('จัดการสินค้า - อยู่ในขั้นตอนพัฒนา')),
    );
  }

  void _navigateToCustomers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('จัดการลูกค้า - อยู่ในขั้นตอนพัฒนา')),
    );
  }

  void _navigateToEmployees() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('จัดการพนักงาน - อยู่ในขั้นตอนพัฒนา')),
    );
  }

  void _navigateToReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('รายงานและสถิติ - อยู่ในขั้นตอนพัฒนา')),
    );
  }

  void _navigateToSystemSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ตั้งค่าระบบ - อยู่ในขั้นตอนพัฒนา')),
    );
  }

  void _navigateToBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('สำรองข้อมูล - อยู่ในขั้นตอนพัฒนา')),
    );
  }
}
