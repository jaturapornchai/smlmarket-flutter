import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../theme/app_theme.dart';
import '../../widgets/ui_components.dart';
import '../../widgets/product_image.dart';
import '../../models/product.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_event.dart';
import '../../blocs/cart/cart_state.dart';
import '../../routes/navigation_helper.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({required this.productId, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  int _quantity = 1;
  String? _specialPriceNote;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    try {
      developer.log(
        'Loading product detail for ID: ${widget.productId}',
        name: 'ProductDetailPage',
      );

      // ในตัวอย่างนี้เราจะสร้างข้อมูลจำลอง เนื่องจากไม่มี API สำหรับดึงข้อมูลสินค้าแต่ละรายการ
      // ในการใช้งานจริงควรเรียก API เพื่อดึงข้อมูลจาก productId
      await Future.delayed(const Duration(seconds: 1)); // จำลองการโหลด
      setState(() {
        _product = Product(
          id: widget.productId,
          name: 'น้ำมันเครื่องยนต์ Shell Helix Ultra 5W-30',
          code: widget.productId,
          price: 1250.0,
          balanceQty: 25.0,
          unit: 'ลิตร',
          supplierCode: 'SH001',
          searchPriority: 1,
          similarityScore: 0.0,
          imageUrl: 'https://picsum.photos/400/400?random=${widget.productId}',
        );
        _isLoading = false;
      });
    } catch (e) {
      developer.log(
        'Error loading product detail: $e',
        name: 'ProductDetailPage',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_product == null || _isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      developer.log(
        'Adding to cart: ${_product!.name} x $_quantity',
        name: 'ProductDetailPage',
      );

      // Use BLoC to add to cart
      context.read<CartBloc>().add(
        AddToCartEvent(
          sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
          productId: _product!.id,
          productName: _product!.name,
          productCode: _product!.code,
          unitPrice: _product!.price,
          quantity: _quantity,
          notes: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่ม ${_product!.name} ลงตระกร้าแล้ว'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'ดูตระกร้า',
              textColor: Colors.white,
              onPressed: () => NavigationHelper.pushToCart(context),
            ),
          ),
        );
      }
    } catch (e) {
      developer.log('Error adding to cart: $e', name: 'ProductDetailPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _showSpecialPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ขอราคาพิเศษ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'หมายเหตุ (ถ้าต้องการ)',
                hintText: 'ระบุความต้องการพิเศษ...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'ทีมงานจะติดต่อกลับเพื่อแจ้งราคาพิเศษ',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestSpecialPrice();
            },
            child: const Text('ขอราคา'),
          ),
        ],
      ),
    );
  }

  void _requestSpecialPrice() {
    setState(() {
      _specialPriceNote = _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : 'ขอราคาพิเศษ';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ส่งคำขอราคาพิเศษแล้ว ทีมงานจะติดต่อกลับ'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          setState(() {
            _isAddingToCart = false;
          });
        } else if (state is CartError) {
          setState(() {
            _isAddingToCart = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading ? _buildLoadingState() : _buildProductDetail(),
        bottomNavigationBar: _product != null ? _buildBottomBar() : null,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildProductDetail() {
    if (_product == null) {
      return const Center(child: Text('ไม่พบข้อมูลสินค้า'));
    }

    return CustomScrollView(
      slivers: [
        // App Bar with Product Image
        _buildSliverAppBar(),

        // Product Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(),
                const SizedBox(height: AppSpacing.lg),
                _buildPriceSection(),
                const SizedBox(height: AppSpacing.lg),
                _buildQuantitySelector(),
                const SizedBox(height: AppSpacing.lg),
                _buildProductDescription(),
                const SizedBox(height: AppSpacing.lg),
                _buildSpecifications(),
                const SizedBox(height: AppSpacing.lg),
                _buildFeatures(),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${_product!.id}',
          child: ProductImage(
            imageUrl: _product!.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => NavigationHelper.pushToCart(context),
          icon: const Icon(Icons.shopping_cart),
        ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _product!.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text(
              'รหัส: ${_product!.code}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            _buildStockChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildStockChip() {
    final isInStock = _product!.balanceQty > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isInStock
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isInStock ? Colors.green : Colors.red),
      ),
      child: Text(
        isInStock
            ? 'คงเหลือ ${_product!.balanceQty.toStringAsFixed(0)} ${_product!.unit}'
            : 'สินค้าหมด',
        style: TextStyle(
          color: isInStock ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return GlassmorphismCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'ราคา',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '฿${_product!.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showSpecialPriceDialog,
                icon: const Icon(Icons.discount),
                label: const Text('ขอราคาพิเศษ'),
              ),
            ],
          ),
          if (_specialPriceNote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.orange, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'ขอราคาพิเศษ: $_specialPriceNote',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return GlassmorphismCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'จำนวน',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
              Expanded(
                child: Text(
                  '$_quantity',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _quantity < _product!.balanceQty
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ราคารวม: ฿${(_product!.price * _quantity).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDescription() {
    // ข้อมูลจำลองสำหรับรายละเอียดสินค้า
    const description =
        'น้ำมันเครื่องสังเคราะห์แท้ 100% ที่ให้การปกป้องเครื่องยนต์ในระดับสูงสุด เหมาะสำหรับรถยนต์ที่ต้องการประสิทธิภาพสูง มีคุณสมบัติป้องกันการสึกหรอและช่วยยืดอายุการใช้งานของเครื่องยนต์';

    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'รายละเอียด',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    // ข้อมูลจำลองสำหรับข้อมูลทางเทคนิค
    final specifications = {
      'วิสโคซิตี้': '5W-30',
      'ปริมาตร': '4 ลิตร',
      'มาตรฐาน': 'API SN, ACEA A3/B4',
      'เหมาะสำหรับ': 'เครื่องยนต์เบนซิน และดีเซล',
      'ยี่ห้อ': 'Shell',
      'ประเทศผู้ผลิต': 'เนเธอร์แลนด์',
    };

    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'ข้อมูลทางเทคนิค',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...specifications.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      '${entry.key}:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    // ข้อมูลจำลองสำหรับคุณสมบัติเด่น
    final features = [
      'ช่วยทำความสะอาดเครื่องยนต์',
      'ลดการสึกหรอของชิ้นส่วน',
      'ประหยัดน้ำมันเชื้อเพลิง',
      'เริ่มเครื่องได้ง่ายในอุณหภูมิต่ำ',
      'ป้องกันการสะสมของคราบสกปรก',
      'เพิ่มประสิทธิภาพเครื่องยนต์',
    ];

    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'คุณสมบัติเด่น',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isOutOfStock = _product!.balanceQty <= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => NavigationHelper.pushToCart(context),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('ดูตระกร้า'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isOutOfStock || _isAddingToCart ? null : _addToCart,
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_shopping_cart),
                label: Text(
                  _isAddingToCart
                      ? 'กำลังเพิ่ม...'
                      : isOutOfStock
                      ? 'สินค้าหมด'
                      : 'เพิ่มลงตระกร้า',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
