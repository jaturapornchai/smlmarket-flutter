import 'lib/services/database_service.dart';

void main() async {
  print('🧪 ทดสอบสร้างตารางที่เหลือ');

  final DatabaseService databaseService = DatabaseService();

  try {
    // ทดสอบสร้างตาราง coupons
    print('\n🎟️ สร้างตาราง coupons...');
    final couponResult = await databaseService.executeCommand('''
      CREATE TABLE IF NOT EXISTS coupons (
        coupon_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        coupon_code VARCHAR(50) UNIQUE NOT NULL,
        coupon_name VARCHAR(255) NOT NULL,
        description TEXT,
        discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed_amount', 'free_shipping')),
        discount_value DECIMAL(15,2) NOT NULL,
        minimum_amount DECIMAL(15,2) DEFAULT 0.00,
        maximum_discount DECIMAL(15,2),
        usage_limit INTEGER,
        usage_count INTEGER DEFAULT 0,
        customer_usage_limit INTEGER DEFAULT 1,
        start_date TIMESTAMP WITH TIME ZONE,
        end_date TIMESTAMP WITH TIME ZONE,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        
        CHECK (discount_value > 0),
        CHECK (minimum_amount >= 0),
        CHECK (usage_limit IS NULL OR usage_limit > 0),
        CHECK (customer_usage_limit > 0)
      )
    ''');

    print('Result: ${couponResult['success'] ? "✅ สำเร็จ" : "❌ ล้มเหลว"}');

    // ทดสอบสร้างตาราง orders
    print('\n📦 สร้างตาราง orders...');
    final orderResult = await databaseService.executeCommand('''
      CREATE TABLE IF NOT EXISTS orders (
        order_id VARCHAR(50) PRIMARY KEY,
        customer_id UUID,
        cart_id UUID,
        order_number VARCHAR(50) UNIQUE NOT NULL,
        order_status VARCHAR(20) DEFAULT 'pending',
        payment_status VARCHAR(20) DEFAULT 'pending',
        shipping_status VARCHAR(20) DEFAULT 'pending',
        
        customer_email VARCHAR(255),
        customer_phone VARCHAR(20),
        customer_name VARCHAR(200),
        
        subtotal DECIMAL(15,2) NOT NULL DEFAULT 0.00,
        discount_amount DECIMAL(15,2) DEFAULT 0.00,
        tax_amount DECIMAL(15,2) DEFAULT 0.00,
        shipping_amount DECIMAL(15,2) DEFAULT 0.00,
        total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
        currency_code VARCHAR(3) DEFAULT 'THB',
        
        order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    print('Result: ${orderResult['success'] ? "✅ สำเร็จ" : "❌ ล้มเหลว"}');

    // ทดสอบใส่คูปองตัวอย่าง
    print('\n📝 ใส่คูปองตัวอย่าง...');
    final insertCoupon = await databaseService.executeCommand('''
      INSERT INTO coupons (coupon_code, coupon_name, discount_type, discount_value) 
      VALUES ('WELCOME10', 'ส่วนลดต้อนรับ 10%', 'percentage', 10.00)
      ON CONFLICT (coupon_code) DO NOTHING
    ''');

    print('Result: ${insertCoupon['success'] ? "✅ สำเร็จ" : "❌ ล้มเหลว"}');

    // ทดสอบสร้าง trigger function
    print('\n⚙️ สร้าง trigger function...');
    final triggerResult = await databaseService.executeCommand('''
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS \$\$
      BEGIN
          NEW.updated_at = CURRENT_TIMESTAMP;
          RETURN NEW;
      END;
      \$\$ language 'plpgsql'
    ''');

    print('Result: ${triggerResult['success'] ? "✅ สำเร็จ" : "❌ ล้มเหลว"}');

    print('\n🎉 การทดสอบเสร็จสิ้น!');
  } catch (e) {
    print('\n💥 เกิดข้อผิดพลาด: $e');
  }
}
