import '../../models/customer/customer.dart';
import '../database_service.dart';

class ClickHouseCustomerService {
  final DatabaseService _databaseService = DatabaseService();

  // สร้างตาราง customers ใน ClickHouse
  Future<bool> createCustomerTable() async {
    try {
      const String createTableCommand = '''
        CREATE TABLE IF NOT EXISTS customers (
          customer_id UInt32 DEFAULT 0,
          customer_type String DEFAULT 'individual',
          tax_id String,
          title String DEFAULT '',
          first_name String DEFAULT '',
          last_name String DEFAULT '',
          company_name String DEFAULT '',
          address_line1 String,
          address_line2 String DEFAULT '',
          subdistrict String DEFAULT '',
          district String,
          province String,
          postal_code String,
          phone String DEFAULT '',
          email String,
          status String DEFAULT 'active',
          created_at DateTime DEFAULT now(),
          updated_at DateTime DEFAULT now()
        ) ENGINE = MergeTree()
        ORDER BY customer_id
        SETTINGS index_granularity = 8192
      ''';

      await _databaseService.executeCommand(createTableCommand);
      return true;
    } catch (e) {
      print('Error creating customer table: $e');
      return false;
    }
  }

  // เพิ่มลูกค้าใหม่
  Future<Customer?> createCustomer(Customer customer) async {
    try {
      // หา customer_id ถัดไป
      final nextIdResult = await _databaseService.executeSelectQuery('''
        SELECT max(customer_id) + 1 as next_id FROM customers
      ''');

      int nextId = 1;
      if (nextIdResult['data'] != null &&
          (nextIdResult['data'] as List).isNotEmpty) {
        final maxId = (nextIdResult['data'] as List).first['next_id'];
        nextId = maxId ?? 1;
      }
      final query =
          '''
        INSERT INTO customers (
          customer_id, customer_type, tax_id, title, first_name, last_name, company_name,
          address_line1, address_line2, subdistrict, district, province, postal_code,
          phone, email, status, line_user_id, line_display_name, is_line_connected, 
          line_connected_at, is_verified, verified_at, notes, created_at, updated_at
        ) VALUES (
          $nextId,
          '${customer.customerType == CustomerType.individual ? 'individual' : 'company'}',
          '${_escapeString(customer.taxId)}',
          '${_escapeString(customer.title ?? '')}',
          '${_escapeString(customer.firstName ?? '')}',
          '${_escapeString(customer.lastName ?? '')}',
          '${_escapeString(customer.companyName ?? '')}',
          '${_escapeString(customer.addressLine1)}',
          '${_escapeString(customer.addressLine2 ?? '')}',
          '${_escapeString(customer.subdistrict ?? '')}',
          '${_escapeString(customer.district)}',
          '${_escapeString(customer.province)}',
          '${_escapeString(customer.postalCode)}',
          '${_escapeString(customer.phone ?? '')}',
          '${_escapeString(customer.email ?? '')}',
          '${customer.status == CustomerStatus.active ? 'active' : 'inactive'}',
          '${_escapeString(customer.lineUserId ?? '')}',
          '${_escapeString(customer.lineDisplayName ?? '')}',
          ${customer.isLineConnected ? 'true' : 'false'},
          ${customer.lineConnectedAt != null ? "'${customer.lineConnectedAt!.toIso8601String()}'" : 'NULL'},
          ${customer.isVerified ? 'true' : 'false'},
          ${customer.verifiedAt != null ? "'${customer.verifiedAt!.toIso8601String()}'" : 'NULL'},
          '${_escapeString(customer.notes ?? '')}',
          now(),
          now()
        )
      ''';
      await _databaseService.executeCommand(query);

      // ดึงข้อมูลลูกค้าที่เพิ่งสร้าง
      if (customer.email != null) {
        return await getCustomerByEmail(customer.email!);
      } else {
        // If no email, try to find by tax ID or other unique field
        return null;
      }
    } catch (e) {
      print('Error creating customer: $e');
      return null;
    }
  }

