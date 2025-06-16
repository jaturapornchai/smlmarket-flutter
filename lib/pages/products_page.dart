import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../widgets/responsive_layout.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'รายการสินค้า',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddProductDialog(context),
            icon: const Icon(Icons.add, color: Colors.white),
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
                    const Icon(Icons.inventory, color: Colors.white, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'จัดการรายการสินค้า',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'เพิ่ม แก้ไข และลบสินค้าในระบบ',
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

              // Search and Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ค้นหาสินค้า...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _showFilterDialog(context),
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Product Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'ทั้งหมด',
                      '156',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      'พร้อมขาย',
                      '142',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      'หมด',
                      '14',
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Products List
              Text(
                'รายการสินค้า',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              ..._buildProductList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Color.fromARGB(
                  51,
                  (color.r * 255).round(),
                  (color.g * 255).round(),
                  (color.b * 255).round(),
                ), // 20% opacity
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
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

  List<Widget> _buildProductList() {
    final products = [
      {
        'name': 'iPhone 15 Pro Max',
        'category': 'สมาร์ทโฟน',
        'price': '฿45,900',
        'stock': '25',
        'status': 'พร้อมขาย',
        'statusColor': Colors.green,
      },
      {
        'name': 'Samsung Galaxy S24',
        'category': 'สมาร์ทโฟน',
        'price': '฿32,900',
        'stock': '0',
        'status': 'หมด',
        'statusColor': Colors.red,
      },
      {
        'name': 'MacBook Air M3',
        'category': 'โน้ตบุ๊ก',
        'price': '฿42,900',
        'stock': '12',
        'status': 'พร้อมขาย',
        'statusColor': Colors.green,
      },
      {
        'name': 'iPad Pro 12.9"',
        'category': 'แท็บเล็ต',
        'price': '฿35,900',
        'stock': '8',
        'status': 'พร้อมขาย',
        'statusColor': Colors.green,
      },
    ];

    return products.map((product) => _buildProductCard(product)).toList();
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassmorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0x1A1976D2), // Light blue with 10% opacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['category'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          product['price'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(
                              product['statusColor'].value & 0x33FFFFFF,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: product['statusColor']),
                          ),
                          child: Text(
                            product['status'],
                            style: TextStyle(
                              color: product['statusColor'],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'คงเหลือ',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    product['stock'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editProduct(product['name']),
                        icon: const Icon(Icons.edit, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _deleteProduct(product['name']),
                        icon: const Icon(Icons.delete, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มสินค้าใหม่'),
        content: const Text('ฟังก์ชันเพิ่มสินค้าใหม่จะถูกพัฒนาต่อไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('กรองสินค้า'),
        content: const Text('ฟังก์ชันกรองสินค้าจะถูกพัฒนาต่อไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _editProduct(String productName) {
    // Implement edit product functionality
  }

  void _deleteProduct(String productName) {
    // Implement delete product functionality
  }
}
