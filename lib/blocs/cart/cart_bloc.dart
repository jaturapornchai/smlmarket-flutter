import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../services/cart_service.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc({CartService? cartService})
    : _cartService = cartService ?? CartService(),
      super(CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<RequestSpecialPriceEvent>(_onRequestSpecialPrice);
  }
  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());

      final cartResult = await _cartService.getCart(
        customerId: event.customerId,
        sessionId: event.sessionId,
      );

      final cartData = cartResult['cart'];
      final itemsData = cartResult['items'] as List? ?? [];

      if (cartData == null || itemsData.isEmpty) {
        emit(CartEmpty());
        return;
      }

      final cartItems = itemsData
          .map((item) => CartItem.fromJson(item))
          .toList();

      emit(
        CartLoaded(
          cartId: cartData['cart_id'],
          items: cartItems,
          totalAmount: (cartData['total_amount'] ?? 0.0).toDouble(),
          discountAmount: (cartData['discount_amount'] ?? 0.0).toDouble(),
          finalAmount: (cartData['final_amount'] ?? 0.0).toDouble(),
          itemCount: cartData['item_count'] ?? 0,
        ),
      );

      developer.log(
        '✅ Cart loaded successfully: ${cartItems.length} items',
        name: 'CartBloc',
      );
    } catch (e) {
      developer.log('❌ Error loading cart: $e', name: 'CartBloc', error: e);
      emit(CartError(message: 'ไม่สามารถโหลดตระกร้าได้: ${e.toString()}'));
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartItemAdding());

      await _cartService.addToCart(
        customerId: event.customerId,
        sessionId: event.sessionId,
        productId: event.productId,
        productName: event.productName,
        productCode: event.productCode,
        unitPrice: event.unitPrice,
        quantity: event.quantity,
        productOptions: event.productOptions,
        notes: event.notes,
      );

      developer.log(
        '✅ Added to cart: ${event.productName} x ${event.quantity}',
        name: 'CartBloc',
      );

      // โหลดตระกร้าใหม่
      add(
        LoadCartEvent(customerId: event.customerId, sessionId: event.sessionId),
      );
    } catch (e) {
      developer.log('❌ Error adding to cart: $e', name: 'CartBloc', error: e);
      emit(
        CartError(message: 'ไม่สามารถเพิ่มสินค้าลงตระกร้าได้: ${e.toString()}'),
      );
    }
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! CartLoaded) return;

      emit(CartItemUpdating(cartItemId: event.cartItemId));

      await _cartService.updateCartItemQuantity(
        event.cartItemId,
        event.quantity,
      );

      developer.log(
        '✅ Updated cart item: ${event.cartItemId} to quantity ${event.quantity}',
        name: 'CartBloc',
      ); // โหลดตระกร้าใหม่
      final cartResult = await _cartService.getCart(
        sessionId:
            'session_${DateTime.now().millisecondsSinceEpoch}', // ใช้ session ID เดียวกัน
      );

      if (cartResult['data'] != null) {
        add(
          LoadCartEvent(
            sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
          ),
        );
      }
    } catch (e) {
      developer.log(
        '❌ Error updating cart item: $e',
        name: 'CartBloc',
        error: e,
      );
      emit(CartError(message: 'ไม่สามารถอัปเดตสินค้าได้: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! CartLoaded) return;

      await _cartService.removeFromCart(event.cartItemId);

      developer.log(
        '✅ Removed from cart: ${event.cartItemId}',
        name: 'CartBloc',
      );

      // โหลดตระกร้าใหม่
      add(
        LoadCartEvent(
          sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    } catch (e) {
      developer.log(
        '❌ Error removing from cart: $e',
        name: 'CartBloc',
        error: e,
      );
      emit(CartError(message: 'ไม่สามารถลบสินค้าได้: ${e.toString()}'));
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _cartService.clearCart(
        sessionId: event.cartId, // Use as session ID
      );

      developer.log('✅ Cart cleared: ${event.cartId}', name: 'CartBloc');

      emit(CartEmpty());
    } catch (e) {
      developer.log('❌ Error clearing cart: $e', name: 'CartBloc', error: e);
      emit(CartError(message: 'ไม่สามารถล้างตระกร้าได้: ${e.toString()}'));
    }
  }

  Future<void> _onRequestSpecialPrice(
    RequestSpecialPriceEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      // ในระบบจริง ควรส่งข้อมูลไปยัง API เพื่อบันทึกคำขอราคาพิเศษ
      developer.log(
        '📋 Special price requested for cart ${event.cartId}: ${event.note}',
        name: 'CartBloc',
      );

      emit(
        CartSpecialPriceRequested(
          message: 'ส่งคำขอราคาพิเศษแล้ว ทีมงานจะติดต่อกลับ',
        ),
      );

      // กลับไปยัง state เดิม
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        emit(currentState.copyWith(specialPriceNote: event.note));
      }
    } catch (e) {
      developer.log(
        '❌ Error requesting special price: $e',
        name: 'CartBloc',
        error: e,
      );
      emit(CartError(message: 'ไม่สามารถส่งคำขอราคาพิเศษได้: ${e.toString()}'));
    }
  }
}