  // อัปเดตข้อมูลลูกค้า
  Future<Customer?> updateCustomer(Customer customer) async {
    try {
      final query =
          '''
        ALTER TABLE customers UPDATE
          customer_type = '${customer.customerType == CustomerType.individual ? 'individual' : 'company'}',
          tax_id = '${_escapeString(customer.taxId)}',
          title = '${_escapeString(customer.title ?? '')}',
          first_name = '${_escapeString(customer.firstName ?? '')}',
          last_name = '${_escapeString(customer.lastName ?? '')}',
          company_name = '${_escapeString(customer.companyName ?? '')}',
          address_line1 = '${_escapeString(customer.addressLine1)}',
          address_line2 = '${_escapeString(customer.addressLine2 ?? '')}',
          subdistrict = '${_escapeString(customer.subdistrict ?? '')}',
          district = '${_escapeString(customer.district)}',
          province = '${_escapeString(customer.province)}',
          postal_code = '${_escapeString(customer.postalCode)}',
          phone = '${_escapeString(customer.phone ?? '')}',
          email = '${_escapeString(customer.email ?? '')}',
          status = '${customer.status == CustomerStatus.active ? 'active' : 'inactive'}',
          line_user_id = '${_escapeString(customer.lineUserId ?? '')}',
          line_display_name = '${_escapeString(customer.lineDisplayName ?? '')}',
          is_line_connected = ${customer.isLineConnected ? 'true' : 'false'},
          line_connected_at = ${customer.lineConnectedAt != null ? "'${customer.lineConnectedAt!.toIso8601String()}'" : 'NULL'},
          is_verified = ${customer.isVerified ? 'true' : 'false'},
          verified_at = ${customer.verifiedAt != null ? "'${customer.verifiedAt!.toIso8601String()}'" : 'NULL'},
          notes = '${_escapeString(customer.notes ?? '')}',
          updated_at = now()
        WHERE customer_id = ${customer.customerId}
      ''';

      await _databaseService.executeCommand(query);
      return await getCustomerById(customer.customerId!);
    } catch (e) {
      print('Error updating customer: $e');
      return null;
    }
  }

  // บันทึกลูกค้า (สร้างใหม่หรืออัปเดต)
  Future<Customer?> saveCustomer(Customer customer) async {
    if (customer.customerId != null && customer.customerId! > 0) {
      return await updateCustomer(customer);
    } else {
      return await createCustomer(customer);
    }
  }

  // ค้นหาลูกค้าด้วยอีเมล
  Future<Customer?> getCustomerByEmail(String email) async {
    try {
      final result = await _databaseService.executeSelectQuery('''
        SELECT * FROM customers 
        WHERE email = '${_escapeString(email)}' 
        AND status = 'active'
        LIMIT 1
      ''');

      if (result['data'] != null && (result['data'] as List).isNotEmpty) {
        final customerData = (result['data'] as List).first;
        return _mapToCustomer(customerData);
      }
      return null;
    } catch (e) {
      print('Error getting customer by email: $e');
      return null;
    }
  }

  // ค้นหาลูกค้าด้วย ID
  Future<Customer?> getCustomerById(int customerId) async {
    try {
      final result = await _databaseService.executeSelectQuery('''
        SELECT * FROM customers 
        WHERE customer_id = $customerId 
        AND status = 'active'
        LIMIT 1
      ''');

      if (result['data'] != null && (result['data'] as List).isNotEmpty) {
        final customerData = (result['data'] as List).first;
        return _mapToCustomer(customerData);
      }
      return null;
    } catch (e) {
      print('Error getting customer by ID: $e');
      return null;
    }
  }

