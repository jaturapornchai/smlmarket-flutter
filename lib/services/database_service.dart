import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  static const String baseUrl = 'http://localhost:8008';

  // ตรวจสอบสุขภาพของฐานข้อมูล
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Health check failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  // รันคำสั่ง ClickHouse SELECT
  Future<Map<String, dynamic>> executeSelectQuery(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/select'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'SELECT query failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to execute SELECT query: $e');
    }
  }

  // รันคำสั่ง ClickHouse ทั่วไป (CREATE, DROP, ALTER, etc.)
  Future<Map<String, dynamic>> executeCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/command'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': command}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Command execution failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to execute command: $e');
    }
  }

  // ดึงรายชื่อตารางทั้งหมด
  Future<List<Map<String, dynamic>>> getAllTables() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tables'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        throw Exception(
          'Tables retrieval failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get tables: $e');
    }
  }

  // สร้างตาราง customers ใน ClickHouse
  Future<Map<String, dynamic>> createCustomerTable() async {
    const String createTableCommand = '''
      CREATE TABLE IF NOT EXISTS customers (
        customer_id UUID DEFAULT generateUUIDv4(),
        first_name String,
        last_name String,
        email String,
        phone String,
        date_of_birth Date,
        gender Enum8('male' = 1, 'female' = 2, 'other' = 3),
        
        -- ที่อยู่หลัก
        address_line1 String,
        address_line2 String DEFAULT '',
        subdistrict String,
        district String,
        province String,
        postal_code String,
        
        -- ข้อมูลเพิ่มเติม
        created_at DateTime DEFAULT now(),
        updated_at DateTime DEFAULT now(),
        is_active UInt8 DEFAULT 1
      ) ENGINE = MergeTree()
      ORDER BY customer_id
      SETTINGS index_granularity = 8192
    ''';

    return await executeCommand(createTableCommand);
  }

  // ตรวจสอบตารางทั้งหมดใน ClickHouse
  Future<List<Map<String, dynamic>>> scanDatabase() async {
    try {
      // ใช้ API endpoint ใหม่
      return await getAllTables();
    } catch (e) {
      // หากไม่สำเร็จ ใช้วิธีเดิม
      try {
        final result = await executeSelectQuery('''
          SELECT 
            name as table_name,
            engine,
            total_rows,
            total_bytes
          FROM system.tables 
          WHERE database = currentDatabase()
          ORDER BY name
        ''');

        if (result['data'] is List) {
          return List<Map<String, dynamic>>.from(result['data']);
        }
        return [];
      } catch (e2) {
        throw Exception('Failed to scan database: $e2');
      }
    }
  }

  // ตรวจสอบความถูกต้องของตาราง customers
  Future<Map<String, dynamic>> verifyCustomerTable() async {
    try {
      final result = await executeSelectQuery('''
        DESCRIBE TABLE customers
      ''');

      return {
        'exists': true,
        'structure': result['data'],
        'message': 'ตาราง customers พร้อมใช้งาน',
      };
    } catch (e) {
      return {
        'exists': false,
        'structure': null,
        'message': 'ตาราง customers ยังไม่ได้สร้าง',
      };
    }
  }

  // ดึงสถิติตาราง customers
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final countResult = await executeSelectQuery('''
        SELECT count() as total_customers FROM customers
      ''');

      final activeResult = await executeSelectQuery('''
        SELECT count() as active_customers FROM customers WHERE is_active = 1
      ''');

      return {
        'total_customers': countResult['data'][0]['total_customers'],
        'active_customers': activeResult['data'][0]['active_customers'],
      };
    } catch (e) {
      throw Exception('Failed to get customer stats: $e');
    }
  }

  // เพิ่มคอลัมน์ใหม่ในตาราง customers (หากจำเป็น)
  Future<Map<String, dynamic>> addCustomerTableColumns() async {
    final List<String> alterCommands = [
      'ALTER TABLE customers ADD COLUMN IF NOT EXISTS loyalty_points UInt32 DEFAULT 0',
      'ALTER TABLE customers ADD COLUMN IF NOT EXISTS preferred_language String DEFAULT \'th\'',
      'ALTER TABLE customers ADD COLUMN IF NOT EXISTS marketing_consent UInt8 DEFAULT 0',
    ];

    final results = <String, dynamic>{};

    for (int i = 0; i < alterCommands.length; i++) {
      try {
        final result = await executeCommand(alterCommands[i]);
        results['command_${i + 1}'] = result;
      } catch (e) {
        results['command_${i + 1}_error'] = e.toString();
      }
    }

    return results;
  }

  // ค้นหาสินค้าด้วย AI Search
  Future<Map<String, dynamic>> searchProducts(
    String query, {
    int limit = 10,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/search'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query, 'limit': limit}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Product search failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // ดึงข้อมูลรายละเอียดฐานข้อมูลแบบละเอียด
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final result = await executeSelectQuery('''
        SELECT 
          name,
          engine,
          total_rows,
          total_bytes,
          metadata_modification_time,
          comment
        FROM system.tables 
        WHERE database = currentDatabase()
        ORDER BY total_bytes DESC
      ''');

      if (result['data'] is List) {
        final tables = List<Map<String, dynamic>>.from(result['data']);

        // คำนวณสถิติรวม
        int totalRows = 0;
        int totalBytes = 0;

        for (var table in tables) {
          totalRows += (table['total_rows'] as int? ?? 0);
          totalBytes += (table['total_bytes'] as int? ?? 0);
        }

        return {
          'tables': tables,
          'summary': {
            'total_tables': tables.length,
            'total_rows': totalRows,
            'total_bytes': totalBytes,
            'database_size_mb': (totalBytes / 1024 / 1024).toStringAsFixed(2),
          },
          'success': true,
        };
      }

      return {'tables': [], 'summary': {}, 'success': false};
    } catch (e) {
      throw Exception('Failed to get database info: $e');
    }
  }

  // ตรวจสอบประสิทธิภาพของคำสั่ง SQL
  Future<Map<String, dynamic>> analyzeQuery(String query) async {
    try {
      final startTime = DateTime.now().millisecondsSinceEpoch;
      final result = await executeSelectQuery(query);
      final endTime = DateTime.now().millisecondsSinceEpoch;

      final executionTime = endTime - startTime;

      return {
        'result': result,
        'performance': {
          'execution_time_ms': executionTime,
          'rows_returned': result['row_count'] ?? 0,
          'query_length': query.length,
        },
        'success': true,
      };
    } catch (e) {
      return {'error': e.toString(), 'success': false};
    }
  }

  // ตรวจสอบความถูกต้องของ SQL syntax โดยใช้ EXPLAIN
  Future<Map<String, dynamic>> validateQuery(String query) async {
    try {
      final explainQuery = 'EXPLAIN $query';
      final result = await executeSelectQuery(explainQuery);

      return {
        'valid': true,
        'explanation': result['data'],
        'message': 'Query syntax is valid',
      };
    } catch (e) {
      return {
        'valid': false,
        'error': e.toString(),
        'message': 'Query syntax error',
      };
    }
  }

  // ลบตาราง customers (ระวัง!)
  Future<Map<String, dynamic>> dropCustomerTable() async {
    return await executeCommand('DROP TABLE IF EXISTS customers');
  }
}
