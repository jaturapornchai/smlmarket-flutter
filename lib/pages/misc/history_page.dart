import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';
import '../../widgets/responsive_layout.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'ประวัติการสั่งซื้อ',
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
                    const Icon(Icons.history, color: Colors.white, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'ประวัติการสั่งซื้อ',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'ดูประวัติการสั่งซื้อและติดตามสถานะ',
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

              // Filter Section
              Text(
                'กรองการค้นหา',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              GlassmorphismCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'สถานะ',
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('ทั้งหมด'),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('รอดำเนินการ'),
                            ),
                            DropdownMenuItem(
                              value: 'processing',
                              child: Text('กำลังเตรียม'),
                            ),
                            DropdownMenuItem(
                              value: 'shipped',
                              child: Text('จัดส่งแล้ว'),
                            ),
                            DropdownMenuItem(
                              value: 'delivered',
                              child: Text('ส่งสำเร็จ'),
                            ),
                            DropdownMenuItem(
                              value: 'cancelled',
                              child: Text('ยกเลิก'),
                            ),
                          ],
                          onChanged: (value) {
                            // Handle filter change
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle search
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('ค้นหา'),
                      ),
                    ],
                  ),
                ),
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

              // Sample Orders
              ..._buildSampleOrders(),

              const SizedBox(height: AppSpacing.xl),

              // Empty State (if no orders)
              Center(
                child: GlassmorphismCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'ไม่มีประวัติการสั่งซื้อ',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'เริ่มต้นสั่งซื้อสินค้าเพื่อดูประวัติที่นี่',
                          style: TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/search');
                          },
                          child: const Text('เริ่มช้อปปิ้ง'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSampleOrders() {
    final orders = [
      {
        'id': 'ORD001',
        'date': '15 ธ.ค. 2024',
        'status': 'delivered',
        'statusText': 'ส่งสำเร็จ',
        'total': '฿1,250.00',
        'items': 3,
        'color': Colors.green,
      },
      {
        'id': 'ORD002',
        'date': '12 ธ.ค. 2024',
        'status': 'shipped',
        'statusText': 'จัดส่งแล้ว',
        'total': '฿850.00',
        'items': 2,
        'color': Colors.blue,
      },
      {
        'id': 'ORD003',
        'date': '10 ธ.ค. 2024',
        'status': 'processing',
        'statusText': 'กำลังเตรียม',
        'total': '฿2,100.00',
        'items': 5,
        'color': Colors.orange,
      },
    ];

    return orders.map((order) => _buildOrderCard(order)).toList();
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GlassmorphismCard(
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
                    ), // order['color'] with opacity
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: order['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'คำสั่งซื้อ ${order['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        order['date'],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0x1A4CAF50,
                    ), // order['color'] with opacity
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: order['color']),
                  ),
                  child: Text(
                    order['statusText'],
                    style: TextStyle(
                      color: order['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      '${order['items']} รายการ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
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
                      order['total'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show order details
                    },
                    child: const Text('ดูรายละเอียด'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Track order or reorder
                    },
                    child: Text(
                      order['status'] == 'delivered' ? 'สั่งซื้อซ้ำ' : 'ติดตาม',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
