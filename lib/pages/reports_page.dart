import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../widgets/responsive_layout.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'รายงาน',
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
                    const Icon(Icons.bar_chart, color: Colors.white, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'รายงานและสถิติ',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'ดูรายงานการขายและสถิติต่างๆ',
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

              // Time Period Filter
              Text(
                'เลือกช่วงเวลา',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPeriodChip('วันนี้', true, Colors.blue),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip('สัปดาห์นี้', false, Colors.green),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip('เดือนนี้', false, Colors.orange),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip('ปีนี้', false, Colors.purple),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip('กำหนดเอง', false, Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Revenue Summary
              Text(
                'สรุปรายได้',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _buildRevenueCard(
                    'รายได้วันนี้',
                    '฿12,500',
                    '+15%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildRevenueCard(
                    'ยอดขายเฉลี่ย',
                    '฿8,900',
                    '+8%',
                    Icons.analytics,
                    Colors.blue,
                  ),
                  _buildRevenueCard(
                    'คำสั่งซื้อ',
                    '25',
                    '+22%',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                  _buildRevenueCard(
                    'ลูกค้าใหม่',
                    '8',
                    '+12%',
                    Icons.person_add,
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Top Products
              Text(
                'สินค้าขายดี',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              GlassmorphismCard(
                child: Column(
                  children: [
                    _buildTopProductItem(
                      'iPhone 15 Pro Max',
                      '25 ชิ้น',
                      '฿1,147,500',
                      1,
                    ),
                    const Divider(),
                    _buildTopProductItem(
                      'Samsung Galaxy S24',
                      '18 ชิ้น',
                      '฿592,200',
                      2,
                    ),
                    const Divider(),
                    _buildTopProductItem(
                      'MacBook Air M3',
                      '12 ชิ้น',
                      '฿514,800',
                      3,
                    ),
                    const Divider(),
                    _buildTopProductItem(
                      'iPad Pro 12.9"',
                      '10 ชิ้น',
                      '฿359,000',
                      4,
                    ),
                    const Divider(),
                    _buildTopProductItem(
                      'AirPods Pro',
                      '35 ชิ้น',
                      '฿315,000',
                      5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Quick Reports
              Text(
                'รายงานด่วน',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.2,
                children: [
                  _buildReportCard(
                    'รายงานการขาย',
                    'ดูรายงานการขายรายละเอียด',
                    Icons.point_of_sale,
                    Colors.blue,
                    () => _generateSalesReport(),
                  ),
                  _buildReportCard(
                    'รายงานสินค้าคงคลัง',
                    'ตรวจสอบสินค้าคงคลัง',
                    Icons.inventory,
                    Colors.green,
                    () => _generateInventoryReport(),
                  ),
                  _buildReportCard(
                    'รายงานลูกค้า',
                    'วิเคราะห์ข้อมูลลูกค้า',
                    Icons.people,
                    Colors.orange,
                    () => _generateCustomerReport(),
                  ),
                  _buildReportCard(
                    'รายงานกำไร',
                    'วิเคราะห์กำไรขาดทุน',
                    Icons.attach_money,
                    Colors.purple,
                    () => _generateProfitReport(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected, Color color) {
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

  Widget _buildRevenueCard(
    String title,
    String amount,
    String change,
    IconData icon,
    Color color,
  ) {
    return GlassmorphismCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              amount,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                change,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem(
    String name,
    String quantity,
    String revenue,
    int rank,
  ) {
    Color rankColor = rank <= 3
        ? [Colors.amber, Colors.grey, Colors.brown][rank - 1]
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color.fromARGB(
                51,
                (rankColor.r * 255).round(),
                (rankColor.g * 255).round(),
                (rankColor.b * 255).round(),
              ), // 20% opacity
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(color: rankColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  quantity,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            revenue,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassmorphismCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    51,
                    (color.r * 255).round(),
                    (color.g * 255).round(),
                    (color.b * 255).round(),
                  ), // 20% opacity
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateSalesReport() {
    // Implement sales report generation
  }

  void _generateInventoryReport() {
    // Implement inventory report generation
  }

  void _generateCustomerReport() {
    // Implement customer report generation
  }

  void _generateProfitReport() {
    // Implement profit report generation
  }
}
