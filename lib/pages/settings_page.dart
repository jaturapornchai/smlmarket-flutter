import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../widgets/responsive_layout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = true;
  bool _locationEnabled = true;
  double _textSizeMultiplier = 1.0;

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
          'การตั้งค่า',
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
              // Settings Header
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
                    const Icon(Icons.settings, color: Colors.white, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'การตั้งค่า',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'ปรับแต่งการใช้งานแอปพลิเคชัน',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // General Settings
              _buildSectionHeader('การตั้งค่าทั่วไป'),
              const SizedBox(height: AppSpacing.md),

              _buildSettingCard([
                _buildSwitchTile(
                  'การแจ้งเตือน',
                  'รับการแจ้งเตือนจากแอป',
                  Icons.notifications,
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
                _buildSwitchTile(
                  'โหมดมืด',
                  'เปลี่ยนธีมเป็นโหมดมืด',
                  Icons.dark_mode,
                  _darkModeEnabled,
                  (value) => setState(() => _darkModeEnabled = value),
                ),
                _buildSliderTile(
                  'ขนาดตัวอักษร',
                  'ปรับขนาดตัวอักษรในแอป',
                  Icons.text_fields,
                  _textSizeMultiplier,
                  0.8,
                  1.5,
                  (value) => setState(() => _textSizeMultiplier = value),
                ),
              ]),

              const SizedBox(height: AppSpacing.xl),

              // Security Settings
              _buildSectionHeader('ความปลอดภัย'),
              const SizedBox(height: AppSpacing.md),

              _buildSettingCard([
                _buildSwitchTile(
                  'การยืนยันตัวตน',
                  'ใช้ลายนิ้วมือหรือ Face ID',
                  Icons.fingerprint,
                  _biometricEnabled,
                  (value) => setState(() => _biometricEnabled = value),
                ),
                _buildActionTile(
                  'เปลี่ยนรหัสผ่าน',
                  'อัปเดตรหัสผ่านของคุณ',
                  Icons.lock,
                  () => _showPasswordDialog(),
                ),
              ]),

              const SizedBox(height: AppSpacing.xl),

              // App Settings
              _buildSectionHeader('การตั้งค่าแอป'),
              const SizedBox(height: AppSpacing.md),

              _buildSettingCard([
                _buildSwitchTile(
                  'การเข้าถึงตำแหน่ง',
                  'อนุญาตให้แอปเข้าถึงตำแหน่ง',
                  Icons.location_on,
                  _locationEnabled,
                  (value) => setState(() => _locationEnabled = value),
                ),
                _buildActionTile(
                  'ล้างข้อมูลแคช',
                  'ลบข้อมูลที่เก็บไว้ชั่วคราว',
                  Icons.cleaning_services,
                  () => _showClearCacheDialog(),
                ),
                _buildActionTile(
                  'ดู Log',
                  'ตรวจสอบการทำงานของระบบ',
                  Icons.list_alt,
                  () => _showDebugDialog(),
                ),
              ]),

              const SizedBox(height: AppSpacing.xl),

              // About Section
              _buildSectionHeader('เกี่ยวกับ'),
              const SizedBox(height: AppSpacing.md),

              _buildSettingCard([
                _buildActionTile(
                  'เกี่ยวกับแอป',
                  'ข้อมูลแอปและเวอร์ชัน',
                  Icons.info,
                  () => _showAboutDialog(),
                ),
                _buildActionTile(
                  'นโยบายความเป็นส่วนตัว',
                  'อ่านนโยบายการใช้ข้อมูล',
                  Icons.privacy_tip,
                  () => _showPrivacyDialog(),
                ),
                _buildActionTile(
                  'เงื่อนไขการใช้งาน',
                  'เงื่อนไขและข้อกำหนด',
                  Icons.description,
                  () => _showTermsDialog(),
                ),
              ]),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return GlassmorphismCard(child: Column(children: children));
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 7,
            label: '${(value * 100).round()}%',
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยนรหัสผ่าน'),
        content: const Text('คุณต้องการเปลี่ยนรหัสผ่านหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างข้อมูลแคช'),
        content: const Text(
          'การดำเนินการนี้จะลบข้อมูลที่เก็บไว้ชั่วคราวทั้งหมด',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement cache clearing logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ล้างข้อมูลแคชเรียบร้อยแล้ว')),
              );
            },
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เกี่ยวกับแอป'),
        content: const Text('SML Market\nเวอร์ชัน 1.0.0\nพัฒนาโดย Flutter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นโยบายความเป็นส่วนตัว'),
        content: const Text('เราให้ความสำคัญกับข้อมูลส่วนตัวของคุณ...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เงื่อนไขการใช้งาน'),
        content: const Text('โดยการใช้แอปพลิเคชันนี้ คุณยอมรับเงื่อนไข...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: 1.0.0'),
            const SizedBox(height: 8),
            Text('Platform: ${Theme.of(context).platform.name}'),
            const SizedBox(height: 8),
            Text('Theme: ${Theme.of(context).brightness.name}'),
            const SizedBox(height: 8),
            Text('Screen Size: ${MediaQuery.of(context).size}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
