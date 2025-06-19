import 'dart:convert';
import 'package:http/http.dart' as http;

// Enum for database types
enum DatabaseType { clickhouse, postgresql }

class DatabaseService {
  static const String baseUrl = 'http://192.168.2.36:8008';

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

  // รันคำสั่ง PostgreSQL SELECT
  Future<Map<String, dynamic>> executeSelectQuery(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/pgselect'),
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

  // รันคำสั่ง ClickHouse SELECT
  Future<Map<String, dynamic>> executeClickHouseSelect(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/select'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'ClickHouse SELECT query failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to execute ClickHouse SELECT query: $e');
    }
  }

  // รันคำสั่ง PostgreSQL ทั่วไป (CREATE, DROP, ALTER, etc.)
  Future<Map<String, dynamic>> executeCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/pgcommand'),
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

  // รันคำสั่ง ClickHouse ทั่วไป (CREATE, DROP, ALTER, etc.)
  Future<Map<String, dynamic>> executeClickHouseCommand(String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/command'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': command}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'ClickHouse command execution failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to execute ClickHouse command: $e');
    }
  }

  // ดึงรายชื่อตารางทั้งหมด
  Future<List<Map<String, dynamic>>> getAllTables() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/tables'),
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

  // สร้างตาราง customers ใน PostgreSQL (ปรับปรุงจาก ClickHouse)
  Future<Map<String, dynamic>> createCustomerTable() async {
    const String createTableCommand = '''
      CREATE TABLE IF NOT EXISTS customers (
        customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        first_name VARCHAR(100) NOT NULL,
        last_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20),
        date_of_birth DATE,
        gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
        
        -- ที่อยู่หลัก
        address_line1 TEXT,
        address_line2 TEXT DEFAULT '',
        subdistrict VARCHAR(100),
        district VARCHAR(100),
        province VARCHAR(100),
        postal_code VARCHAR(10),
        
        -- ข้อมูลเพิ่มเติม
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT TRUE
      );
      
      -- สร้าง index สำหรับการค้นหา
      CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
      CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
      CREATE INDEX IF NOT EXISTS idx_customers_is_active ON customers(is_active);
    ''';

    return await executeCommand(createTableCommand);
  } // สร้างตารางสำหรับระบบตระกร้าสินค้า

  Future<Map<String, dynamic>> createCartTables() async {
    try {
      // สร้างตาราง carts
      await executeCommand('''
        CREATE TABLE IF NOT EXISTS carts (
          cart_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          customer_id UUID,
          session_id VARCHAR(255),
          cart_status VARCHAR(20) DEFAULT 'active' CHECK (cart_status IN ('active', 'abandoned', 'converted', 'expired')),
          total_amount DECIMAL(15,2) DEFAULT 0.00,
          item_count INTEGER DEFAULT 0,
          discount_amount DECIMAL(15,2) DEFAULT 0.00,
          tax_amount DECIMAL(15,2) DEFAULT 0.00,
          shipping_amount DECIMAL(15,2) DEFAULT 0.00,
          final_amount DECIMAL(15,2) DEFAULT 0.00,
          currency_code VARCHAR(3) DEFAULT 'THB',
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          expires_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days')
        )
      ''');

      // สร้างตาราง cart_items
      await executeCommand('''
        CREATE TABLE IF NOT EXISTS cart_items (
          cart_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          cart_id UUID NOT NULL,
          product_id VARCHAR(50) NOT NULL,
          product_name VARCHAR(255) NOT NULL,
          product_code VARCHAR(100),
          unit_price DECIMAL(15,2) NOT NULL,
          quantity INTEGER NOT NULL DEFAULT 1,
          total_price DECIMAL(15,2) NOT NULL,
          discount_percent DECIMAL(5,2) DEFAULT 0.00,
          discount_amount DECIMAL(15,2) DEFAULT 0.00,
          final_price DECIMAL(15,2) NOT NULL,
          product_options JSONB,
          notes TEXT,
          added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          
          CHECK (quantity > 0),
          CHECK (unit_price >= 0),
          CHECK (total_price >= 0),
          CHECK (final_price >= 0)
        )
      ''');

      // สร้างตาราง coupons
      await executeCommand('''
        CREATE TABLE IF NOT EXISTS coupons (
          coupon_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          coupon_code VARCHAR(50) UNIQUE NOT NULL,
          coupon_name VARCHAR(255) NOT NULL,
          description TEXT,
          discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount', 'free_shipping')),
          discount_value DECIMAL(15,2) NOT NULL,
          minimum_amount DECIMAL(15,2) DEFAULT 0.00,
          maximum_discount DECIMAL(15,2),
          usage_limit INTEGER,
          usage_count INTEGER DEFAULT 0,
          customer_usage_limit INTEGER DEFAULT 1,
          start_date TIMESTAMP WITH TIME ZONE,
          end_date TIMESTAMP WITH TIME ZONE,
          is_active BOOLEAN DEFAULT TRUE,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          
          CHECK (discount_value > 0),
          CHECK (minimum_amount >= 0),
          CHECK (usage_limit IS NULL OR usage_limit > 0),
          CHECK (customer_usage_limit > 0)
        )
      ''');

      // สร้างตาราง coupon_usages
      await executeCommand('''
        CREATE TABLE IF NOT EXISTS coupon_usages (
          usage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          coupon_id UUID NOT NULL,
          customer_id UUID,
          cart_id UUID,
          order_id VARCHAR(50),
          discount_amount DECIMAL(15,2) NOT NULL,
          used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // สร้าง indexes
      await executeCommand('''
        CREATE INDEX IF NOT EXISTS idx_carts_customer_id ON carts(customer_id);
        CREATE INDEX IF NOT EXISTS idx_carts_session_id ON carts(session_id);
        CREATE INDEX IF NOT EXISTS idx_carts_status ON carts(cart_status);
        CREATE INDEX IF NOT EXISTS idx_carts_created_at ON carts(created_at);
        CREATE INDEX IF NOT EXISTS idx_carts_expires_at ON carts(expires_at);
      ''');

      await executeCommand('''
        CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON cart_items(cart_id);
        CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);
        CREATE INDEX IF NOT EXISTS idx_cart_items_product_code ON cart_items(product_code);
      ''');

      await executeCommand('''
        CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(coupon_code);
        CREATE INDEX IF NOT EXISTS idx_coupons_active ON coupons(is_active);
        CREATE INDEX IF NOT EXISTS idx_coupons_dates ON coupons(start_date, end_date);
      ''');

      await executeCommand('''
        CREATE INDEX IF NOT EXISTS idx_coupon_usages_coupon_id ON coupon_usages(coupon_id);
        CREATE INDEX IF NOT EXISTS idx_coupon_usages_customer_id ON coupon_usages(customer_id);
        CREATE INDEX IF NOT EXISTS idx_coupon_usages_cart_id ON coupon_usages(cart_id);
      ''');

      return {'success': true, 'message': 'Cart tables created successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // สร้าง triggers สำหรับ auto-update timestamps
  Future<Map<String, dynamic>> createDatabaseTriggers() async {
    try {
      // สร้าง function สำหรับ auto-update timestamps
      await executeCommand('''
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS \$\$
        BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        \$\$ language 'plpgsql'
      ''');

      // สร้าง triggers สำหรับตาราง customers
      await executeCommand('''
        DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
        CREATE TRIGGER update_customers_updated_at 
            BEFORE UPDATE ON customers 
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
      ''');

      // สร้าง triggers สำหรับตาราง carts
      await executeCommand('''
        DROP TRIGGER IF EXISTS update_carts_updated_at ON carts;
        CREATE TRIGGER update_carts_updated_at 
            BEFORE UPDATE ON carts 
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
      ''');

      // สร้าง triggers สำหรับตาราง cart_items
      await executeCommand('''
        DROP TRIGGER IF EXISTS update_cart_items_updated_at ON cart_items;
        CREATE TRIGGER update_cart_items_updated_at 
            BEFORE UPDATE ON cart_items 
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
      ''');

      // สร้าง triggers สำหรับตาราง coupons
      await executeCommand('''
        DROP TRIGGER IF EXISTS update_coupons_updated_at ON coupons;
        CREATE TRIGGER update_coupons_updated_at 
            BEFORE UPDATE ON coupons 
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
      ''');

      return {
        'success': true,
        'message': 'Database triggers created successfully',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  } // สร้างตารางสำหรับระบบคำสั่งซื้อ

  Future<Map<String, dynamic>> createOrderTables() async {
    try {
      // สร้างตาราง orders
      await executeCommand('''
        CREATE TABLE IF NOT EXISTS orders (
          order_id VARCHAR(50) PRIMARY KEY,
          customer_id UUID,
          cart_id UUID,
          order_number VARCHAR(50) UNIQUE NOT NULL,
          order_status VARCHAR(20) DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
          payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'partial')),
          shipping_status VARCHAR(20) DEFAULT 'pending' CHECK (shipping_status IN ('pending', 'preparing', 'shipped', 'in_transit', 'delivered', 'returned')),
          
          customer_email VARCHAR(255),
          customer_phone VARCHAR(20),
          customer_name VARCHAR(200),
          
          shipping_address JSONB,
          billing_address JSONB,
          shipping_method VARCHAR(100),
          tracking_number VARCHAR(100),
          
          subtotal DECIMAL(15,2) NOT NULL DEFAULT 0.00,
          discount_amount DECIMAL(15,2) DEFAULT 0.00,
          tax_amount DECIMAL(15,2) DEFAULT 0.00,
          shipping_amount DECIMAL(15,2) DEFAULT 0.00,
          total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
          currency_code VARCHAR(3) DEFAULT 'THB',
          
          coupon_code VARCHAR(50),
          coupon_discount DECIMAL(15,2) DEFAULT 0.00,
          
          payment_method VARCHAR(50),
          payment_reference VARCHAR(255),
          paid_at TIMESTAMP WITH TIME ZONE,
          
          order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          confirmed_at TIMESTAMP WITH TIME ZONE,
          shipped_at TIMESTAMP WITH TIME ZONE,
          delivered_at TIMESTAMP WITH TIME ZONE,
          cancelled_at TIMESTAMP WITH TIME ZONE,
          
          notes TEXT,
          admin_notes TEXT,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // สร้างตาราง order_items
      await executeCommand('''
        CREATE TABLE IF NOT EXISTS order_items (
          order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          order_id VARCHAR(50) NOT NULL,
          product_id VARCHAR(50) NOT NULL,
          product_name VARCHAR(255) NOT NULL,
          product_code VARCHAR(100),
          unit_price DECIMAL(15,2) NOT NULL,
          quantity INTEGER NOT NULL,
          total_price DECIMAL(15,2) NOT NULL,
          discount_percent DECIMAL(5,2) DEFAULT 0.00,
          discount_amount DECIMAL(15,2) DEFAULT 0.00,
          final_price DECIMAL(15,2) NOT NULL,
          product_options JSONB,
          notes TEXT,
          
          CHECK (quantity > 0),
          CHECK (unit_price >= 0),
          CHECK (total_price >= 0),
          CHECK (final_price >= 0)
        )
      ''');

      // สร้างตาราง order_status_history
      await executeCommand('''
        CREATE TABLE IF NOT EXISTS order_status_history (
          history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          order_id VARCHAR(50) NOT NULL,
          status_type VARCHAR(20) NOT NULL CHECK (status_type IN ('order', 'payment', 'shipping')),
          old_status VARCHAR(20),
          new_status VARCHAR(20) NOT NULL,
          changed_by VARCHAR(100),
          change_reason TEXT,
          changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // สร้าง indexes สำหรับ orders
      await executeCommand('''
        CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
        CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders(order_number);
        CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
        CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
        CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
        CREATE INDEX IF NOT EXISTS idx_orders_email ON orders(customer_email);
        CREATE INDEX IF NOT EXISTS idx_orders_phone ON orders(customer_phone);
      ''');

      // สร้าง indexes สำหรับ order_items
      await executeCommand('''
        CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
        CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
        CREATE INDEX IF NOT EXISTS idx_order_items_product_code ON order_items(product_code);
      ''');

      // สร้าง indexes สำหรับ order_status_history
      await executeCommand('''
        CREATE INDEX IF NOT EXISTS idx_order_history_order_id ON order_status_history(order_id);
        CREATE INDEX IF NOT EXISTS idx_order_history_status_type ON order_status_history(status_type);
        CREATE INDEX IF NOT EXISTS idx_order_history_changed_at ON order_status_history(changed_at);
      ''');

      return {'success': true, 'message': 'Order tables created successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // สร้าง triggers สำหรับตาราง orders
  Future<Map<String, dynamic>> createOrderTriggers() async {
    try {
      // สร้าง trigger สำหรับ orders
      await executeCommand('''
        DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
        CREATE TRIGGER update_orders_updated_at 
            BEFORE UPDATE ON orders 
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()
      ''');

      return {
        'success': true,
        'message': 'Order triggers created successfully',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // สร้างตารางทั้งหมดสำหรับ PostgreSQL
  Future<Map<String, dynamic>> createAllPostgreSQLTables() async {
    final results = <String, dynamic>{};

    try {
      // 1. สร้างตาราง customers
      print('สร้างตาราง customers...');
      results['customers'] = await createCustomerTable();

      // 2. สร้างตารางระบบตระกร้า
      print('สร้างตารางระบบตระกร้า...');
      results['cart_tables'] = await createCartTables();

      // 3. สร้างตารางระบบคำสั่งซื้อ
      print('สร้างตารางระบบคำสั่งซื้อ...');
      results['order_tables'] = await createOrderTables();

      // 4. สร้าง triggers
      print('สร้าง database triggers...');
      results['triggers'] = await createDatabaseTriggers();
      results['order_triggers'] = await createOrderTriggers();

      results['success'] = true;
      results['message'] = 'สร้างตารางทั้งหมดสำเร็จ';
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();
      results['message'] = 'เกิดข้อผิดพลาดในการสร้างตาราง: $e';
    }

    return results;
  }

  // สแกนฐานข้อมูลทั้งหมด (เน้น PostgreSQL เป็นหลัก)
  Future<List<Map<String, dynamic>>> scanDatabase() async {
    try {
      // ใช้ PostgreSQL เป็นหลัก
      final result = await executeSelectQuery('''
        SELECT 
          t.table_name,
          'PostgreSQL' as engine,
          COALESCE(c.reltuples::BIGINT, 0) as total_rows,
          COALESCE(pg_total_relation_size(c.oid), 0) as total_bytes,
          ROUND(COALESCE(pg_total_relation_size(c.oid), 0) / 1024.0 / 1024.0, 2) as size_mb,
          'PostgreSQL' as database_type
        FROM information_schema.tables t
        LEFT JOIN pg_class c ON c.relname = t.table_name
        LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE t.table_schema = 'public' 
          AND t.table_type = 'BASE TABLE'
          AND (n.nspname = 'public' OR n.nspname IS NULL)
        ORDER BY total_bytes DESC      ''');

      if (result['data'] is List) {
        return List<Map<String, dynamic>>.from(result['data']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to scan database: $e');
    }
  }

  // ฟังก์ชันใหม่: ดึงรายละเอียดตารางพร้อมข้อมูลสถิติ
  Future<List<Map<String, dynamic>>> getAllTablesWithDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/tables'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true) {
          // ถ้า API ส่งข้อมูลมาแล้ว ใช้เลย
          if (data['data'] is List) {
            return List<Map<String, dynamic>>.from(data['data']);
          }
        }

        // ถ้าไม่มีข้อมูลละเอียด ให้ดึงข้อมูลเพิ่มเติม
        return await getTableDetailsManually();
      } else {
        throw Exception(
          'Tables retrieval failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get tables with details: $e');
    }
  }

  // ดึงข้อมูลตารางพร้อมสถิติด้วยตนเอง
  Future<List<Map<String, dynamic>>> getTableDetailsManually() async {
    final result = await executeSelectQuery('''
      SELECT 
        t.table_name,
        'PostgreSQL' as engine,
        COALESCE(c.reltuples::BIGINT, 0) as total_rows,
        COALESCE(pg_total_relation_size(c.oid), 0) as total_bytes,
        ROUND(COALESCE(pg_total_relation_size(c.oid), 0) / 1024.0 / 1024.0, 2) as size_mb,
        obj_description(c.oid, 'pg_class') as comment
      FROM information_schema.tables t
      LEFT JOIN pg_class c ON c.relname = t.table_name
      LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE t.table_schema = 'public' 
        AND t.table_type = 'BASE TABLE'
        AND (n.nspname = 'public' OR n.nspname IS NULL)
      ORDER BY total_bytes DESC
    ''');

    if (result['data'] is List) {
      return List<Map<String, dynamic>>.from(result['data']);
    }
    return [];
  }

  // ตรวจสอบความถูกต้องของตาราง customers
  Future<Map<String, dynamic>> verifyCustomerTable() async {
    try {
      final result = await executeSelectQuery('''
        SELECT 
          column_name,
          data_type,
          is_nullable,
          column_default
        FROM information_schema.columns 
        WHERE table_name = 'customers' AND table_schema = 'public'
        ORDER BY ordinal_position
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
        Uri.parse('$baseUrl/v1/search'),
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
          table_name as name,
          'PostgreSQL' as engine,
          0 as total_rows,
          0 as total_bytes,
          CURRENT_TIMESTAMP as metadata_modification_time,
          '' as comment
        FROM information_schema.tables 
        WHERE table_schema = 'public'
        ORDER BY table_name
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

  // ดึงรายละเอียด fields ของตาราง
  Future<Map<String, dynamic>> getTableFields(String tableName) async {
    try {
      final result = await executeSelectQuery('''
        SELECT 
          column_name,
          data_type,
          is_nullable,
          column_default,
          character_maximum_length,
          numeric_precision,
          numeric_scale,
          ordinal_position
        FROM information_schema.columns 
        WHERE table_name = '$tableName' 
          AND table_schema = 'public'
        ORDER BY ordinal_position
      ''');

      if (result['success'] == true && result['data'] is List) {
        final fields = List<Map<String, dynamic>>.from(result['data']);

        // ดึงข้อมูล Primary Keys แบบง่าย
        Map<String, dynamic> pkResult;
        try {
          pkResult = await executeSelectQuery('''
            SELECT column_name
            FROM information_schema.key_column_usage
            WHERE table_name = '$tableName' 
              AND table_schema = 'public'
          ''');
        } catch (e) {
          pkResult = {'data': []};
        }

        final primaryKeys = <String>[];
        if (pkResult['data'] is List) {
          primaryKeys.addAll(
            (pkResult['data'] as List).map(
              (pk) => pk['column_name'].toString(),
            ),
          );
        }

        return {
          'table_name': tableName,
          'fields': fields,
          'primary_keys': primaryKeys,
          'field_count': fields.length,
        };
      } else {
        throw Exception(
          'No field data returned: ${result['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get table fields for $tableName: $e');
    }
  }

  // ดึงข้อมูลสถิติของตาราง (แบบง่าย)
  Future<Map<String, dynamic>> getTableStatistics(String tableName) async {
    try {
      final result = await executeSelectQuery('''
        SELECT COUNT(*) as total_rows FROM $tableName
      ''');

      final rowCount = result['data']?[0]?['total_rows'] ?? 0;

      return {
        'table_name': tableName,
        'total_rows': rowCount,
        'size_mb': 0.0, // จะคำนวณภายหลัง
        'message': 'Statistics retrieved successfully',
      };
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาด ส่งค่าเริ่มต้น
      return {
        'table_name': tableName,
        'total_rows': 0,
        'size_mb': 0.0,
        'message': 'Unable to get statistics: $e',
      };
    }
  }

  // สแกนฐานข้อมูล ClickHouse
  Future<List<Map<String, dynamic>>> scanClickHouseDatabase() async {
    try {
      final result = await executeClickHouseSelect('''
        SELECT 
          name as table_name,
          engine,
          total_rows,
          total_bytes,
          ROUND(total_bytes / 1024.0 / 1024.0, 2) as size_mb,
          metadata_modification_time,
          comment
        FROM system.tables 
        WHERE database = currentDatabase()
        ORDER BY total_bytes DESC
      ''');

      if (result['success'] == true && result['data'] is List) {
        final tables = List<Map<String, dynamic>>.from(result['data']);
        // เพิ่ม database type
        for (var table in tables) {
          table['database_type'] = 'ClickHouse';
        }
        return tables;
      }
      return [];
    } catch (e) {
      print('Error scanning ClickHouse: $e');
      return [];
    }
  }

  // สแกนฐานข้อมูล PostgreSQL
  Future<List<Map<String, dynamic>>> scanPostgreSQLDatabase() async {
    try {
      final result = await executeSelectQuery('''
        SELECT 
          t.table_name,
          'PostgreSQL' as engine,
          COALESCE(c.reltuples::BIGINT, 0) as total_rows,
          COALESCE(pg_total_relation_size(c.oid), 0) as total_bytes,
          ROUND(COALESCE(pg_total_relation_size(c.oid), 0) / 1024.0 / 1024.0, 2) as size_mb,
          obj_description(c.oid, 'pg_class') as comment
        FROM information_schema.tables t
        LEFT JOIN pg_class c ON c.relname = t.table_name
        LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE t.table_schema = 'public' 
          AND t.table_type = 'BASE TABLE'
          AND (n.nspname = 'public' OR n.nspname IS NULL)
        ORDER BY total_bytes DESC
      ''');

      if (result['success'] == true && result['data'] is List) {
        final tables = List<Map<String, dynamic>>.from(result['data']);
        // เพิ่ม database type
        for (var table in tables) {
          table['database_type'] = 'PostgreSQL';
        }
        return tables;
      }
      return [];
    } catch (e) {
      print('Error scanning PostgreSQL: $e');
      return [];
    }
  }

  // สแกนฐานข้อมูลทั้งสองแบบ
  Future<Map<String, dynamic>> scanBothDatabases() async {
    try {
      final clickHouseTables = await scanClickHouseDatabase();
      final postgreSQLTables = await scanPostgreSQLDatabase();
      return {
        'clickhouse': {
          'tables': clickHouseTables,
          'count': clickHouseTables.length,
          'total_size_mb': clickHouseTables.fold<double>(0, (sum, table) {
            final sizeMb = table['size_mb'];
            if (sizeMb is num) return sum + sizeMb.toDouble();
            return sum;
          }),
        },
        'postgresql': {
          'tables': postgreSQLTables,
          'count': postgreSQLTables.length,
          'total_size_mb': postgreSQLTables.fold<double>(0, (sum, table) {
            final sizeMb = table['size_mb'];
            if (sizeMb is num) return sum + sizeMb.toDouble();
            return sum;
          }),
        },
        'combined': {
          'total_tables': clickHouseTables.length + postgreSQLTables.length,
          'all_tables': [...clickHouseTables, ...postgreSQLTables],
        },
      };
    } catch (e) {
      throw Exception('Failed to scan both databases: $e');
    }
  }

  // ดึงรายละเอียด fields ของตาราง ClickHouse
  Future<Map<String, dynamic>> getClickHouseTableFields(
    String tableName,
  ) async {
    try {
      final result = await executeClickHouseSelect('''
        DESCRIBE TABLE $tableName
      ''');

      if (result['success'] == true && result['data'] is List) {
        final fields = List<Map<String, dynamic>>.from(result['data']);

        return {
          'table_name': tableName,
          'database_type': 'ClickHouse',
          'fields': fields,
          'field_count': fields.length,
        };
      } else {
        throw Exception(
          'No field data returned: ${result['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to get ClickHouse table fields for $tableName: $e',
      );
    }
  }

  // ดึงรายละเอียด fields ของตาราง PostgreSQL
  Future<Map<String, dynamic>> getPostgreSQLTableFields(
    String tableName,
  ) async {
    try {
      final result = await executeSelectQuery('''
        SELECT 
          column_name,
          data_type,
          is_nullable,
          column_default,
          character_maximum_length,
          numeric_precision,
          numeric_scale,
          ordinal_position
        FROM information_schema.columns 
        WHERE table_name = '$tableName' 
          AND table_schema = 'public'
        ORDER BY ordinal_position
      ''');

      if (result['success'] == true && result['data'] is List) {
        final fields = List<Map<String, dynamic>>.from(result['data']);

        return {
          'table_name': tableName,
          'database_type': 'PostgreSQL',
          'fields': fields,
          'field_count': fields.length,
        };
      } else {
        throw Exception(
          'No field data returned: ${result['error'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to get PostgreSQL table fields for $tableName: $e',
      );
    }
  }

  // ดึงรายละเอียด fields ของตารางตาม database type
  Future<Map<String, dynamic>> getTableFieldsByType(
    String tableName,
    DatabaseType dbType,
  ) async {
    switch (dbType) {
      case DatabaseType.clickhouse:
        return await getClickHouseTableFields(tableName);
      case DatabaseType.postgresql:
        return await getPostgreSQLTableFields(tableName);
    }
  }

  // ดึงข้อมูลรายละเอียดฐานข้อมูลแบบครบถ้วน
  Future<Map<String, dynamic>> getComprehensiveDatabaseInfo() async {
    try {
      final scanResult = await scanBothDatabases();
      final clickHouseData = scanResult['clickhouse'] as Map<String, dynamic>;
      final postgreSQLData = scanResult['postgresql'] as Map<String, dynamic>;
      final combinedData = scanResult['combined'] as Map<String, dynamic>;

      final clickHouseTables =
          clickHouseData['tables'] as List<Map<String, dynamic>>;
      final postgreSQLTables =
          postgreSQLData['tables'] as List<Map<String, dynamic>>;

      // คำนวณสถิติรวม
      int totalClickHouseRows = 0;
      int totalPostgreSQLRows = 0;

      for (var table in clickHouseTables) {
        totalClickHouseRows += (table['total_rows'] as int? ?? 0);
      }

      for (var table in postgreSQLTables) {
        totalPostgreSQLRows += (table['total_rows'] as int? ?? 0);
      }

      return {
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
        'summary': {
          'total_databases': 2,
          'total_tables': combinedData['total_tables'],
          'total_rows': totalClickHouseRows + totalPostgreSQLRows,
          'total_size_mb':
              clickHouseData['total_size_mb'] + postgreSQLData['total_size_mb'],
        },
        'clickhouse': {
          'status': 'connected',
          'table_count': clickHouseData['count'],
          'total_rows': totalClickHouseRows,
          'total_size_mb': clickHouseData['total_size_mb'],
          'tables': clickHouseTables,
        },
        'postgresql': {
          'status': 'connected',
          'table_count': postgreSQLData['count'],
          'total_rows': totalPostgreSQLRows,
          'total_size_mb': postgreSQLData['total_size_mb'],
          'tables': postgreSQLTables,
        },
        'all_tables': combinedData['all_tables'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get comprehensive database info: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
