import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🔍 ทดสอบ PostgreSQL Database Scanning...\n');

  const String baseUrl = 'http://192.168.2.36:8008';

  // ทดสอบ: PostgreSQL Information Schema Query
  print('ทดสอบ PostgreSQL Information Schema...');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/pgselect'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': '''
          SELECT 
            table_name,
            'PostgreSQL' as engine,
            0 as total_rows,
            0 as total_bytes
          FROM information_schema.tables 
          WHERE table_schema = 'public'
          ORDER BY table_name
        ''',
      }),
    );

    if (response.statusCode == 200) {
      print('✅ PostgreSQL Information Schema: สำเร็จ');
      final data = jsonDecode(response.body);
      print('   📊 จำนวนตาราง: ${data['data']?.length ?? 0}');
      if (data['data'] != null && data['data'].isNotEmpty) {
        print('   📄 ตารางที่พบ:');
        for (var table in data['data']) {
          print('     - ${table['table_name']}');
        }
      }
    } else {
      print('❌ PostgreSQL Query: ล้มเหลว (${response.statusCode})');
      print('   📄 Response: ${response.body}');
    }
  } catch (e) {
    print('❌ PostgreSQL Query: เกิดข้อผิดพลาด - $e');
  }

  print('\n');

  // ทดสอบ: ตรวจสอบ columns ของตาราง customers (ถ้ามี)
  print('ทดสอบการตรวจสอบโครงสร้างตาราง customers...');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/pgselect'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': '''
          SELECT 
            column_name,
            data_type,
            is_nullable,
            column_default
          FROM information_schema.columns 
          WHERE table_name = 'customers' AND table_schema = 'public'
          ORDER BY ordinal_position
        ''',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        print('✅ ตาราง customers: พบแล้ว');
        print('   📊 จำนวน columns: ${data['data']?.length ?? 0}');
        print('   📄 โครงสร้าง:');
        for (var column in data['data']) {
          print(
            '     - ${column['column_name']}: ${column['data_type']} (${column['is_nullable'] == 'YES' ? 'nullable' : 'not null'})',
          );
        }
      } else {
        print('ℹ️  ตาราง customers: ยังไม่ได้สร้าง');
      }
    } else {
      print('❌ Table Structure Query: ล้มเหลว (${response.statusCode})');
      print('   📄 Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Table Structure Query: เกิดข้อผิดพลาด - $e');
  }

  print('\n🏁 การทดสอบ PostgreSQL Database Scanning เสร็จสิ้น!');
}
