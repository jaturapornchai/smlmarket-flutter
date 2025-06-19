import 'package:smlmarket/services/database_service.dart';

void main() async {
  print('=== ทดสอบฟังก์ชันฐานข้อมูลใหม่ ===');

  final dbService = DatabaseService();

  try {
    // ทดสอบการตรวจสอบสุขภาพ
    print('\n1. ตรวจสอบสุขภาพฐานข้อมูล...');
    final health = await dbService.checkHealth();
    print('สถานะ: ${health['status'] ?? 'ไม่ทราบ'}');

    // ทดสอบการสแกนฐานข้อมูลแบบครบถ้วน
    print('\n2. สแกนฐานข้อมูลแบบครบถ้วน...');
    final comprehensiveInfo = await dbService.getComprehensiveDatabaseInfo();

    if (comprehensiveInfo['success'] == true) {
      final summary = comprehensiveInfo['summary'];
      print('สรุป:');
      print('  - ฐานข้อมูลทั้งหมด: ${summary['total_databases']}');
      print('  - ตารางทั้งหมด: ${summary['total_tables']}');
      print('  - แถวข้อมูลทั้งหมด: ${summary['total_rows']}');
      print('  - ขนาดรวม: ${summary['total_size_mb']} MB');

      // แสดงรายละเอียด ClickHouse
      final clickhouse = comprehensiveInfo['clickhouse'];
      print('\nClickHouse:');
      print('  - สถานะ: ${clickhouse['status']}');
      print('  - จำนวนตาราง: ${clickhouse['table_count']}');
      print('  - แถวข้อมูล: ${clickhouse['total_rows']}');
      print('  - ขนาด: ${clickhouse['total_size_mb']} MB');

      // แสดงรายละเอียด PostgreSQL
      final postgresql = comprehensiveInfo['postgresql'];
      print('\nPostgreSQL:');
      print('  - สถานะ: ${postgresql['status']}');
      print('  - จำนวนตาราง: ${postgresql['table_count']}');
      print('  - แถวข้อมูล: ${postgresql['total_rows']}');
      print('  - ขนาด: ${postgresql['total_size_mb']} MB');

      // แสดงตารางทั้งหมด
      final allTables = comprehensiveInfo['all_tables'] as List;
      print('\n3. รายการตารางทั้งหมด (${allTables.length} ตาราง):');

      final clickhouseTables = allTables
          .where((t) => t['database_type'] == 'ClickHouse')
          .toList();
      final postgresqlTables = allTables
          .where((t) => t['database_type'] == 'PostgreSQL')
          .toList();

      if (clickhouseTables.isNotEmpty) {
        print('\n  ClickHouse Tables:');
        for (var table in clickhouseTables) {
          print(
            '    - ${table['table_name'] ?? table['name']}: ${table['total_rows']} rows, ${table['engine']}',
          );
        }
      }

      if (postgresqlTables.isNotEmpty) {
        print('\n  PostgreSQL Tables:');
        for (var table in postgresqlTables) {
          print(
            '    - ${table['table_name'] ?? table['name']}: ${table['total_rows']} rows, ${table['engine']}',
          );
        }
      }

      // ทดสอบการดึงข้อมูล fields
      if (allTables.isNotEmpty) {
        print('\n4. ทดสอบการดึงข้อมูล fields...');
        final testTable = allTables.first;
        final tableName = testTable['table_name'] ?? testTable['name'];
        final dbType = testTable['database_type'];

        print('กำลังดึงข้อมูล fields ของตาราง: $tableName ($dbType)');

        try {
          Map<String, dynamic> fieldsData;
          if (dbType == 'ClickHouse') {
            fieldsData = await dbService.getClickHouseTableFields(tableName);
          } else {
            fieldsData = await dbService.getPostgreSQLTableFields(tableName);
          }

          final fields = fieldsData['fields'] as List;
          print('พบ ${fields.length} fields:');
          for (var field in fields.take(5)) {
            // แสดงแค่ 5 ตัวแรก
            print(
              '  - ${field['name'] ?? field['column_name']}: ${field['type'] ?? field['data_type']}',
            );
          }
          if (fields.length > 5) {
            print('  ... และอีก ${fields.length - 5} fields');
          }
        } catch (e) {
          print('ไม่สามารถดึงข้อมูล fields ได้: $e');
        }
      }
    } else {
      print('ไม่สามารถสแกนฐานข้อมูลได้: ${comprehensiveInfo['error']}');
    }
  } catch (e) {
    print('เกิดข้อผิดพลาด: $e');
  }

  print('\n=== การทดสอบเสร็จสิ้น ===');
}
