import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/customer/customer_service.dart';
import '../../models/customer/customer.dart';
import '../../widgets/ui_components.dart';
import 'customer_form.dart';

class CustomerManagementPage extends StatefulWidget {
  const CustomerManagementPage({super.key});

  @override
  State<CustomerManagementPage> createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final CustomerService _customerService = CustomerService();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _customerService.getAllCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return customer.displayName.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            (customer.email?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            customer.taxId.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final canManageCustomers =
        currentUser?.isEmployee == true || currentUser?.isAdmin == true;

    if (!canManageCustomers) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('จัดการลูกค้า'),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(child: Text('คุณไม่มีสิทธิ์เข้าถึงหน้านี้')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'จัดการลูกค้า',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Search bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'ค้นหาลูกค้า...',
                          hintText: 'ค้นหาลูกค้า...',
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        onChanged: _filterCustomers,
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addCustomer,
                    icon: const Icon(Icons.person_add),
                    label: const Text('เพิ่มลูกค้า'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Content area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : _buildCustomerList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'ไม่พบลูกค้า',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _customers.isEmpty
                ? 'ยังไม่มีลูกค้าในระบบ'
                : 'ไม่พบลูกค้าที่ตรงกับคำค้นหา',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassmorphismCard(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  customer.displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                customer.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.email ?? 'ไม่มีอีเมล'),
                  Text(
                    'เลขประจำตัวผู้เสียภาษี: ${customer.taxId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editCustomer(customer);
                      break;
                    case 'view':
                      _viewCustomer(customer);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(Icons.visibility),
                      title: Text('ดูข้อมูล'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('แก้ไข'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _filterCustomers(query);
    } else {
      setState(() {
        _filteredCustomers = _customers;
      });
    }
  }

  void _addCustomer() async {
    final result = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(builder: (context) => const CustomerForm()),
    );

    if (result != null) {
      _loadCustomers(); // Reload the list
    }
  }

  void _editCustomer(Customer customer) async {
    final result = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(builder: (context) => CustomerForm(customer: customer)),
    );

    if (result != null) {
      _loadCustomers(); // Reload the list
    }
  }

  void _viewCustomer(Customer customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CustomerForm(customer: customer, isReadOnly: true),
      ),
    );
  }
}
