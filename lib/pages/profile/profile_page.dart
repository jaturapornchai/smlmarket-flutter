import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';
import '../../services/auth_service.dart';
import '../../services/customer/customer_service.dart';
import '../../models/customer/customer.dart';
import '../customers/customer_form.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final CustomerService _customerService = CustomerService();
  Customer? _customerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      setState(() {
        _isLoading = true;
      });

      final customer = await _customerService.getCustomerByEmail(
        currentUser.email,
      );

      setState(() {
        _customerData = customer;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editProfile() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final result = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(
        builder: (context) => CustomerForm(customer: _customerData),
      ),
    );

    if (result != null) {
      setState(() {
        _customerData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('โปรไฟล์'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editProfile,
              tooltip: 'แก้ไขข้อมูล',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
          ? _buildNotLoggedIn()
          : _buildProfileContent(currentUser),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'กรุณาเข้าสู่ระบบเพื่อดูข้อมูลโปรไฟล์',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(currentUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Card
          GlassmorphismCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    currentUser.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser.roleDisplayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Customer Data Card
          if (_customerData != null)
            _buildCustomerDataCard()
          else
            _buildNoCustomerDataCard(),

          const SizedBox(height: 16),

          // Actions Card
          _buildActionsCard(),
        ],
      ),
    );
  }

  Widget _buildCustomerDataCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ข้อมูลลูกค้า',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('แก้ไข'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildInfoRow('ประเภท', _customerData!.customerType.displayName),
          _buildInfoRow('เลขประจำตัวผู้เสียภาษี', _customerData!.taxId),
          _buildInfoRow('ชื่อ', _customerData!.displayName),
          _buildInfoRow('ที่อยู่', _customerData!.fullAddress),
          if (_customerData!.phone?.isNotEmpty == true)
            _buildInfoRow('เบอร์โทรศัพท์', _customerData!.phone!),
        ],
      ),
    );
  }

  Widget _buildNoCustomerDataCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีข้อมูลลูกค้า',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'กรุณาเพิ่มข้อมูลลูกค้าเพื่อใช้งานระบบอย่างเต็มรูปแบบ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มข้อมูลลูกค้า'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'การตั้งค่า',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ'),
            onTap: () {
              _authService.logout();
            },
          ),
        ],
      ),
    );
  }
}
