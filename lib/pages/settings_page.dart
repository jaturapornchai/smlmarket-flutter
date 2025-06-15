import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../widgets/responsive_layout.dart';
import 'log_viewer_page.dart';

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
      body: ResponsiveLayout(
        fullWidth: true, // ใช้ full width สำหรับหน้า Settings
        child: CustomScrollView(
          slivers: [
            // Settings Header
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primary, // เพิ่ม background color
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'ตั้งค่า',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -50,
                        bottom: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.settings,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ), // General Settings Section
            SliverPersistentHeader(
              pinned: true,
              delegate: CustomSliverPersistentHeader(
                maxHeight: 60,
                minHeight: 60,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ทั่วไป',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedListItem(
                    index: 0,
                    child: GlassmorphismCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            title: const Text('การแจ้งเตือน'),
                            subtitle: const Text('รับการแจ้งเตือนจากแอป'),
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            title: const Text('โหมดมืด'),
                            subtitle: const Text('เปลี่ยนธีมของแอป'),
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            title: const Text('ตำแหน่งที่ตั้ง'),
                            subtitle: const Text('อนุญาตการเข้าถึงตำแหน่ง'),
                            value: _locationEnabled,
                            onChanged: (value) {
                              setState(() {
                                _locationEnabled = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimatedListItem(
                    index: 1,
                    child: GlassmorphismCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            title: const Text('ขนาดตัวอักษร'),
                            subtitle: Text(
                              'ขนาดปัจจุบัน: ${(_textSizeMultiplier * 100).round()}%',
                            ),
                            trailing: Icon(
                              Icons.text_fields,
                              color: AppColors.primary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Slider(
                              value: _textSizeMultiplier,
                              min: 0.8,
                              max: 1.4,
                              divisions: 6,
                              label: '${(_textSizeMultiplier * 100).round()}%',
                              onChanged: (value) {
                                setState(() {
                                  _textSizeMultiplier = value;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ), // Security Section
            SliverPersistentHeader(
              pinned: true,
              delegate: CustomSliverPersistentHeader(
                maxHeight: 60,
                minHeight: 60,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ความปลอดภัย',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedListItem(
                    index: 2,
                    child: GlassmorphismCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            title: const Text('การยืนยันตัวตนแบบไบโอเมตริก'),
                            subtitle: const Text('ใช้ลายนิ้วมือหรือ Face ID'),
                            value: _biometricEnabled,
                            onChanged: (value) {
                              setState(() {
                                _biometricEnabled = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lock_outline,
                                color: AppColors.accent,
                              ),
                            ),
                            title: const Text('เปลี่ยนรหัสผ่าน'),
                            subtitle: const Text('อัปเดตรหัสผ่านของคุณ'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showPasswordDialog();
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.security,
                                color: AppColors.secondary,
                              ),
                            ),
                            title: const Text('การตรวจสอบสองชั้น'),
                            subtitle: const Text('เพิ่มความปลอดภัยให้บัญชี'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showTwoFactorDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ), // About Section
            SliverPersistentHeader(
              pinned: true,
              delegate: CustomSliverPersistentHeader(
                maxHeight: 60,
                minHeight: 60,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'เกี่ยวกับ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedListItem(
                    index: 3,
                    child: GlassmorphismCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                              ),
                            ),
                            title: const Text('เกี่ยวกับแอป'),
                            subtitle: const Text('เวอร์ชัน 1.0.0'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showAboutDialog();
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                color: AppColors.accent,
                              ),
                            ),
                            title: const Text('เงื่อนไขการใช้งาน'),
                            subtitle: const Text('นโยบายและข้อกำหนด'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showTermsDialog();
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.privacy_tip_outlined,
                                color: AppColors.secondary,
                              ),
                            ),
                            title: const Text('นโยบายความเป็นส่วนตัว'),
                            subtitle: const Text('การใช้และเก็บข้อมูล'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showPrivacyDialog();
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.bug_report_outlined,
                                color: Colors.orange,
                              ),
                            ),
                            title: const Text('Debug Logs'),
                            subtitle: const Text('ดู API logs สำหรับการ debug'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogViewerPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ), // Contact & Support Section
            SliverPersistentHeader(
              pinned: true,
              delegate: CustomSliverPersistentHeader(
                maxHeight: 60,
                minHeight: 60,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ติดต่อและสนับสนุน',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedListItem(
                    index: 4,
                    child: GlassmorphismCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.help_outline,
                                color: AppColors.primary,
                              ),
                            ),
                            title: const Text('ศูนย์ช่วยเหลือ'),
                            subtitle: const Text('คำถามที่พบบ่อยและคู่มือ'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showHelpCenter();
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.contact_support_outlined,
                                color: AppColors.accent,
                              ),
                            ),
                            title: const Text('ติดต่อเรา'),
                            subtitle: const Text('ส่งข้อความหาทีมสนับสนุน'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showContactDialog();
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.star_outline,
                                color: AppColors.secondary,
                              ),
                            ),
                            title: const Text('ให้คะแนนแอป'),
                            subtitle: const Text(
                              'แบ่งปันความคิดเห็นใน App Store',
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              _showRatingDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ), // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('เปลี่ยนรหัสผ่าน'),
        content: const Text('คุณต้องการเปลี่ยนรหัสผ่านหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ดำเนินการ'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('การตรวจสอบสองชั้น'),
        content: const Text('เปิดใช้งานการตรวจสอบสองชั้นเพื่อเพิ่มความปลอดภัย'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เปิดใช้งาน'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('เกี่ยวกับ SML Market'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เวอร์ชัน: 1.0.0'),
            Text('พัฒนาโดย: SML Team'),
            Text('© 2025 SML Market'),
          ],
        ),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('เงื่อนไขการใช้งาน'),
        content: const Text('นี่คือเงื่อนไขการใช้งานของแอปพลิเคชัน SML Market'),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('นโยบายความเป็นส่วนตัว'),
        content: const Text(
          'เราเคารพความเป็นส่วนตัวของคุณและจะปกป้องข้อมูลส่วนบุคคล',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ศูนย์ช่วยเหลือ'),
        content: const Text('ที่นี่คุณจะพบคำตอบสำหรับคำถามที่พบบ่อย'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ติดต่อเรา'),
        content: const Text('ส่งอีเมลไปที่: support@smlmarket.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ให้คะแนนแอป'),
        content: const Text('ขอบคุณที่ใช้แอป! กรุณาให้คะแนนเราใน App Store'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ไว้ครั้งหน้า'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ให้คะแนน'),
          ),
        ],
      ),
    );
  }
}
