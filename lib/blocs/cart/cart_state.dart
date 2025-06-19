import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final String cartId;
  final List<CartItem> items;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final int itemCount;
  final String? specialPriceNote;

  const CartLoaded({
    required this.cartId,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.itemCount,
    this.specialPriceNote,
  });

  @override
  List<Object?> get props => [
    cartId,
    items,
    totalAmount,
    discountAmount,
    finalAmount,
    itemCount,
    specialPriceNote,
  ];

  CartLoaded copyWith({
    String? cartId,
    List<CartItem>? items,
    double? totalAmount,
    double? discountAmount,
    double? finalAmount,
    int? itemCount,
    String? specialPriceNote,
  }) {
    return CartLoaded(
      cartId: cartId ?? this.cartId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      itemCount: itemCount ?? this.itemCount,
      specialPriceNote: specialPriceNote ?? this.specialPriceNote,
    );
  }
}

class CartEmpty extends CartState {}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CartItemAdding extends CartState {}

class CartItemUpdating extends CartState {
  final String cartItemId;

  const CartItemUpdating({required this.cartItemId});

  @override
  List<Object?> get props => [cartItemId];
}

class CartSpecialPriceRequested extends CartState {
  final String message;

  const CartSpecialPriceRequested({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cart Item Model
class CartItem extends Equatable {
  final String cartItemId;
  final String productId;
  final String productName;
  final String? productCode;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final double discountAmount;
  final double finalPrice;
  final Map<String, dynamic>? productOptions;
  final String? notes;
  final DateTime addedAt;
  final DateTime updatedAt;

  const CartItem({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    this.productCode,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.discountAmount,
    required this.finalPrice,
    this.productOptions,
    this.notes,
    required this.addedAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    cartItemId,
    productId,
    productName,
    productCode,
    unitPrice,
    quantity,
    totalPrice,
    discountAmount,
    finalPrice,
    productOptions,
    notes,
    addedAt,
    updatedAt,
  ];

  CartItem copyWith({
    String? cartItemId,
    String? productId,
    String? productName,
    String? productCode,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    double? discountAmount,
    double? finalPrice,
    Map<String, dynamic>? productOptions,
    String? notes,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      finalPrice: finalPrice ?? this.finalPrice,
      productOptions: productOptions ?? this.productOptions,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['cart_item_id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productCode: json['product_code'],
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      finalPrice: (json['final_price'] ?? 0.0).toDouble(),
      productOptions: json['product_options'],
      notes: json['notes'],
      addedAt: DateTime.parse(
        json['added_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item_id': cartItemId,
      'product_id': productId,
      'product_name': productName,
      'product_code': productCode,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'discount_amount': discountAmount,
      'final_price': finalPrice,
      'product_options': productOptions,
      'notes': notes,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