  // ค้นหาลูกค้า (สำหรับพนักงาน/แอดมิน)
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final result = await _databaseService.executeSelectQuery('''
        SELECT * FROM customers 
        WHERE (
          first_name ILIKE '%${_escapeString(query)}%' OR
          last_name ILIKE '%${_escapeString(query)}%' OR
          company_name ILIKE '%${_escapeString(query)}%' OR
          email ILIKE '%${_escapeString(query)}%' OR
          phone ILIKE '%${_escapeString(query)}%' OR
          tax_id ILIKE '%${_escapeString(query)}%'
        ) AND status = 'active'
        ORDER BY updated_at DESC
        LIMIT 50
      ''');

      if (result['data'] != null) {
        final customers = (result['data'] as List)
            .map((data) => _mapToCustomer(data))
            .toList();
        return customers;
      }
      return [];
    } catch (e) {
      print('Error searching customers: $e');
      return [];
    }
  }

  // ดึงลูกค้าทั้งหมด (สำหรับแอดมิน/พนักงาน)
  Future<List<Customer>> getAllCustomers({int limit = 100}) async {
    try {
      final result = await _databaseService.executeSelectQuery('''
        SELECT * FROM customers 
        WHERE status = 'active'
        ORDER BY updated_at DESC
        LIMIT $limit
      ''');

      if (result['data'] != null) {
        final customers = (result['data'] as List)
            .map((data) => _mapToCustomer(data))
            .toList();
        return customers;
      }
      return [];
    } catch (e) {
      print('Error getting all customers: $e');
      return [];
    }
  }

  // ลบลูกค้า (soft delete)
  Future<bool> deleteCustomer(int customerId) async {
    try {
      await _databaseService.executeCommand('''
        ALTER TABLE customers UPDATE
          status = 'inactive',
          updated_at = now()
        WHERE customer_id = $customerId
      ''');
      return true;
    } catch (e) {
      print('Error deleting customer: $e');
      return false;
    }
  }

  // ดึงสถิติลูกค้า
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final totalResult = await _databaseService.executeSelectQuery('''
        SELECT count() as total_customers FROM customers WHERE status = 'active'
      ''');

      final individualResult = await _databaseService.executeSelectQuery('''
        SELECT count() as individual_customers FROM customers 
        WHERE status = 'active' AND customer_type = 'individual'
      ''');

      final companyResult = await _databaseService.executeSelectQuery('''
        SELECT count() as company_customers FROM customers 
        WHERE status = 'active' AND customer_type = 'company'
      ''');

      return {
        'total_customers': totalResult['data'][0]['total_customers'] ?? 0,
        'individual_customers':
            individualResult['data'][0]['individual_customers'] ?? 0,
        'company_customers': companyResult['data'][0]['company_customers'] ?? 0,
      };
    } catch (e) {
      print('Error getting customer stats: $e');
      return {
        'total_customers': 0,
        'individual_customers': 0,
        'company_customers': 0,
      };
    }
  }

  // แปลงข้อมูลจาก ClickHouse เป็น Customer object
  Customer _mapToCustomer(Map<String, dynamic> data) {
    return Customer(
      customerId: data['customer_id']?.toInt(),
      customerType: data['customer_type'] == 'company'
          ? CustomerType.company
          : CustomerType.individual,
      taxId: data['tax_id']?.toString() ?? '',
      title: data['title']?.toString(),
      firstName: data['first_name']?.toString(),
      lastName: data['last_name']?.toString(),
      companyName: data['company_name']?.toString(),
      addressLine1: data['address_line1']?.toString() ?? '',
      addressLine2: data['address_line2']?.toString(),
      subdistrict: data['subdistrict']?.toString(),
      district: data['district']?.toString() ?? '',
      province: data['province']?.toString() ?? '',
      postalCode: data['postal_code']?.toString() ?? '',
      phone: data['phone']?.toString(),
      email: data['email']?.toString() ?? '',
      status: data['status'] == 'inactive'
          ? CustomerStatus.inactive
          : CustomerStatus.active,
    );
  }

  // Escape string สำหรับ SQL injection protection
  String _escapeString(String input) {
    return input.replaceAll("'", "''").replaceAll('\\', '\\\\');
  }
}
