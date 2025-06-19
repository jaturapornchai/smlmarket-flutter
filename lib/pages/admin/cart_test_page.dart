import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';

class CartTestPage extends StatefulWidget {
  const CartTestPage({super.key});

  @override
  State<CartTestPage> createState() => _CartTestPageState();
}

class _CartTestPageState extends State<CartTestPage> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  bool _isLoading = false;
  Map<String, dynamic>? _cartData;
  Map<String, dynamic>? _cartStats;
  Map<String, dynamic>? _orderStats;
  String? _errorMessage;
  String? _successMessage;

  // Form controllers
  final _productIdController = TextEditingController();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _sessionIdController = TextEditingController();
  final _couponCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sessionIdController.text =
        'test-session-${DateTime.now().millisecondsSinceEpoch}';
    _loadCartData();
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _sessionIdController.dispose();
    _couponCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadCartData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cartData = await _cartService.getCart(
        sessionId: _sessionIdController.text,
      );

      final cartStats = await _cartService.getCartStatistics();
      final orderStats = await _orderService.getOrderStatistics();

      setState(() {
        _cartData = cartData;
        _cartStats = cartStats;
        _orderStats = orderStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_productIdController.text.isEmpty ||
        _productNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบถ้วน';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _cartService.addToCart(
        sessionId: _sessionIdController.text,
        productId: _productIdController.text,
        productName: _productNameController.text,
        unitPrice: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
      );

      setState(() {
        _successMessage = result['message'];
        _isLoading = false;
      });

      // Clear form
      _productIdController.clear();
      _productNameController.clear();
      _priceController.clear();
      _quantityController.text = '1';

      await _loadCartData();
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเพิ่มสินค้า: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _cartService.clearCart(
        sessionId: _sessionIdController.text,
      );

      setState(() {
        _successMessage = result['message'];
        _isLoading = false;
      });

      await _loadCartData();
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการล้างตระกร้า: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _applyCoupon() async {
    if (_couponCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกรหัสคูปอง';
      });
      return;
    }

    if (_cartData == null || _cartData!['cart'] == null) {
      setState(() {
        _errorMessage = 'ไม่พบตระกร้าสินค้า';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _cartService.applyCoupon(
        cartId: _cartData!['cart']['cart_id'],
        couponCode: _couponCodeController.text,
      );

      setState(() {
        _successMessage =
            'ใช้คูปองสำเร็จ ส่วนลด ${result['discount_amount']} บาท';
        _isLoading = false;
      });

      _couponCodeController.clear();
      await _loadCartData();
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการใช้คูปอง: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ทดสอบระบบตระกร้าสินค้า'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddToCartSection(),
              const SizedBox(height: 20),
              if (_errorMessage != null) _buildErrorCard(),
              if (_successMessage != null) _buildSuccessCard(),
              const SizedBox(height: 20),
              _buildCartDisplay(),
              const SizedBox(height: 20),
              _buildStatisticsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เพิ่มสินค้าลงตระกร้า',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _sessionIdController,
            decoration: const InputDecoration(
              labelText: 'Session ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _productIdController,
                  decoration: const InputDecoration(
                    labelText: 'รหัสสินค้า',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสินค้า',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ราคา',
                    border: OutlineInputBorder(),
                    suffixText: 'บาท',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'จำนวน',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('เพิ่มลงตระกร้า'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadCartData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('รีเฟรช'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartDisplay() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ตระกร้าสินค้า',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_cartData != null && _cartData!['cart'] != null)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _clearCart,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('ล้างตระกร้า'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_cartData == null || _cartData!['cart'] == null)
            const Center(
              child: Text(
                'ไม่มีตระกร้าสินค้า',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else ...[
            // Cart summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'จำนวนสินค้า: ${_cartData!['item_count']} รายการ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ยอดรวม: ${_cartData!['total_amount']} บาท',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Coupon section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponCodeController,
                    decoration: const InputDecoration(
                      labelText: 'รหัสคูปอง',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _applyCoupon,
                  child: const Text('ใช้คูปอง'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cart items
            const Text(
              'รายการสินค้า:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (_cartData!['items'] == null || _cartData!['items'].isEmpty)
              const Text('ไม่มีสินค้าในตระกร้า')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cartData!['items'].length,
                itemBuilder: (context, index) {
                  final item = _cartData!['items'][index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item['product_name']),
                      subtitle: Text('รหัส: ${item['product_id']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${item['quantity']} x ${item['unit_price']}'),
                          Text(
                            '${item['final_price']} บาท',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สถิติระบบ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_cartStats != null) ...[
            const Text(
              'สถิติตระกร้า:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatCard(
              'ตระกร้าทั้งหมด',
              _cartStats!['statistics']['total_carts']?.toString() ?? '0',
            ),
            _buildStatCard(
              'ตระกร้าที่ใช้งาน',
              _cartStats!['statistics']['active_carts']?.toString() ?? '0',
            ),
            _buildStatCard(
              'ตระกร้าที่ถูกทิ้ง',
              _cartStats!['statistics']['abandoned_carts']?.toString() ?? '0',
            ),
            _buildStatCard(
              'มูลค่าเฉลี่ย',
              '${_cartStats!['statistics']['avg_cart_value']?.toStringAsFixed(2) ?? '0'} บาท',
            ),
            const SizedBox(height: 16),
          ],

          if (_orderStats != null) ...[
            const Text(
              'สถิติคำสั่งซื้อ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatCard(
              'คำสั่งซื้อทั้งหมด',
              _orderStats!['statistics']['total_orders']?.toString() ?? '0',
            ),
            _buildStatCard(
              'คำสั่งซื้อที่ชำระแล้ว',
              _orderStats!['statistics']['paid_orders']?.toString() ?? '0',
            ),
            _buildStatCard(
              'ยอดขายรวม',
              '${_orderStats!['statistics']['total_revenue']?.toStringAsFixed(2) ?? '0'} บาท',
            ),
            _buildStatCard(
              'ยอดขายที่ชำระแล้ว',
              '${_orderStats!['statistics']['paid_revenue']?.toStringAsFixed(2) ?? '0'} บาท',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
