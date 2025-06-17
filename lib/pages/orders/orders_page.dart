import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';
import '../../widgets/responsive_layout.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'คำสั่งซื้อ',
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
                    const Icon(Icons.list_alt, color: Colors.white, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'จัดการคำสั่งซื้อ',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'ดูและจัดการคำสั่งซื้อทั้งหมด',
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

              // Order Status Filter
              Text(
                'กรองตามสถานะ',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusChip('ทั้งหมด', true, Colors.grey),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusChip('รอดำเนินการ', false, Colors.orange),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusChip('กำลังเตรียม', false, Colors.blue),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusChip('จัดส่งแล้ว', false, Colors.green),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusChip('เสร็จสิ้น', false, Colors.teal),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusChip('ยกเลิก', false, Colors.red),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Order Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'วันนี้',
                      '25',
                      Icons.today,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      'รอดำเนินการ',
                      '8',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      'เสร็จสิ้น',
                      '142',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Orders List
              Text(
                'รายการคำสั่งซื้อ',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              ..._buildOrdersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isSelected, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? color
            : Color.fromARGB(
                51,
                (color.r * 255).round(),
                (color.g * 255).round(),
                (color.b * 255).round(),
              ), // 20% opacity
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
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

  List<Widget> _buildOrdersList() {
    final orders = [
      {
        'id': 'ORD001',
        'customer': 'สมชาย ใจดี',
        'date': '16 ธ.ค. 2024 14:30',
        'amount': '฿2,450',
        'items': '3 รายการ',
        'status': 'รอดำเนินการ',
        'statusColor': Colors.orange,
        'canEdit': true,
      },
      {
        'id': 'ORD002',
        'customer': 'สมหญิง ใจงาม',
        'date': '16 ธ.ค. 2024 13:15',
        'amount': '฿1,890',
        'items': '2 รายการ',
        'status': 'กำลังเตรียม',
        'statusColor': Colors.blue,
        'canEdit': true,
      },
      {
        'id': 'ORD003',
        'customer': 'วิชัย เก่งดี',
        'date': '16 ธ.ค. 2024 11:45',
        'amount': '฿3,200',
        'items': '5 รายการ',
        'status': 'จัดส่งแล้ว',
        'statusColor': Colors.green,
        'canEdit': false,
      },
      {
        'id': 'ORD004',
        'customer': 'มาลี สวยงาม',
        'date': '15 ธ.ค. 2024 16:20',
        'amount': '฿990',
        'items': '1 รายการ',
        'status': 'เสร็จสิ้น',
        'statusColor': Colors.teal,
        'canEdit': false,
      },
    ];

    return orders.map((order) => _buildOrderCard(order)).toList();
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassmorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(
                        0x1A1976D2,
                      ), // Light blue with 10% opacity
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              order['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(
                                  51,
                                  (order['statusColor'].r * 255).round(),
                                  (order['statusColor'].g * 255).round(),
                                  (order['statusColor'].b * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: order['statusColor']),
                              ),
                              child: Text(
                                order['status'],
                                style: TextStyle(
                                  color: order['statusColor'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['customer'],
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['date'],
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'จำนวนสินค้า',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          order['items'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ยอดรวม',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          order['amount'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewOrderDetails(order['id']),
                      icon: const Icon(Icons.visibility),
                      label: const Text('ดูรายละเอียด'),
                    ),
                  ),
                  if (order['canEdit']) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order['id']),
                        icon: const Icon(Icons.edit),
                        label: const Text('อัปเดตสถานะ'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewOrderDetails(String orderId) {
    // Implement view order details functionality
  }

  void _updateOrderStatus(String orderId) {
    // Implement update order status functionality
  }
}
