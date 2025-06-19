import 'dart:convert';
import 'database_service.dart';

class OrderService {
  final DatabaseService _databaseService = DatabaseService();

  // สร้างคำสั่งซื้อจากตระกร้า
  Future<Map<String, dynamic>> createOrderFromCart({
    required String cartId,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
    required Map<String, dynamic> shippingAddress,
    Map<String, dynamic>? billingAddress,
    String? shippingMethod,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      // ตรวจสอบตระกร้า
      final cartResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM carts 
        WHERE cart_id = '$cartId' AND cart_status = 'active'
      ''');

      if (cartResult['data'] == null || (cartResult['data'] as List).isEmpty) {
        throw Exception('Cart not found or not active');
      }

      final cart = cartResult['data'][0];

      // ดึงรายการสินค้าในตระกร้า
      final itemsResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM cart_items WHERE cart_id = '$cartId'
      ''');

      if (itemsResult['data'] == null ||
          (itemsResult['data'] as List).isEmpty) {
        throw Exception('No items in cart');
      }

      final cartItems = itemsResult['data'] as List<Map<String, dynamic>>;

      // สร้าง order ID และ order number
      final orderId = _generateOrderId();
      final orderNumber = _generateOrderNumber();

      // สร้างคำสั่งซื้อ
      await _databaseService.executeCommand('''
        INSERT INTO orders (
          order_id, customer_id, cart_id, order_number,
          customer_email, customer_phone, customer_name,
          shipping_address, billing_address, shipping_method,
          subtotal, discount_amount, tax_amount, 
          shipping_amount, total_amount,
          coupon_code, coupon_discount, payment_method, notes
        ) VALUES (
          '$orderId',
          ${cart['customer_id'] != null ? "'${cart['customer_id']}'" : 'NULL'},
          '$cartId',
          '$orderNumber',
          '$customerEmail',
          '$customerPhone',
          '$customerName',
          '${json.encode(shippingAddress)}',
          ${billingAddress != null ? "'${json.encode(billingAddress)}'" : 'NULL'},
          ${shippingMethod != null ? "'$shippingMethod'" : 'NULL'},
          ${cart['total_amount']},
          ${cart['discount_amount'] ?? 0},
          0.00, -- tax_amount
          0.00, -- shipping_amount
          ${cart['final_amount']},
          NULL, -- coupon_code
          ${cart['discount_amount'] ?? 0},
          ${paymentMethod != null ? "'$paymentMethod'" : 'NULL'},
          ${notes != null ? "'$notes'" : 'NULL'}
        )
      ''');

      // คัดลอกรายการสินค้าจากตระกร้าไปยังคำสั่งซื้อ
      for (final item in cartItems) {
        await _databaseService.executeCommand('''
          INSERT INTO order_items (
            order_id, product_id, product_name, product_code,
            unit_price, quantity, total_price, discount_percent,
            discount_amount, final_price, product_options, notes
          ) VALUES (
            '$orderId',
            '${item['product_id']}',
            '${item['product_name']}',
            ${item['product_code'] != null ? "'${item['product_code']}'" : 'NULL'},
            ${item['unit_price']},
            ${item['quantity']},
            ${item['total_price']},
            ${item['discount_percent'] ?? 0},
            ${item['discount_amount'] ?? 0},
            ${item['final_price']},
            ${item['product_options'] != null ? "'${item['product_options']}'" : 'NULL'},
            ${item['notes'] != null ? "'${item['notes']}'" : 'NULL'}
          )
        ''');
      }

      // อัปเดตสถานะตระกร้าเป็น converted
      await _databaseService.executeCommand('''
        UPDATE carts 
        SET cart_status = 'converted',
            updated_at = CURRENT_TIMESTAMP
        WHERE cart_id = '$cartId'
      ''');

      // บันทึกประวัติการเปลี่ยนแปลงสถานะ
      await _addOrderStatusHistory(
        orderId: orderId,
        statusType: 'order',
        newStatus: 'pending',
        changedBy: 'system',
        changeReason: 'Order created from cart',
      );

      return {
        'success': true,
        'order_id': orderId,
        'order_number': orderNumber,
        'message': 'Order created successfully',
      };
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // อัปเดตสถานะคำสั่งซื้อ
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    String? orderStatus,
    String? paymentStatus,
    String? shippingStatus,
    String? changedBy,
    String? changeReason,
  }) async {
    try {
      final updates = <String>[];

      if (orderStatus != null) {
        updates.add("order_status = '$orderStatus'");

        // อัปเดตวันที่ตามสถานะ
        switch (orderStatus) {
          case 'confirmed':
            updates.add("confirmed_at = CURRENT_TIMESTAMP");
            break;
          case 'shipped':
            updates.add("shipped_at = CURRENT_TIMESTAMP");
            break;
          case 'delivered':
            updates.add("delivered_at = CURRENT_TIMESTAMP");
            break;
          case 'cancelled':
            updates.add("cancelled_at = CURRENT_TIMESTAMP");
            break;
        }
      }

      if (paymentStatus != null) {
        updates.add("payment_status = '$paymentStatus'");

        if (paymentStatus == 'paid') {
          updates.add("paid_at = CURRENT_TIMESTAMP");
        }
      }

      if (shippingStatus != null) {
        updates.add("shipping_status = '$shippingStatus'");
      }

      if (updates.isNotEmpty) {
        updates.add("updated_at = CURRENT_TIMESTAMP");

        await _databaseService.executeCommand('''
          UPDATE orders 
          SET ${updates.join(', ')}
          WHERE order_id = '$orderId'
        ''');

        // บันทึกประวัติการเปลี่ยนแปลง
        if (orderStatus != null) {
          await _addOrderStatusHistory(
            orderId: orderId,
            statusType: 'order',
            newStatus: orderStatus,
            changedBy: changedBy ?? 'system',
            changeReason: changeReason,
          );
        }

        if (paymentStatus != null) {
          await _addOrderStatusHistory(
            orderId: orderId,
            statusType: 'payment',
            newStatus: paymentStatus,
            changedBy: changedBy ?? 'system',
            changeReason: changeReason,
          );
        }

        if (shippingStatus != null) {
          await _addOrderStatusHistory(
            orderId: orderId,
            statusType: 'shipping',
            newStatus: shippingStatus,
            changedBy: changedBy ?? 'system',
            changeReason: changeReason,
          );
        }
      }

      return {'success': true, 'message': 'Order status updated successfully'};
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ดึงข้อมูลคำสั่งซื้อ
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      // ดึงข้อมูลคำสั่งซื้อ
      final orderResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM orders WHERE order_id = '$orderId'
      ''');

      if (orderResult['data'] == null ||
          (orderResult['data'] as List).isEmpty) {
        throw Exception('Order not found');
      }

      final order = orderResult['data'][0];

      // ดึงรายการสินค้า
      final itemsResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM order_items 
        WHERE order_id = '$orderId'
        ORDER BY order_item_id
      ''');

      // ดึงประวัติการเปลี่ยนแปลงสถานะ
      final historyResult = await _databaseService.executeSelectQuery('''
        SELECT * FROM order_status_history 
        WHERE order_id = '$orderId'
        ORDER BY changed_at DESC
      ''');

      return {
        'success': true,
        'order': order,
        'items': itemsResult['data'] ?? [],
        'status_history': historyResult['data'] ?? [],
      };
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // ดึงรายการคำสั่งซื้อของลูกค้า
  Future<Map<String, dynamic>> getCustomerOrders({
    String? customerId,
    String? customerEmail,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      String whereClause = '1=1';

      if (customerId != null) {
        whereClause += " AND customer_id = '$customerId'";
      } else if (customerEmail != null) {
        whereClause += " AND customer_email = '$customerEmail'";
      } else {
        throw Exception('Either customerId or customerEmail must be provided');
      }

      final result = await _databaseService.executeSelectQuery('''
        SELECT * FROM orders 
        WHERE $whereClause
        ORDER BY order_date DESC
        LIMIT $limit OFFSET $offset
      ''');

      // นับจำนวนทั้งหมด
      final countResult = await _databaseService.executeSelectQuery('''
        SELECT COUNT(*) as total_count FROM orders WHERE $whereClause
      ''');

      return {
        'success': true,
        'orders': result['data'] ?? [],
        'total_count': countResult['data'][0]['total_count'],
        'limit': limit,
        'offset': offset,
      };
    } catch (e) {
      throw Exception('Failed to get customer orders: $e');
    }
  }

  // ค้นหาคำสั่งซื้อ
  Future<Map<String, dynamic>> searchOrders({
    String? orderNumber,
    String? customerEmail,
    String? orderStatus,
    String? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final conditions = <String>['1=1'];

      if (orderNumber != null && orderNumber.isNotEmpty) {
        conditions.add("order_number ILIKE '%$orderNumber%'");
      }

      if (customerEmail != null && customerEmail.isNotEmpty) {
        conditions.add("customer_email ILIKE '%$customerEmail%'");
      }

      if (orderStatus != null && orderStatus.isNotEmpty) {
        conditions.add("order_status = '$orderStatus'");
      }

      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        conditions.add("payment_status = '$paymentStatus'");
      }

      if (startDate != null) {
        conditions.add("order_date >= '${startDate.toIso8601String()}'");
      }

      if (endDate != null) {
        conditions.add("order_date <= '${endDate.toIso8601String()}'");
      }

      final whereClause = conditions.join(' AND ');

      final result = await _databaseService.executeSelectQuery('''
        SELECT * FROM orders 
        WHERE $whereClause
        ORDER BY order_date DESC
        LIMIT $limit OFFSET $offset
      ''');

      // นับจำนวนทั้งหมด
      final countResult = await _databaseService.executeSelectQuery('''
        SELECT COUNT(*) as total_count FROM orders WHERE $whereClause
      ''');

      return {
        'success': true,
        'orders': result['data'] ?? [],
        'total_count': countResult['data'][0]['total_count'],
        'limit': limit,
        'offset': offset,
      };
    } catch (e) {
      throw Exception('Failed to search orders: $e');
    }
  }

  // สถิติคำสั่งซื้อ
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final result = await _databaseService.executeSelectQuery('''
        SELECT 
          COUNT(*) as total_orders,
          COUNT(CASE WHEN order_status = 'pending' THEN 1 END) as pending_orders,
          COUNT(CASE WHEN order_status = 'confirmed' THEN 1 END) as confirmed_orders,
          COUNT(CASE WHEN order_status = 'shipped' THEN 1 END) as shipped_orders,
          COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) as delivered_orders,
          COUNT(CASE WHEN order_status = 'cancelled' THEN 1 END) as cancelled_orders,
          COUNT(CASE WHEN payment_status = 'paid' THEN 1 END) as paid_orders,
          COUNT(CASE WHEN payment_status = 'pending' THEN 1 END) as pending_payments,
          AVG(total_amount) as avg_order_value,
          SUM(total_amount) as total_revenue,
          SUM(CASE WHEN payment_status = 'paid' THEN total_amount ELSE 0 END) as paid_revenue
        FROM orders
      ''');

      return {'success': true, 'statistics': result['data'][0]};
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // เพิ่มประวัติการเปลี่ยนแปลงสถานะ
  Future<void> _addOrderStatusHistory({
    required String orderId,
    required String statusType,
    String? oldStatus,
    required String newStatus,
    String? changedBy,
    String? changeReason,
  }) async {
    await _databaseService.executeCommand('''
      INSERT INTO order_status_history (
        order_id, status_type, old_status, new_status,
        changed_by, change_reason
      ) VALUES (
        '$orderId',
        '$statusType',
        ${oldStatus != null ? "'$oldStatus'" : 'NULL'},
        '$newStatus',
        ${changedBy != null ? "'$changedBy'" : 'NULL'},
        ${changeReason != null ? "'$changeReason'" : 'NULL'}
      )
    ''');
  }

  // สร้าง Order ID
  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD-$timestamp';
  }

  // สร้าง Order Number
  String _generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return '$year$month$day-$timestamp';
  }

  // อัปเดต tracking number
  Future<Map<String, dynamic>> updateTrackingNumber({
    required String orderId,
    required String trackingNumber,
    String? changedBy,
  }) async {
    try {
      await _databaseService.executeCommand('''
        UPDATE orders 
        SET tracking_number = '$trackingNumber',
            updated_at = CURRENT_TIMESTAMP
        WHERE order_id = '$orderId'
      ''');

      await _addOrderStatusHistory(
        orderId: orderId,
        statusType: 'shipping',
        newStatus: 'shipped',
        changedBy: changedBy ?? 'system',
        changeReason: 'Tracking number added: $trackingNumber',
      );

      return {
        'success': true,
        'message': 'Tracking number updated successfully',
      };
    } catch (e) {
      throw Exception('Failed to update tracking number: $e');
    }
  }

  // ยกเลิกคำสั่งซื้อ
  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    required String cancelReason,
    String? changedBy,
  }) async {
    try {
      await _databaseService.executeCommand('''
        UPDATE orders 
        SET order_status = 'cancelled',
            cancelled_at = CURRENT_TIMESTAMP,
            admin_notes = CONCAT(COALESCE(admin_notes, ''), 'Cancelled: $cancelReason\n'),
            updated_at = CURRENT_TIMESTAMP
        WHERE order_id = '$orderId' 
          AND order_status NOT IN ('delivered', 'cancelled')
      ''');

      await _addOrderStatusHistory(
        orderId: orderId,
        statusType: 'order',
        newStatus: 'cancelled',
        changedBy: changedBy ?? 'system',
        changeReason: cancelReason,
      );

      return {'success': true, 'message': 'Order cancelled successfully'};
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}
