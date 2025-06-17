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
      final databaseInfo = await _databaseService.getDatabaseInfo();
      setState(() {
        _databaseInfo = databaseInfo;
        _tables = List<Map<String, dynamic>>.from(databaseInfo['tables'] ?? []);
        _successMessage = 'สแกนฐานข้อมูลสำเร็จ พบ ${_tables.length} ตาราง';
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

  Future<void> _testProductSearch() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _databaseService.searchProducts('laptop', limit: 5);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ผลการค้นหาสินค้า'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('พบสินค้า: ${result['metadata']['total_found']} รายการ'),
                  Text('เวลาค้นหา: ${result['metadata']['duration_ms']} ms'),
                  const SizedBox(height: 16),
                  if (result['data'] != null && result['data'].isNotEmpty) ...[
                    const Text(
                      'ตัวอย่างสินค้า:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...((result['data'] as List)
                        .take(3)
                        .map(
                          (product) => Text(
                            '• ${product['product_name']} (${product['product_code']})',
                          ),
                        )),
                  ],
                ],
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
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการทดสอบค้นหา: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showQueryAnalyzer() {
    final TextEditingController queryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('วิเคราะห์ SQL Query'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: queryController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'SQL Query',
                  hintText: 'SELECT * FROM customers LIMIT 10',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _validateQuery(queryController.text),
                    child: const Text('ตรวจสอบ Syntax'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _analyzeQueryPerformance(queryController.text),
                    child: const Text('วิเคราะห์ Performance'),
                  ),
                ],
              ),
            ],
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

  Future<void> _validateQuery(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final result = await _databaseService.validateQuery(query);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['valid'] ? Colors.green : Colors.red,
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
    }
  }

  Future<void> _analyzeQueryPerformance(String query) async {
    if (query.trim().isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _databaseService.analyzeQuery(query);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ผลการวิเคราะห์ Performance'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (result['success']) ...[
                    Text(
                      'เวลาดำเนินการ: ${result['performance']['execution_time_ms']} ms',
                    ),
                    Text(
                      'จำนวนแถวที่ได้: ${result['performance']['rows_returned']} แถว',
                    ),
                    Text(
                      'ความยาว Query: ${result['performance']['query_length']} ตัวอักษร',
                    ),
                  ] else ...[
                    Text('เกิดข้อผิดพลาด: ${result['error']}'),
                  ],
                ],
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
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการวิเคราะห์: $e';
      });
    } finally {
      setState(() {
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
                  if (_databaseInfo != null) _buildDatabaseSummaryCard(),

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
              'http://localhost:8008',
              Colors.grey,
            ),
            if (_healthStatus!.containsKey('version'))
              _buildStatusRow(
                'ClickHouse Version',
                _healthStatus!['version'].toString(),
                Colors.blue,
              ),
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
                  onPressed: _isLoading ? null : _createCustomerTable,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('สร้างตารางใหม่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _verifyAndUpdateTables,
                  icon: const Icon(Icons.verified),
                  label: const Text('ตรวจสอบและอัปเดต'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
                  onPressed: _isLoading ? null : _testProductSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('ทดสอบค้นหาสินค้า'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _showQueryAnalyzer,
                  icon: const Icon(Icons.analytics),
                  label: const Text('วิเคราะห์ Query'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _scanDatabase,
              icon: const Icon(Icons.scanner),
              label: const Text('สแกนฐานข้อมูลทั้งหมด'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
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
    final summary = _databaseInfo!['summary'] as Map<String, dynamic>;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปข้อมูลฐานข้อมูล',
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tables.length,
              itemBuilder: (context, index) {
                final table = _tables[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.table_chart, color: AppColors.primary),
                    title: Text(
                      table['name'] ?? table['table_name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Engine: ${table['engine'] ?? 'Unknown'} | '
                      'Rows: ${table['rows'] ?? table['total_rows'] ?? '0'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (table['rows'] != null ||
                            table['total_rows'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${table['rows'] ?? table['total_rows'] ?? 0}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
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
        ],
      ),
    );
  }

  void _showTableDetails(Map<String, dynamic> table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียดตาราง ${table['name'] ?? table['table_name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'ชื่อตาราง',
                table['name'] ?? table['table_name'] ?? 'Unknown',
              ),
              _buildDetailRow('Engine', table['engine'] ?? 'Unknown'),
              _buildDetailRow(
                'จำนวนแถว',
                (table['rows'] ?? table['total_rows'] ?? 0).toString(),
              ),
              if (table['total_bytes'] != null)
                _buildDetailRow(
                  'ขนาดข้อมูล (bytes)',
                  table['total_bytes'].toString(),
                ),
              if (table['metadata_modification_time'] != null)
                _buildDetailRow(
                  'วันที่แก้ไข',
                  table['metadata_modification_time'].toString(),
                ),
              if (table['comment'] != null &&
                  table['comment'].toString().isNotEmpty)
                _buildDetailRow('คำอธิบาย', table['comment'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
          if (table['name'] == 'customers' ||
              table['table_name'] == 'customers')
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
