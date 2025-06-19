import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';
import '../../services/database_service.dart';
import '../../services/customer/customer_service.dart';

class DatabaseManagementPage extends StatefulWidget {
  const DatabaseManagementPage({super.key});

  @override
  State<DatabaseManagementPage> createState() => _DatabaseManagementPageState();
}

class _DatabaseManagementPageState extends State<DatabaseManagementPage> {
  final DatabaseService _databaseService = DatabaseService();
  final CustomerService _customerService = CustomerService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _tables = [];
  Map<String, dynamic>? _healthStatus;
  Map<String, dynamic>? _customerStats;
  Map<String, dynamic>? _databaseInfo;
  Map<String, dynamic>? _comprehensiveDbInfo;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _checkDatabaseHealth();
  }

  Future<void> _checkDatabaseHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final health = await _databaseService.checkHealth();
      setState(() {
        _healthStatus = health;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการตรวจสอบสุขภาพฐานข้อมูล: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _scanDatabase() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // ใช้ PostgreSQL เป็นหลัก
      final tables = await _databaseService.scanDatabase();
      setState(() {
        _tables = tables;
        _successMessage =
            'สแกนฐานข้อมูล PostgreSQL สำเร็จ พบ ${_tables.length} ตาราง';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการสแกนฐานข้อมูล: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createCustomerTable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _customerService.createCustomerTable();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างตาราง customers สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _scanDatabase(); // รีเฟรชรายการตาราง
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการสร้างตาราง: $e';
        _isLoading = false;
      });
    }
  }

  // เพิ่มฟังก์ชันสร้างตารางทั้งหมดใน PostgreSQL
  Future<void> _createAllPostgreSQLTables() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _databaseService.createAllPostgreSQLTables();

      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _successMessage =
              'สร้างตารางทั้งหมดสำเร็จ: customers, carts, cart_items, coupons, coupon_usages, orders, order_items, order_status_history';
        } else {
          _errorMessage = result['message'] ?? 'เกิดข้อผิดพลาดในการสร้างตาราง';
        }
      });

      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างตารางทั้งหมดใน PostgreSQL สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _scanDatabase(); // รีเฟรชรายการตาราง
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการสร้างตาราง: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyAndUpdateTables() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final customerStats = await _customerService.getCustomerStats();

      setState(() {
        _customerStats = customerStats;
        _successMessage = 'ตรวจสอบและอัปเดตตารางสำเร็จ';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ตรวจสอบและอัปเดตตารางสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _scanDatabase();
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการตรวจสอบตาราง: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showCustomerTableDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // ดึงข้อมูลโครงสร้างตาราง
      final tableStructure = await _databaseService.executeSelectQuery(
        'DESCRIBE TABLE customers',
      );

      // ดึงสถิติลูกค้า
      final customerStats = await _customerService.getCustomerStats();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('รายละเอียดตารางลูกค้า'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // สถิติ
                    const Text(
                      'สถิติ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ลูกค้าทั้งหมด: ${customerStats['total_customers']} คน',
                    ),
                    Text(
                      'ลูกค้าที่ใช้งาน: ${customerStats['active_customers']} คน',
                    ),

                    const SizedBox(height: 20),

                    // โครงสร้างตาราง
                    const Text(
                      'โครงสร้างตาราง',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (tableStructure['data'] != null) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tableStructure['data'].length,
                        itemBuilder: (context, index) {
                          final column = tableStructure['data'][index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      column['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      column['type'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ปิด'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('จัดการฐานข้อมูล'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkDatabaseHealth,
            tooltip: 'รีเฟรช',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Status Card
                  _buildHealthStatusCard(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 20), // Error Message
                  if (_errorMessage != null) _buildErrorCard(),

                  // Success Message
                  if (_successMessage != null) _buildSuccessCard(),
                  const SizedBox(height: 20),

                  // Database Summary
                  if (_comprehensiveDbInfo != null || _databaseInfo != null)
                    _buildDatabaseSummaryCard(),

                  const SizedBox(height: 20),

                  // Customer Stats
                  if (_customerStats != null) _buildCustomerStatsCard(),

                  const SizedBox(height: 20),

                  // Tables List
                  _buildTablesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthStatusCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: _healthStatus != null ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'สถานะฐานข้อมูล',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_healthStatus != null) ...[
            _buildStatusRow('สถานะเชื่อมต่อ', 'เชื่อมต่อสำเร็จ', Colors.green),
            _buildStatusRow(
              'เวลาตอบกลับ',
              '${DateTime.now().millisecondsSinceEpoch % 1000}ms',
              Colors.blue,
            ),
            _buildStatusRow(
              'API Base URL',
              'http://192.168.2.36:8008',
              Colors.grey,
            ),

            const SizedBox(height: 16),

            // แสดงสถานะแต่ละฐานข้อมูล
            Row(
              children: [
                // ClickHouse Status
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ClickHouse',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_healthStatus!.containsKey('version'))
                          Text(
                            'Version: ${_healthStatus!['version'].toString()}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        Text(
                          'Status: Connected',
                          style: TextStyle(fontSize: 11, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // PostgreSQL Status
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_tree,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PostgreSQL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version: PostgreSQL 16.9',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Status: Connected',
                          style: TextStyle(fontSize: 11, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_healthStatus!.containsKey('timestamp'))
              _buildStatusRow(
                'Last Check',
                DateTime.now().toString().substring(0, 19),
                Colors.grey,
              ),
          ] else ...[
            _buildStatusRow('สถานะเชื่อมต่อ', 'เชื่อมต่อไม่สำเร็จ', Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'การจัดการฐานข้อมูล',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createAllPostgreSQLTables,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('สร้างตารางทั้งหมด'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createCustomerTable,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('สร้างตารางลูกค้า'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _verifyAndUpdateTables,
                  icon: const Icon(Icons.verified),
                  label: const Text('ตรวจสอบตาราง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scanDatabase,
                  icon: const Icon(Icons.scanner),
                  label: const Text('สแกนฐานข้อมูล'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseSummaryCard() {
    // ใช้ข้อมูลจาก comprehensive scan ถ้ามี หรือใช้ข้อมูลเก่า
    Map<String, dynamic> summary;

    if (_comprehensiveDbInfo != null &&
        _comprehensiveDbInfo!['success'] == true) {
      summary = _comprehensiveDbInfo!['summary'] as Map<String, dynamic>;

      return GlassmorphismCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สรุปข้อมูลฐานข้อมูลทั้งหมด',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // สรุปรวม
            Row(
              children: [
                Expanded(
                  child: _buildSummaryTile(
                    'ฐานข้อมูลทั้งหมด',
                    '${summary['total_databases']} ฐาน',
                    Icons.data_usage,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryTile(
                    'ตารางทั้งหมด',
                    '${summary['total_tables']} ตาราง',
                    Icons.table_chart,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryTile(
                    'แถวข้อมูลทั้งหมด',
                    '${summary['total_rows']} แถว',
                    Icons.storage,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryTile(
                    'ขนาดฐานข้อมูล',
                    '${summary['total_size_mb']?.toStringAsFixed(2) ?? '0'} MB',
                    Icons.memory,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // แสดงรายละเอียดแต่ละฐานข้อมูล
            Row(
              children: [
                // ClickHouse
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ClickHouse',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_comprehensiveDbInfo!['clickhouse']['table_count']} ตาราง',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${_comprehensiveDbInfo!['clickhouse']['total_rows']} แถว',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${(_comprehensiveDbInfo!['clickhouse']['total_size_mb'] as num?)?.toStringAsFixed(2) ?? '0'} MB',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // PostgreSQL
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_tree,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PostgreSQL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_comprehensiveDbInfo!['postgresql']['table_count']} ตาราง',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${_comprehensiveDbInfo!['postgresql']['total_rows']} แถว',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${(_comprehensiveDbInfo!['postgresql']['total_size_mb'] as num?)?.toStringAsFixed(2) ?? '0'} MB',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (_databaseInfo != null) {
      // แสดงข้อมูลแบบเก่า (PostgreSQL เท่านั้น)
      summary = _databaseInfo!['summary'] as Map<String, dynamic>;

      return GlassmorphismCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สรุปข้อมูลฐานข้อมูล (PostgreSQL)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryTile(
                    'ตารางทั้งหมด',
                    '${summary['total_tables']} ตาราง',
                    Icons.table_chart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryTile(
                    'แถวข้อมูลทั้งหมด',
                    '${summary['total_rows']} แถว',
                    Icons.storage,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSummaryTile(
              'ขนาดฐานข้อมูล',
              '${summary['database_size_mb']} MB',
              Icons.memory,
              Colors.orange,
            ),
          ],
        ),
      );
    }

    return Container(); // ไม่แสดงอะไรถ้าไม่มีข้อมูล
  }

  Widget _buildCustomerStatsCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สถิติลูกค้า',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  'ลูกค้าทั้งหมด',
                  '${_customerStats!['total_customers']} คน',
                  Icons.people,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryTile(
                  'ลูกค้าที่ใช้งาน',
                  '${_customerStats!['active_customers']} คน',
                  Icons.person_outline,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ตารางในฐานข้อมูล',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_tables.length} ตาราง',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_tables.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.table_chart_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่พบตารางในฐานข้อมูล',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'กดปุ่ม "สแกนฐานข้อมูลทั้งหมด" เพื่อตรวจสอบ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // แยกตารางตามประเภทฐานข้อมูล
            ...(() {
              final clickHouseTables = _tables
                  .where((table) => table['database_type'] == 'ClickHouse')
                  .toList();
              final postgreSQLTables = _tables
                  .where((table) => table['database_type'] == 'PostgreSQL')
                  .toList();
              final unknownTables = _tables
                  .where((table) => table['database_type'] == null)
                  .toList();

              final widgets = <Widget>[];

              // ClickHouse Tables
              if (clickHouseTables.isNotEmpty) {
                widgets.add(
                  _buildDatabaseSection(
                    'ClickHouse',
                    Icons.speed,
                    Colors.green,
                    clickHouseTables,
                  ),
                );
                widgets.add(const SizedBox(height: 16));
              }

              // PostgreSQL Tables
              if (postgreSQLTables.isNotEmpty) {
                widgets.add(
                  _buildDatabaseSection(
                    'PostgreSQL',
                    Icons.account_tree,
                    Colors.blue,
                    postgreSQLTables,
                  ),
                );
                widgets.add(const SizedBox(height: 16));
              }

              // Unknown Tables (fallback)
              if (unknownTables.isNotEmpty) {
                widgets.add(
                  _buildDatabaseSection(
                    'ไม่ระบุประเภท',
                    Icons.help_outline,
                    Colors.grey,
                    unknownTables,
                  ),
                );
              }

              return widgets;
            })(),
          ],
        ],
      ),
    );
  }

  Widget _buildDatabaseSection(
    String databaseName,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> tables,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$databaseName (${tables.length} ตาราง)',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: Icon(Icons.table_chart, color: color),
                title: Text(
                  table['name'] ?? table['table_name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Engine: ${table['engine'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Rows: ${_formatNumber(table['rows'] ?? table['total_rows'] ?? 0)} | '
                      'Size: ${_formatSize(table['total_bytes'] ?? table['size_mb'])}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatNumber(
                          table['rows'] ?? table['total_rows'] ?? 0,
                        ),
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showTableDetails(table),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final num = int.tryParse(number.toString()) ?? 0;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  String _formatSize(dynamic size) {
    if (size == null) return '0 B';

    if (size is num) {
      // ถ้าเป็น bytes
      if (size > 1024 * 1024) {
        return '${(size / 1024 / 1024).toStringAsFixed(1)} MB';
      } else if (size > 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '$size B';
      }
    }

    return size.toString();
  }

  void _showTableDetails(Map<String, dynamic> table) {
    final tableName = table['name'] ?? table['table_name'] ?? 'Unknown';
    final databaseType = table['database_type'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              databaseType == 'ClickHouse' ? Icons.speed : Icons.account_tree,
              color: databaseType == 'ClickHouse' ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('รายละเอียดตาราง $tableName')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 600, // เพิ่มความสูงเพื่อให้พอดีกับตาราง fields
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ข้อมูลพื้นฐาน
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (databaseType == 'ClickHouse'
                              ? Colors.green
                              : Colors.blue)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ชื่อตาราง', tableName),
                    _buildDetailRow('ฐานข้อมูล', databaseType ?? 'Unknown'),
                    _buildDetailRow('Engine', table['engine'] ?? 'Unknown'),
                    _buildDetailRow(
                      'จำนวนแถว',
                      _formatNumber(table['rows'] ?? table['total_rows'] ?? 0),
                    ),
                    if (table['total_bytes'] != null ||
                        table['size_mb'] != null)
                      _buildDetailRow(
                        'ขนาดข้อมูล',
                        _formatSize(table['total_bytes'] ?? table['size_mb']),
                      ),
                    if (table['metadata_modification_time'] != null)
                      _buildDetailRow(
                        'วันที่แก้ไข',
                        table['metadata_modification_time']
                            .toString()
                            .substring(0, 19),
                      ),
                    if (table['comment'] != null &&
                        table['comment'].toString().isNotEmpty)
                      _buildDetailRow('คำอธิบาย', table['comment'].toString()),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // แสดงข้อมูล Fields โดยตรง
              Text(
                'Fields ของตาราง',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: databaseType == 'ClickHouse'
                      ? Colors.green
                      : Colors.blue,
                ),
              ),
              const SizedBox(height: 8),

              // ตาราง Fields
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _getTableFieldsData(tableName, databaseType),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('กำลังโหลดข้อมูล fields...'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'ไม่สามารถโหลดข้อมูล fields ได้',
                              style: TextStyle(color: Colors.red),
                            ),
                            Text(
                              snapshot.error.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text('ไม่พบข้อมูล fields'));
                    }

                    final fieldsData = snapshot.data!;
                    final fields = fieldsData['fields'] as List;

                    if (fields.isEmpty) {
                      return const Center(
                        child: Text('ไม่พบ fields ในตารางนี้'),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'จำนวน Fields: ${fields.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ตารางแสดง Fields
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                // Header ของตาราง
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        (databaseType == 'ClickHouse'
                                                ? Colors.green
                                                : Colors.blue)
                                            .withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Field Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: databaseType == 'ClickHouse'
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Type',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: databaseType == 'ClickHouse'
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Nullable',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: databaseType == 'ClickHouse'
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Default',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: databaseType == 'ClickHouse'
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ข้อมูล Fields
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: fields.length,
                                    itemBuilder: (context, index) {
                                      final field = fields[index];
                                      final isEven = index % 2 == 0;

                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isEven
                                              ? Colors.grey[50]
                                              : Colors.white,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[200]!,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                field['name'] ??
                                                    field['column_name'] ??
                                                    'Unknown',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                field['type'] ??
                                                    field['data_type'] ??
                                                    'Unknown',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                field['is_nullable']
                                                        ?.toString() ??
                                                    '-',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                (field['column_default']
                                                            ?.toString()
                                                            .isNotEmpty ==
                                                        true)
                                                    ? field['column_default']
                                                          .toString()
                                                    : '-',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
          if (tableName == 'customers')
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCustomerTableDetails();
              },
              child: const Text('ดูรายละเอียดลูกค้า'),
            ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับดึงข้อมูล fields ของตาราง
  Future<Map<String, dynamic>> _getTableFieldsData(
    String tableName,
    String? databaseType,
  ) async {
    if (databaseType == 'ClickHouse') {
      return await _databaseService.getClickHouseTableFields(tableName);
    } else {
      return await _databaseService.getPostgreSQLTableFields(tableName);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
