import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // ใส่ email ทดสอบไว้เลย - ลูกค้า
    _emailController.text = 'smltest@gmail.com';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage('กรุณาใส่อีเมล');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(_emailController.text.trim());

      if (success && mounted) {
        Navigator.of(context).pop(); // ปิดหน้า login
        _showMessage('เข้าสู่ระบบสำเร็จ');
      } else {
        _showMessage('อีเมลไม่ถูกต้อง');
      }
    } catch (e) {
      _showMessage('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildTestUserItem(String email, String role, IconData icon) {
    return InkWell(
      onTap: () {
        _emailController.text = email;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$email - $role',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'เข้าสู่ระบบ',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo หรือ App name
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.shopping_cart, size: 64, color: Colors.white),
              ),

              const SizedBox(height: 32),

              Text(
                'SML Market',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 48),

              // Email field
              GlassmorphismCard(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    hintText: 'เลือกจากผู้ใช้ทดสอบด้านล่าง',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    prefixIcon: Icon(Icons.email, color: AppColors.primary),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _login(),
                ),
              ),

              const SizedBox(height: 24),
              // Login button
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: _isLoading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
                  onPressed: _isLoading ? null : _login,
                ),
              ),
              const SizedBox(height: 16),

              // Test users info
              GlassmorphismCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผู้ใช้ทดสอบ:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTestUserItem(
                      'smltest@gmail.com',
                      'ลูกค้า (1)',
                      Icons.person,
                    ),
                    _buildTestUserItem(
                      'smlstaff@gmail.com',
                      'พนักงาน (2)',
                      Icons.work,
                    ),
                    _buildTestUserItem(
                      'smladmin@gmail.com',
                      'ผู้ดูแลระบบ (3)',
                      Icons.admin_panel_settings,
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
}
