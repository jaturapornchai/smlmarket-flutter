import 'lib/services/database_service.dart';

void main() async {
  final db = DatabaseService();

  try {
    // สร้างตระกร้าใหม่
    print('🛒 สร้างตระกร้าใหม่...');
    final cartResult = await db.executeCommand('''
      INSERT INTO carts (session_id, cart_status) 
      VALUES ('simple-test-456', 'active')
    ''');

    print('สร้างตระกร้า: ${cartResult['success'] ? "✅" : "❌"}');

    if (cartResult['success']) {
      // ดึง cart_id
      final cartQuery = await db.executeSelectQuery('''
        SELECT cart_id FROM carts WHERE session_id = 'simple-test-456'
      ''');

      if (cartQuery['data'] != null && (cartQuery['data'] as List).isNotEmpty) {
        final cartId = cartQuery['data'][0]['cart_id'];
        print('Cart ID: $cartId');

        // ใส่สินค้าแบบง่าย
        print('\n🛍️ ใส่สินค้าลงตระกร้า...');
        final itemResult = await db.executeCommand('''
          INSERT INTO cart_items (
            cart_id, product_id, product_name, unit_price, quantity, total_price, final_price
          ) VALUES (
            '$cartId', 'SIMPLE001', 'สินค้าง่ายๆ', 50.00, 2, 100.00, 100.00
          )
        ''');

        print('ใส่สินค้า: ${itemResult['success'] ? "✅" : "❌"}');
        if (!itemResult['success']) {
          print('Error: ${itemResult['error']}');
        }

        // ดึงข้อมูลรวม
        if (itemResult['success']) {
          print('\n📋 ดึงข้อมูลตระกร้า...');
          final cartData = await db.executeSelectQuery('''
            SELECT 
              c.cart_id, c.session_id, c.total_amount, c.item_count,
              ci.product_name, ci.quantity, ci.unit_price, ci.final_price
            FROM carts c
            LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id
            WHERE c.session_id = 'simple-test-456'
          ''');

          if (cartData['success'] && cartData['data'] != null) {
            for (var row in cartData['data']) {
              print(
                'Cart: ${row['session_id']}, Product: ${row['product_name']}, Price: ${row['final_price']}',
              );
            }
          }
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
