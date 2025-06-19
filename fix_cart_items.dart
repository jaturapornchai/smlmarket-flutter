import 'lib/services/database_service.dart';

void main() async {
  final db = DatabaseService();

  try {
    print('🔄 ลบและสร้างตาราง cart_items ใหม่...');

    // ลบตารางเก่า
    await db.executeCommand('DROP TABLE IF EXISTS cart_items');

    // สร้างตารางใหม่
    final result = await db.executeCommand('''
      CREATE TABLE cart_items (
        cart_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        cart_id UUID NOT NULL,
        product_id VARCHAR(50) NOT NULL,
        product_name VARCHAR(255) NOT NULL,
        product_code VARCHAR(100),
        unit_price DECIMAL(15,2) NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        total_price DECIMAL(15,2) NOT NULL,
        discount_percent DECIMAL(5,2) DEFAULT 0.00,
        discount_amount DECIMAL(15,2) DEFAULT 0.00,
        final_price DECIMAL(15,2) NOT NULL,
        product_options JSONB,
        notes TEXT,
        added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        
        CHECK (quantity > 0),
        CHECK (unit_price >= 0),
        CHECK (total_price >= 0),
        CHECK (final_price >= 0)
      )
    ''');

    print('สร้างตาราง: ${result['success'] ? "✅ สำเร็จ" : "❌ ล้มเหลว"}');

    // ทดสอบใส่ข้อมูล
    print('\n🧪 ทดสอบใส่ข้อมูล...');
    final testResult = await db.executeCommand('''
      INSERT INTO cart_items (
        cart_id, product_id, product_name, unit_price, quantity, total_price, final_price
      ) VALUES (
        'dd7ef71a-0693-4e0e-855a-a90d5c15b625', 'TEST001', 'สินค้าทดสอบ', 100.00, 1, 100.00, 100.00
      )
    ''');

    print('ใส่ข้อมูล: ${testResult['success'] ? "✅ สำเร็จ" : "❌ ล้มเหลว"}');
    if (!testResult['success']) {
      print('Error: ${testResult['error']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
