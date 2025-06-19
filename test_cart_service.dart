import 'lib/services/cart_service.dart';

void main() async {
  print('🛒 ทดสอบระบบตระกร้าสินค้า');

  final CartService cartService = CartService();

  try {
    final sessionId = 'test-session-${DateTime.now().millisecondsSinceEpoch}';
    print('Session ID: $sessionId');

    // 1. ทดสอบเพิ่มสินค้าลงตระกร้า
    print('\n📦 เพิ่มสินค้าลงตระกร้า...');
    final addResult1 = await cartService.addToCart(
      sessionId: sessionId,
      productId: 'PROD001',
      productName: 'สินค้าทดสอบ 1',
      productCode: 'TEST001',
      unitPrice: 100.0,
      quantity: 2,
    );

    print(
      'เพิ่มสินค้า 1: ${addResult1['success'] ? "✅" : "❌"} ${addResult1['message']}',
    );

    // 2. เพิ่มสินค้าอีกชิ้น
    final addResult2 = await cartService.addToCart(
      sessionId: sessionId,
      productId: 'PROD002',
      productName: 'สินค้าทดสอบ 2',
      productCode: 'TEST002',
      unitPrice: 150.0,
      quantity: 1,
    );

    print(
      'เพิ่มสินค้า 2: ${addResult2['success'] ? "✅" : "❌"} ${addResult2['message']}',
    );

    // 3. ดึงข้อมูลตระกร้า
    print('\n📋 ดึงข้อมูลตระกร้า...');
    final cartData = await cartService.getCart(sessionId: sessionId);

    print('ตระกร้า: ${cartData['cart'] != null ? "✅ พบ" : "❌ ไม่พบ"}');
    print('จำนวนสินค้า: ${cartData['item_count']} รายการ');
    print('ยอดรวม: ${cartData['total_amount']} บาท');

    if (cartData['items'] != null) {
      print('รายการสินค้า:');
      for (var item in cartData['items']) {
        print(
          '  - ${item['product_name']}: ${item['quantity']} x ${item['unit_price']} = ${item['final_price']} บาท',
        );
      }
    }

    // 4. ทดสอบสถิติ
    print('\n📊 ดึงสถิติตระกร้า...');
    final stats = await cartService.getCartStatistics();

    if (stats['success'] == true) {
      final statistics = stats['statistics'];
      print('สถิติตระกร้า:');
      print('  - ตระกร้าทั้งหมด: ${statistics['total_carts']}');
      print('  - ตระกร้าที่ใช้งาน: ${statistics['active_carts']}');
      print(
        '  - มูลค่าเฉลี่ย: ${double.tryParse(statistics['avg_cart_value']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0'} บาท',
      );
    }

    print('\n🎉 การทดสอบ cart service เสร็จสิ้น!');
  } catch (e) {
    print('\n💥 เกิดข้อผิดพลาดในการทดสอบ cart service: $e');
  }
}
