import 'lib/services/database_service.dart';

Future<void> main() async {
  print('🔍 ทดสอบ Dual Database Scanning (ClickHouse + PostgreSQL)...\n');

  final dbService = DatabaseService();

  try {
    // ทดสอบ Health Check
    print('1. ทดสอบ Health Check...');
    final health = await dbService.checkHealth();
    print('✅ Health Status: ${health['status']}');
    print('   📄 Version: ${health['version']}');
    print('');

    // ทดสอบการสแกนฐานข้อมูลทั้งสองแบบ
    print('2. ทดสอบการสแกนฐานข้อมูลทั้ง ClickHouse และ PostgreSQL...');
    final scanResult = await dbService.scanBothDatabases();

    // แสดงผล ClickHouse
    final clickHouseData = scanResult['clickhouse'] as Map<String, dynamic>;
    final clickHouseTables =
        clickHouseData['tables'] as List<Map<String, dynamic>>;
    print('📊 ClickHouse Database:');
    print('   ตาราง: ${clickHouseData['count']} ตาราง');
    print('   ขนาดรวม: ${clickHouseData['total_size_mb']} MB');

    if (clickHouseTables.isNotEmpty) {
      print('   รายการตาราง:');
      for (final table in clickHouseTables.take(5)) {
        print(
          '     🗃️  ${table['table_name']}: ${table['total_rows']} แถว, ${table['size_mb']} MB',
        );
      }
      if (clickHouseTables.length > 5) {
        print('     ... และอีก ${clickHouseTables.length - 5} ตาราง');
      }
    }
    print('');

    // แสดงผล PostgreSQL
    final postgreSQLData = scanResult['postgresql'] as Map<String, dynamic>;
    final postgreSQLTables =
        postgreSQLData['tables'] as List<Map<String, dynamic>>;
    print('🐘 PostgreSQL Database:');
    print('   ตาราง: ${postgreSQLData['count']} ตาราง');
    print('   ขนาดรวม: ${postgreSQLData['total_size_mb']} MB');

    if (postgreSQLTables.isNotEmpty) {
      print('   รายการตาราง:');
      for (final table in postgreSQLTables.take(5)) {
        print(
          '     🗃️  ${table['table_name']}: ${table['total_rows']} แถว, ${table['size_mb']} MB',
        );
      }
      if (postgreSQLTables.length > 5) {
        print('     ... และอีก ${postgreSQLTables.length - 5} ตาราง');
      }
    }
    print('');

    // แสดงสรุปรวม
    final combinedData = scanResult['combined'] as Map<String, dynamic>;
    print('📈 สรุปรวม:');
    print('   ตารางทั้งหมด: ${combinedData['total_tables']} ตาราง');
    print('   - ClickHouse: ${clickHouseData['count']} ตาราง');
    print('   - PostgreSQL: ${postgreSQLData['count']} ตาราง');
    print('');

    // ทดสอบดูรายละเอียด fields ของตารางแรกในแต่ละฐานข้อมูล
    if (clickHouseTables.isNotEmpty) {
      print('3. ทดสอบดู fields ของตาราง ClickHouse...');
      final firstClickHouseTable = clickHouseTables.first['table_name'];
      try {
        final fields = await dbService.getClickHouseTableFields(
          firstClickHouseTable,
        );
        final fieldList = fields['fields'] as List<Map<String, dynamic>>;
        print(
          '✅ ตาราง $firstClickHouseTable (ClickHouse) มี ${fieldList.length} fields:',
        );
        for (final field in fieldList.take(5)) {
          print('   📋 ${field['name']}: ${field['type']}');
        }
        if (fieldList.length > 5) {
          print('   ... และอีก ${fieldList.length - 5} fields');
        }
      } catch (e) {
        print('❌ เกิดข้อผิดพลาดในการดู ClickHouse fields: $e');
      }
      print('');
    }

    if (postgreSQLTables.isNotEmpty) {
      print('4. ทดสอบดู fields ของตาราง PostgreSQL...');
      final firstPostgreSQLTable = postgreSQLTables.first['table_name'];
      try {
        final fields = await dbService.getPostgreSQLTableFields(
          firstPostgreSQLTable,
        );
        final fieldList = fields['fields'] as List<Map<String, dynamic>>;
        print(
          '✅ ตาราง $firstPostgreSQLTable (PostgreSQL) มี ${fieldList.length} fields:',
        );
        for (final field in fieldList.take(5)) {
          final nullable = field['is_nullable'] == 'YES'
              ? ' (NULL)'
              : ' (NOT NULL)';
          print(
            '   📋 ${field['column_name']}: ${field['data_type']}$nullable',
          );
        }
        if (fieldList.length > 5) {
          print('   ... และอีก ${fieldList.length - 5} fields');
        }
      } catch (e) {
        print('❌ เกิดข้อผิดพลาดในการดู PostgreSQL fields: $e');
      }
      print('');
    }
  } catch (e) {
    print('❌ เกิดข้อผิดพลาด: $e');
  }

  print('🏁 การทดสอบ Dual Database Scanning เสร็จสิ้น!');
}
