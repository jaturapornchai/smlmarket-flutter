import 'lib/services/database_service.dart';

void main() async {
  print('🚀 เริ่มทดสอบระบบ PostgreSQL ครบครัน');

  final DatabaseService databaseService = DatabaseService();

  try {
    // 1. ตรวจสอบสุขภาพฐานข้อมูล
    print('\n📊 ตรวจสอบสุขภาพฐานข้อมูล...');
    final healthResult = await databaseService.checkHealth();
    print('สุขภาพฐานข้อมูล: ${healthResult['status']}');

    // 2. สร้างตารางทั้งหมดใน PostgreSQL
    print('\n🏗️ กำลังสร้างตารางทั้งหมดใน PostgreSQL...');
    final createResult = await databaseService.createAllPostgreSQLTables();

    if (createResult['success'] == true) {
      print('✅ สร้างตารางทั้งหมดสำเร็จ!');
      print('ข้อความ: ${createResult['message']}');
    } else {
      print('❌ เกิดข้อผิดพลาดในการสร้างตาราง');
      print('ข้อผิดพลาด: ${createResult['error']}');
    }

    // 3. สแกนฐานข้อมูล PostgreSQL
    print('\n🔍 กำลังสแกนฐานข้อมูล PostgreSQL...');
    final tables = await databaseService.scanDatabase();
    print('พบตาราง ${tables.length} ตารางใน PostgreSQL:');

    for (var table in tables) {
      print(
        '  📋 ${table['table_name']} (${table['total_rows']} แถว, ${table['size_mb']} MB)',
      );
    }

    // 4. ตรวจสอบตารางที่สำคัญ
    print('\n🔎 ตรวจสอบตารางที่สำคัญ...');
    final importantTables = [
      'customers',
      'carts',
      'cart_items',
      'coupons',
      'coupon_usages',
      'orders',
      'order_items',
      'order_status_history',
    ];

    for (String tableName in importantTables) {
      try {
        final fields = await databaseService.getTableFields(tableName);
        print('  ✅ $tableName: ${fields['field_count']} fields');
      } catch (e) {
        print('  ❌ $tableName: ยังไม่ได้สร้าง หรือ มีปัญหา');
      }
    }

    // 5. ทดสอบการใส่ข้อมูลตัวอย่าง
    print('\n📝 ทดสอบการใส่ข้อมูลตัวอย่าง...');

    // ทดสอบใส่ลูกค้าตัวอย่าง
    try {
      await databaseService.executeCommand('''
        INSERT INTO customers (first_name, last_name, email, phone) 
        VALUES ('ทดสอบ', 'ผู้ใช้', 'test@example.com', '0812345678')
        ON CONFLICT (email) DO NOTHING
      ''');
      print('  ✅ ใส่ข้อมูลลูกค้าตัวอย่างสำเร็จ');
    } catch (e) {
      print('  ⚠️ ไม่สามารถใส่ข้อมูลลูกค้า: $e');
    }

    // 6. ทดสอบการนับข้อมูล
    print('\n📊 สถิติข้อมูลในตาราง:');
    for (String tableName in importantTables) {
      try {
        final countResult = await databaseService.executeSelectQuery('''
          SELECT COUNT(*) as total FROM $tableName
        ''');
        final count = countResult['data'][0]['total'];
        print('  📈 $tableName: $count แถว');
      } catch (e) {
        print('  ❌ $tableName: ไม่สามารถนับได้');
      }
    }

    print('\n🎉 การทดสอบเสร็จสิ้น! ระบบ PostgreSQL พร้อมใช้งาน');
  } catch (e) {
    print('\n💥 เกิดข้อผิดพลาดในการทดสอบ: $e');
  }
}
