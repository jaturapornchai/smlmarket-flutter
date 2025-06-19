import 'database_service.dart';

class CartService {
  static const String baseUrl = 'http://192.168.2.36:8008';
  final DatabaseService _databaseService = DatabaseService();

  // เพิ่มสินค้าลงตระกร้า
  Future<Map<String, dynamic>> addToCart({
    String? customerId,
    String? sessionId,
    required String productId,
    required String productName,
    String? productCode,
    required double unitPrice,
    required int quantity,
    Map<String, dynamic>? productOptions,
    String? notes,
  }) async {
    try {
      // หาตระกร้าที่ active หรือสร้างใหม่
      String cartId = await _getOrCreateActiveCart(
        customerId: customerId,
        sessionId: sessionId,
      );

      // เช็คว่ามีสินค้านี้ในตระกร้าแล้วหรือไม่
      final existingItem = await _findCartItem(cartId, productId);

      if (existingItem != null) {
        // อัปเดตจำนวน
        return await _updateCartItemQuantity(
          existingItem['cart_item_id'],
          existingItem['quantity'] + quantity,
        );
      } else {
        // เพิ่มรายการใหม่
        return await _insertCartItem(
          cartId: cartId,
          productId: productId,
          productName: productName,
          productCode: productCode,
          unitPrice: unitPrice,
          quantity: quantity,
          productOptions: productOptions,
          notes: notes,
        );
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // หาตระกร้าที่ active หรือสร้างใหม่
  Future<String> _getOrCreateActiveCart({
    String? customerId,
    String? sessionId,
  }) async {
    // หาตระกร้าที่ active
    String whereClause = "cart_status = 'active'";

    if (customerId != null) {
      whereClause += " AND customer_id = '$customerId'";
    } else if (sessionId != null) {
      whereClause += " AND session_id = '$sessionId'";
    } else {
      throw Exception('Either customerId or sessionId must be provided');
    }

    final result = await _databaseService.executeSelectQuery('''
      SELECT cart_id FROM carts 
      WHERE $whereClause
      ORDER BY created_at DESC 
      LIMIT 1
    ''');

    if (result['data'] != null && (result['data'] as List).isNotEmpty) {
      return result['data'][0]['cart_id'];
    }

    // สร้างตระกร้าใหม่
    return await _createNewCart(customerId: customerId, sessionId: sessionId);
  }

  // สร้างตระกร้าใหม่
  Future<String> _createNewCart({String? customerId, String? sessionId}) async {
    final customerIdClause = customerId != null ? "'$customerId'" : 'NULL';
    final sessionIdClause = sessionId != null ? "'$sessionId'" : 'NULL';

    final result = await _databaseService.executeCommand('''
      INSERT INTO carts (customer_id, session_id)
      VALUES ($customerIdClause, $sessionIdClause)
    ''');

    if (result['success'] == true) {
      // ดึง cart_id ที่เพิ่งสร้าง
      final cartResult = await _databaseService.executeSelectQuery('''
        SELECT cart_id FROM carts 
        WHERE ${customerId != null ? "customer_id = '$customerId'" : "session_id = '$sessionId'"}
        ORDER BY created_at DESC 
        LIMIT 1
      ''');

      if (cartResult['data'] != null &&
          (cartResult['data'] as List).isNotEmpty) {
        return cartResult['data'][0]['cart_id'];
      }
    }

    throw Exception('Failed to create new cart');
  }

  // หารายการสินค้าในตระกร้า
  Future<Map<String, dynamic>?> _findCartItem(
    String cartId,
    String productId,
  ) async {
    final result = await _databaseService.executeSelectQuery('''
      SELECT * FROM cart_items 
      WHERE cart_id = '$cartId' AND product_id = '$productId'
      LIMIT 1
    ''');

    if (result['data'] != null && (result['data'] as List).isNotEmpty) {
      return result['data'][0];
    }

    return null;
  } // เพิ่มรายการสินค้าใหม่

  Future<Map<String, dynamic>> _insertCartItem({
    required String cartId,
    required String productId,
    required String productName,
    String? productCode,
    required double unitPrice,
    required int quantity,
    Map<String, dynamic>? productOptions,
    String? notes,
  }) async {
    final totalPrice = unitPrice * quantity;

    final result = await _databaseService.executeCommand('''
      INSERT INTO cart_items (
        cart_id, product_id, product_name, unit_price, quantity, total_price, final_price
      ) VALUES (
        '$cartId', '$productId', '$productName', $unitPrice, $quantity, $totalPrice, $totalPrice
      )
    ''');

    if (result['success'] == true) {
      // อัปเดตยอดรวมในตระกร้า
      await _updateCartTotals(cartId);

      return {'success': true, 'message': 'Item added to cart successfully'};
    } else {
      throw Exception('Failed to insert cart item: ${result['error']}');
    }
  }

  // อัปเดตจำนวนสินค้า
  Future<Map<String, dynamic>> _updateCartItemQuantity(
    String cartItemId,
    int newQuantity,
  ) async {
    if (newQuantity <= 0) {
      return await removeFromCart(cartItemId);
    }

    // ดึงข้อมูลราคาต่อหน่วย
    final itemResult = await _databaseService.executeSelectQuery('''
      SELECT unit_price, cart_id FROM cart_items 
      WHERE cart_item_id = '$cartItemId'
    ''');

    if (itemResult['data'] == null || (itemResult['data'] as List).isEmpty) {
      throw Exception('Cart item not found');
    }

    final unitPrice = itemResult['data'][0]['unit_price'];
    final cartId = itemResult['data'][0]['cart_id'];
    final newTotalPrice = unitPrice * newQuantity;

    await _databaseService.executeCommand('''
      UPDATE cart_items 
      SET quantity = $newQuantity,
          total_price = $newTotalPrice,
          final_price = $newTotalPrice,
          updated_at = CURRENT_TIMESTAMP
      WHERE cart_item_id = '$cartItemId'
    ''');

    // อัปเดตยอดรวมในตระกร้า
    await _updateCartTotals(cartId);

    return {
      'success': true,
      'message': 'Cart item quantity updated successfully',
    };
  }

  // อัปเดตจำนวนสินค้า (public method)
  Future<Map<String, dynamic>> updateCartItemQuantity(
    String cartItemId,
    int newQuantity,
  ) async {
    return await _updateCartItemQuantity(cartItemId, newQuantity);
  }

  // ลบสินค้าออกจากตระกร้า
  Future<Map<String, dynamic>> removeFromCart(String cartItemId) async {
    // ดึง cart_id ก่อนลบ
    final itemResult = await _databaseService.executeSelectQuery('''
      SELECT cart_id FROM cart_items WHERE cart_item_id = '$cartItemId'
    ''');

    if (itemResult['data'] == null || (itemResult['data'] as List).isEmpty) {
      throw Exception('Cart item not found');
    }

    final cartId = itemResult['data'][0]['cart_id'];

    // ลบรายการ
    await _databaseService.executeCommand('''
      DELETE FROM cart_items WHERE cart_item_id = '$cartItemId'
    ''');

    // อัปเดตยอดรวมในตระกร้า
    await _updateCartTotals(cartId);

    return {'success': true, 'message': 'Item removed from cart successfully'};
  }

  // อัปเดตยอดรวมในตระกร้า
  Future<void> _updateCartTotals(String cartId) async {
    final result = await _databaseService.executeSelectQuery('''
      SELECT 
        COUNT(*) as item_count,
        COALESCE(SUM(final_price), 0) as total_amount
      FROM cart_items 
      WHERE cart_id = '$cartId'
    ''');

    if (result['data'] != null && (result['data'] as List).isNotEmpty) {
      final itemCount = result['data'][0]['item_count'];
      final totalAmount = result['data'][0]['total_amount'];

      await _databaseService.executeCommand('''
        UPDATE carts 
        SET item_count = $itemCount,
            total_amount = $totalAmount,
            updated_at = CURRENT_TIMESTAMP
        WHERE cart_id = '$cartId'
      ''');
    }
  }

  // ดึงข้อมูลตระกร้า
  Future<Map<String, dynamic>> getCart({
    String? customerId,
    String? sessionId,
  }) async {
    try {
      String whereClause = "cart_status = 'active'";

      if (customerId != null) {
        whereClause += " AND customer_id = '$customerId'";
      } else if (sessionId != null) {
        whereClause += " AND session_id = '$sessionId'";
      } else {
        throw Exception('Either customerId or sessionId must be provided');
      }

      // ดึงข้อมูลตระกร้า
      final cartResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM carts WHERE $whereClause
        ORDER BY created_at DESC LIMIT 1
      ''');

      if (cartResult['data'] == null || (cartResult['data'] as List).isEmpty) {
        return {
          'cart': null,
          'items': [],
          'item_count': 0,
          'total_amount': 0.0,
        };
      }

      final cart = cartResult['data'][0];
      final cartId = cart['cart_id'];

      // ดึงรายการสินค้าในตระกร้า
      final itemsResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM cart_items 
        WHERE cart_id = '$cartId'
        ORDER BY added_at DESC
      ''');

      return {
        'cart': cart,
        'items': itemsResult['data'] ?? [],
        'item_count': cart['item_count'] ?? 0,
        'total_amount': cart['total_amount'] ?? 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  // ล้างตระกร้า
  Future<Map<String, dynamic>> clearCart({
    String? customerId,
    String? sessionId,
  }) async {
    try {
      String whereClause = "cart_status = 'active'";

      if (customerId != null) {
        whereClause += " AND customer_id = '$customerId'";
      } else if (sessionId != null) {
        whereClause += " AND session_id = '$sessionId'";
      } else {
        throw Exception('Either customerId or sessionId must be provided');
      }

      await _databaseService.executeCommand('''
        UPDATE carts 
        SET cart_status = 'abandoned',
            updated_at = CURRENT_TIMESTAMP
        WHERE $whereClause
      ''');

      return {'success': true, 'message': 'Cart cleared successfully'};
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ใช้คูปอง
  Future<Map<String, dynamic>> applyCoupon({
    required String cartId,
    required String couponCode,
    String? customerId,
  }) async {
    try {
      // ตรวจสอบคูปอง
      final couponResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM coupons 
        WHERE coupon_code = '$couponCode' 
          AND is_active = true
          AND (start_date IS NULL OR start_date <= CURRENT_TIMESTAMP)
          AND (end_date IS NULL OR end_date >= CURRENT_TIMESTAMP)
          AND (usage_limit IS NULL OR usage_count < usage_limit)
      ''');

      if (couponResult['data'] == null ||
          (couponResult['data'] as List).isEmpty) {
        throw Exception('Invalid or expired coupon');
      }

      final coupon = couponResult['data'][0];

      // ตรวจสอบการใช้งานของลูกค้า
      if (customerId != null) {
        final usageResult = await _databaseService.executeSelectQuery('''
          SELECT COUNT(*) as usage_count
          FROM coupon_usages 
          WHERE coupon_id = '${coupon['coupon_id']}' 
            AND customer_id = '$customerId'
        ''');

        final customerUsageCount = usageResult['data'][0]['usage_count'];
        if (customerUsageCount >= coupon['customer_usage_limit']) {
          throw Exception('Coupon usage limit exceeded for this customer');
        }
      }

      // คำนวณส่วนลด
      final cartResult = await _databaseService.executeSelectQuery('''
        SELECT total_amount FROM carts WHERE cart_id = '$cartId'
      ''');

      if (cartResult['data'] == null || (cartResult['data'] as List).isEmpty) {
        throw Exception('Cart not found');
      }

      final totalAmount = cartResult['data'][0]['total_amount'];
      double discountAmount = 0.0;

      switch (coupon['discount_type']) {
        case 'percentage':
          discountAmount = totalAmount * (coupon['discount_value'] / 100);
          if (coupon['maximum_discount'] != null) {
            discountAmount = discountAmount > coupon['maximum_discount']
                ? coupon['maximum_discount']
                : discountAmount;
          }
          break;
        case 'fixed_amount':
          discountAmount = coupon['discount_value'];
          break;
        case 'free_shipping':
          // จะต้องจัดการแยกต่างหาก
          discountAmount = 0.0;
          break;
      }

      // ตรวจสอบยอดขั้นต่ำ
      if (totalAmount < coupon['minimum_amount']) {
        throw Exception(
          'Cart total must be at least ${coupon['minimum_amount']} to use this coupon',
        );
      }

      // อัปเดตตระกร้า
      final finalAmount = totalAmount - discountAmount;
      await _databaseService.executeCommand('''
        UPDATE carts 
        SET discount_amount = $discountAmount,
            final_amount = $finalAmount,
            updated_at = CURRENT_TIMESTAMP
        WHERE cart_id = '$cartId'
      ''');

      // บันทึกการใช้คูปอง
      await _databaseService.executeCommand('''
        INSERT INTO coupon_usages (
          coupon_id, customer_id, cart_id, discount_amount
        ) VALUES (
          '${coupon['coupon_id']}', 
          ${customerId != null ? "'$customerId'" : 'NULL'}, 
          '$cartId', 
          $discountAmount
        )
      ''');

      // อัปเดตจำนวนการใช้งานคูปอง
      await _databaseService.executeCommand('''
        UPDATE coupons 
        SET usage_count = usage_count + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE coupon_id = '${coupon['coupon_id']}'
      ''');

      return {
        'success': true,
        'discount_amount': discountAmount,
        'final_amount': finalAmount,
        'message': 'Coupon applied successfully',
      };
    } catch (e) {
      throw Exception('Failed to apply coupon: $e');
    }
  }

  // สถิติตระกร้า
  Future<Map<String, dynamic>> getCartStatistics() async {
    try {
      final result = await _databaseService.executeSelectQuery('''
        SELECT 
          COUNT(*) as total_carts,
          COUNT(CASE WHEN cart_status = 'active' THEN 1 END) as active_carts,
          COUNT(CASE WHEN cart_status = 'abandoned' THEN 1 END) as abandoned_carts,
          COUNT(CASE WHEN cart_status = 'converted' THEN 1 END) as converted_carts,
          AVG(total_amount) as avg_cart_value,
          SUM(total_amount) as total_cart_value
        FROM carts
      ''');

      return {'success': true, 'statistics': result['data'][0]};
    } catch (e) {
      throw Exception('Failed to get cart statistics: $e');
    }
  }
}
