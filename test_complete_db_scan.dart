import 'lib/services/database_service.dart';

Future<void> main() async {
  print('🔍 ทดสอบ Complete Database Scanning...\n');

  final dbService = DatabaseService();

  try {
    // ทดสอบ 1: สแกนฐานข้อมูลทั้งหมด (ฟังก์ชันหลัก)
    print('1. ทดสอบการสแกนฐานข้อมูลทั้งหมด (scanDatabase)...');
    final allTables = await dbService.scanDatabase();

    if (allTables.isNotEmpty) {
      print('✅ พบ ${allTables.length} ตารางทั้งหมด:');

      // แยกตาม database type
      final clickHouseTables = allTables
          .where((table) => table['database_type'] == 'ClickHouse')
          .toList();
      final postgreSQLTables = allTables
          .where((table) => table['database_type'] == 'PostgreSQL')
          .toList();

      print('   📊 ClickHouse: ${clickHouseTables.length} ตาราง');
      print('   🐘 PostgreSQL: ${postgreSQLTables.length} ตาราง');

      // แสดงตาราง Top 5 ตามขนาด
      allTables.sort((a, b) {
        final aSize = a['size_mb'] ?? 0;
        final bSize = b['size_mb'] ?? 0;
        if (aSize is String) return -1;
        if (bSize is String) return 1;
        return bSize.compareTo(aSize);
      });

      print('\n   🏆 Top 5 ตารางที่ใหญ่ที่สุด:');
      for (var i = 0; i < allTables.length && i < 5; i++) {
        final table = allTables[i];
        final dbType = table['database_type'] ?? 'Unknown';
        final name = table['table_name'] ?? table['name'] ?? 'Unknown';
        final rows = table['total_rows'] ?? 0;
        final size = table['size_mb'] ?? 0;
        final icon = dbType == 'ClickHouse' ? '📊' : '🐘';
        print('     ${i + 1}. $icon $name ($dbType): $rows แถว, ${size} MB');
      }
    } else {
      print('❌ ไม่พบตารางใดๆ');
    }

    print('');

    // ทดสอบ 2: ข้อมูลครบถ้วนของฐานข้อมูล
    print('2. ทดสอบการดึงข้อมูลครบถ้วนของฐานข้อมูล...');
    final comprehensiveInfo = await dbService.getComprehensiveDatabaseInfo();

    if (comprehensiveInfo['success'] == true) {
      final summary = comprehensiveInfo['summary'] as Map<String, dynamic>;
      final clickhouse =
          comprehensiveInfo['clickhouse'] as Map<String, dynamic>;
      final postgresql =
          comprehensiveInfo['postgresql'] as Map<String, dynamic>;

      print('✅ ข้อมูลฐานข้อมูลครบถ้วน:');
      print('   📈 สรุปรวม:');
      print('     - ฐานข้อมูล: ${summary['total_databases']} ฐาน');
      print('     - ตาราง: ${summary['total_tables']} ตาราง');
      print('     - แถวข้อมูล: ${summary['total_rows']} แถว');
      print('     - ขนาดรวม: ${summary['total_size_mb']} MB');

      print('   📊 ClickHouse:');
      print('     - สถานะ: ${clickhouse['status']}');
      print('     - ตาราง: ${clickhouse['table_count']} ตาราง');
      print('     - แถวข้อมูล: ${clickhouse['total_rows']} แถว');
      print('     - ขนาด: ${clickhouse['total_size_mb']} MB');

      print('   🐘 PostgreSQL:');
      print('     - สถานะ: ${postgresql['status']}');
      print('     - ตาราง: ${postgresql['table_count']} ตาราง');
      print('     - แถวข้อมูล: ${postgresql['total_rows']} แถว');
      print('     - ขนาด: ${postgresql['total_size_mb']} MB');
    } else {
      print('❌ เกิดข้อผิดพลาด: ${comprehensiveInfo['error']}');
    }

    print('');

    // ทดสอบ 3: ทดสอบดูรายละเอียด field ของตารางยอดนิยม
    if (allTables.isNotEmpty) {
      print('3. ทดสอบดูรายละเอียด fields ของตารางที่มีข้อมูลมากที่สุด...');

      // หาตารางที่มีข้อมูลมากที่สุด
      allTables.sort((a, b) {
        final aRows = a['total_rows'] ?? 0;
        final bRows = b['total_rows'] ?? 0;
        return bRows.compareTo(aRows);
      });

      final topTable = allTables.first;
      final tableName = topTable['table_name'] ?? topTable['name'] ?? '';
      final dbType = topTable['database_type'] ?? 'Unknown';

      if (tableName.isNotEmpty) {
        try {
          Map<String, dynamic> fields;
          if (dbType == 'ClickHouse') {
            fields = await dbService.getClickHouseTableFields(tableName);
          } else {
            fields = await dbService.getPostgreSQLTableFields(tableName);
          }

          final fieldList = fields['fields'] as List<Map<String, dynamic>>;
          print('✅ ตาราง $tableName ($dbType) มี ${fieldList.length} fields:');

          for (var i = 0; i < fieldList.length && i < 10; i++) {
            final field = fieldList[i];
            if (dbType == 'ClickHouse') {
              print('     📋 ${field['name']}: ${field['type']}');
            } else {
              final nullable = field['is_nullable'] == 'YES'
                  ? ' (NULL)'
                  : ' (NOT NULL)';
              print(
                '     📋 ${field['column_name']}: ${field['data_type']}$nullable',
              );
            }
          }

          if (fieldList.length > 10) {
            print('     ... และอีก ${fieldList.length - 10} fields');
          }
        } catch (e) {
          print('❌ เกิดข้อผิดพลาดในการดู fields: $e');
        }
      }
    }
  } catch (e) {
    print('❌ เกิดข้อผิดพลาดหลัก: $e');
  }

  print('\n🏁 การทดสอบ Complete Database Scanning เสร็จสิ้น!');
}
