import 'lib/services/database_service.dart';

void main() async {
  print('🧪 ทดสอบสร้างตารางแยกทีละตาราง');

  final DatabaseService databaseService = DatabaseService();

  try {
    // ทดสอบสร้างตาราง carts
    print('\n🛒 ทดสอบสร้างตาราง carts...');
    final cartResult = await databaseService.executeCommand('''
      CREATE TABLE IF NOT EXISTS carts (
        cart_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        customer_id UUID,
        session_id VARCHAR(255),
        cart_status VARCHAR(20) DEFAULT 'active',
        total_amount DECIMAL(15,2) DEFAULT 0.00,
        item_count INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    if (cartResult['success'] == true) {
      print('✅ สร้างตาราง carts สำเร็จ');
    } else {
      print('❌ ไม่สามารถสร้างตาราง carts ได้');
      print('Error: ${cartResult['error']}');
    }

    // ทดสอบสร้างตาราง cart_items
    print('\n🛍️ ทดสอบสร้างตาราง cart_items...');
    final itemResult = await databaseService.executeCommand('''
      CREATE TABLE IF NOT EXISTS cart_items (
        cart_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        cart_id UUID NOT NULL,
        product_id VARCHAR(50) NOT NULL,
        product_name VARCHAR(255) NOT NULL,
        unit_price DECIMAL(15,2) NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        total_price DECIMAL(15,2) NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    if (itemResult['success'] == true) {
      print('✅ สร้างตาราง cart_items สำเร็จ');
    } else {
      print('❌ ไม่สามารถสร้างตาราง cart_items ได้');
      print('Error: ${itemResult['error']}');
    }

    // ทดสอบใส่ข้อมูลตัวอย่าง
    print('\n📝 ทดสอบใส่ข้อมูลลงตาราง carts...');
    final insertResult = await databaseService.executeCommand('''
      INSERT INTO carts (session_id, cart_status) 
      VALUES ('test-session-123', 'active')
    ''');

    if (insertResult['success'] == true) {
      print('✅ ใส่ข้อมูลสำเร็จ');
    } else {
      print('❌ ไม่สามารถใส่ข้อมูลได้');
      print('Error: ${insertResult['error']}');
    }

    // ทดสอบดึงข้อมูล
    print('\n📊 ทดสอบดึงข้อมูลจากตาราง carts...');
    final selectResult = await databaseService.executeSelectQuery('''
      SELECT * FROM carts LIMIT 5
    ''');

    if (selectResult['success'] == true) {
      print('✅ ดึงข้อมูลสำเร็จ');
      print('ข้อมูลที่ได้: ${selectResult['data']?.length ?? 0} แถว');
    } else {
      print('❌ ไม่สามารถดึงข้อมูลได้');
      print('Error: ${selectResult['error']}');
    }
  } catch (e) {
    print('\n💥 เกิดข้อผิดพลาด: $e');
  }
}
