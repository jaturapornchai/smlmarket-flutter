import 'lib/services/database_service.dart';

void main() async {
  final db = DatabaseService();

  try {
    print('🧪 ดีบัก cart service ทีละขั้นตอน');
    final sessionId = 'debug-session-123';

    // ขั้นตอน 1: หาตระกร้า active
    print('\n1️⃣ หาตระกร้า active...');
    final findResult = await db.executeSelectQuery('''
      SELECT cart_id FROM carts 
      WHERE cart_status = 'active' AND session_id = '$sessionId'
      ORDER BY created_at DESC 
      LIMIT 1
    ''');

    print('Find result: ${findResult['success']}');
    if (findResult['data'] != null && (findResult['data'] as List).isNotEmpty) {
      print('พบตระกร้า: ${findResult['data'][0]['cart_id']}');
    } else {
      print('ไม่พบตระกร้า, จะสร้างใหม่');

      // ขั้นตอน 2: สร้างตระกร้าใหม่
      print('\n2️⃣ สร้างตระกร้าใหม่...');
      final createResult = await db.executeCommand('''
        INSERT INTO carts (session_id)
        VALUES ('$sessionId')
      ''');

      print('Create result: ${createResult['success']}');

      if (createResult['success']) {
        // หา cart_id ที่เพิ่งสร้าง
        final newCartResult = await db.executeSelectQuery('''
          SELECT cart_id FROM carts 
          WHERE session_id = '$sessionId'
          ORDER BY created_at DESC 
          LIMIT 1
        ''');

        if (newCartResult['data'] != null &&
            (newCartResult['data'] as List).isNotEmpty) {
          final cartId = newCartResult['data'][0]['cart_id'];
          print('Cart ID ใหม่: $cartId');

          // ขั้นตอน 3: เพิ่มสินค้า
          print('\n3️⃣ เพิ่มสินค้าลงตระกร้า...');
          final addItemResult = await db.executeCommand('''
            INSERT INTO cart_items (
              cart_id, product_id, product_name, unit_price, quantity, total_price, final_price
            ) VALUES (
              '$cartId', 'DEBUG001', 'สินค้าดีบัก', 75.00, 1, 75.00, 75.00
            )
          ''');

          print('Add item result: ${addItemResult['success']}');

          if (addItemResult['success']) {
            // ขั้นตอน 4: อัปเดตยอดรวม
            print('\n4️⃣ อัปเดตยอดรวมในตระกร้า...');
            final updateResult = await db.executeCommand('''
              UPDATE carts 
              SET item_count = 1,
                  total_amount = 75.00,
                  final_amount = 75.00,
                  updated_at = CURRENT_TIMESTAMP
              WHERE cart_id = '$cartId'
            ''');

            print('Update result: ${updateResult['success']}');

            // ขั้นตอน 5: ดึงข้อมูลตระกร้าเพื่อตรวจสอบ
            print('\n5️⃣ ดึงข้อมูลตระกร้าเพื่อตรวจสอบ...');
            final finalResult = await db.executeSelectQuery('''
              SELECT 
                c.cart_id, c.session_id, c.total_amount, c.item_count,
                ci.product_name, ci.quantity, ci.final_price
              FROM carts c
              LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id
              WHERE c.session_id = '$sessionId'
            ''');

            if (finalResult['success'] && finalResult['data'] != null) {
              print('ข้อมูลตระกร้า:');
              for (var row in finalResult['data']) {
                print('  Cart: ${row['cart_id']}');
                print('  Session: ${row['session_id']}');
                print('  Total: ${row['total_amount']}');
                print('  Items: ${row['item_count']}');
                print(
                  '  Product: ${row['product_name']} x ${row['quantity']} = ${row['final_price']}',
                );
              }

              print('\n✅ ทุกขั้นตอนสำเร็จ!');
            }
          }
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
