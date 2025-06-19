import 'lib/services/database_service.dart';

Future<void> main() async {
  print('🔍 ทดสอบ Enhanced PostgreSQL Database Scanning...\n');

  final dbService = DatabaseService();

  try {
    // ทดสอบ 1: สแกนฐานข้อมูลพร้อมข้อมูลละเอียด
    print('1. ทดสอบการสแกนฐานข้อมูลพร้อมสถิติ...');
    final tables = await dbService.scanDatabase();

    if (tables.isNotEmpty) {
      print('✅ พบ ${tables.length} ตาราง:');
      for (final table in tables) {
        final tableName = table['table_name'] ?? table['name'] ?? 'Unknown';
        final rows = table['total_rows'] ?? 0;
        final sizeMb = table['size_mb'] ?? 0.0;

        print('   📊 $tableName: $rows แถว, ${sizeMb}MB');
      }
    } else {
      print('❌ ไม่พบตารางในฐานข้อมูล');
    }

    print('');

    // ทดสอบ 2: ดูรายละเอียด fields ของตารางแรก
    if (tables.isNotEmpty) {
      final firstTable = tables.first;
      final tableName = firstTable['table_name'] ?? firstTable['name'] ?? '';

      if (tableName.isNotEmpty) {
        print('2. ทดสอบการดู fields ของตาราง: $tableName');

        try {
          final tableFields = await dbService.getTableFields(tableName);
          final fields =
              tableFields['fields'] as List<Map<String, dynamic>>? ?? [];
          final primaryKeys =
              tableFields['primary_keys'] as List<String>? ?? [];

          print('✅ ตาราง $tableName มี ${fields.length} fields:');

          for (final field in fields) {
            final name = field['column_name'];
            final type = field['data_type'];
            final nullable = field['is_nullable'] == 'YES'
                ? 'NULL'
                : 'NOT NULL';
            final isPrimary = primaryKeys.contains(name) ? ' 🔑' : '';

            print('   📋 $name: $type $nullable$isPrimary');
          }

          if (primaryKeys.isNotEmpty) {
            print('   🔑 Primary Keys: ${primaryKeys.join(', ')}');
          }
        } catch (e) {
          print('❌ เกิดข้อผิดพลาดในการดู fields: $e');
        }

        print('');

        // ทดสอบ 3: ดูสถิติของตาราง
        print('3. ทดสอบการดูสถิติของตาราง: $tableName');

        try {
          final stats = await dbService.getTableStatistics(tableName);

          print('✅ สถิติตาราง $tableName:');
          print('   📊 จำนวนแถว: ${stats['total_rows']}');
          print('   💾 ขนาด: ${stats['size_pretty']} (${stats['size_mb']} MB)');
          print('   📏 ขนาดเฉลี่ยต่อแถว: ${stats['average_row_size']} bytes');
        } catch (e) {
          print('❌ เกิดข้อผิดพลาดในการดูสถิติ: $e');
        }
      }
    }
  } catch (e) {
    print('❌ เกิดข้อผิดพลาด: $e');
  }

  print('\n🏁 การทดสอบ Enhanced Database Scanning เสร็จสิ้น!');
}
