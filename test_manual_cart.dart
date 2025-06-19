import 'lib/services/database_service.dart';

void main() async {
  print('🧪 ทดสอบการทำงานของตาราง cart แบบง่าย');

  final DatabaseService databaseService = DatabaseService();

  try {
    // ทดสอบใส่ข้อมูลลงตาราง carts
    print('\n🛒 ใส่ข้อมูลลงตาราง carts...');
    final insertResult = await databaseService.executeCommand('''
      INSERT INTO carts (session_id, cart_status) 
      VALUES ('manual-test-123', 'active')
    ''');

    print('Insert result: ${insertResult['success'] ? "✅" : "❌"}');
    if (!insertResult['success']) {
      print('Error: ${insertResult['error']}');
    }

    // ทดสอบดึงข้อมูลจากตาราง carts
    print('\n📋 ดึงข้อมูลจากตาราง carts...');
    final selectResult = await databaseService.executeSelectQuery('''
      SELECT cart_id, session_id, cart_status, created_at FROM carts 
      WHERE session_id = 'manual-test-123'
    ''');

    print('Select result: ${selectResult['success'] ? "✅" : "❌"}');
    if (selectResult['success'] && selectResult['data'] != null) {
      final data = selectResult['data'] as List;
      print('พบข้อมูล ${data.length} รายการ');
      if (data.isNotEmpty) {
        final cart = data[0];
        print('Cart ID: ${cart['cart_id']}');
        print('Session ID: ${cart['session_id']}');
        print('Status: ${cart['cart_status']}');

        // ทดสอบใส่สินค้าลงตระกร้า
        print('\n🛍️ ใส่สินค้าลงตาราง cart_items...');
        final itemResult = await databaseService.executeCommand('''
          INSERT INTO cart_items (
            cart_id, product_id, product_name, unit_price, quantity, total_price, final_price
          ) VALUES (
            '${cart['cart_id']}', 'TEST001', 'สินค้าทดสอบ', 100.00, 1, 100.00, 100.00
          )
        ''');

        print('Item insert result: ${itemResult['success'] ? "✅" : "❌"}');
        if (!itemResult['success']) {
          print('Error: ${itemResult['error']}');
        }
      }
    }

    // ทดสอบดึงข้อมูลรวม
    print('\n📊 ดึงข้อมูลรวม cart + items...');
    final joinResult = await databaseService.executeSelectQuery('''
      SELECT c.cart_id, c.session_id, c.total_amount, ci.product_name, ci.quantity, ci.unit_price
      FROM carts c
      LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id
      WHERE c.session_id = 'manual-test-123'
    ''');

    print('Join result: ${joinResult['success'] ? "✅" : "❌"}');
    if (joinResult['success'] && joinResult['data'] != null) {
      final data = joinResult['data'] as List;
      print('พบข้อมูลรวม ${data.length} รายการ');
      for (var row in data) {
        print(
          'Cart: ${row['cart_id']}, Product: ${row['product_name'] ?? "ไม่มีสินค้า"}',
        );
      }
    }

    print('\n🎉 การทดสอบเสร็จสิ้น!');
  } catch (e) {
    print('\n💥 เกิดข้อผิดพลาด: $e');
  }
}
