import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {
  final String? customerId;
  final String? sessionId;

  const LoadCartEvent({this.customerId, this.sessionId});

  @override
  List<Object?> get props => [customerId, sessionId];
}

class AddToCartEvent extends CartEvent {
  final String productId;
  final String productName;
  final String? productCode;
  final double unitPrice;
  final int quantity;
  final Map<String, dynamic>? productOptions;
  final String? notes;
  final String? customerId;
  final String? sessionId;

  const AddToCartEvent({
    required this.productId,
    required this.productName,
    this.productCode,
    required this.unitPrice,
    required this.quantity,
    this.productOptions,
    this.notes,
    this.customerId,
    this.sessionId,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    productCode,
    unitPrice,
    quantity,
    productOptions,
    notes,
    customerId,
    sessionId,
  ];
}

class UpdateCartItemEvent extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartItemEvent({required this.cartItemId, required this.quantity});

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final String cartItemId;

  const RemoveFromCartEvent({required this.cartItemId});

  @override
  List<Object?> get props => [cartItemId];
}

class ClearCartEvent extends CartEvent {
  final String cartId;

  const ClearCartEvent({required this.cartId});

  @override
  List<Object?> get props => [cartId];
}

class RequestSpecialPriceEvent extends CartEvent {
  final String cartId;
  final String note;

  const RequestSpecialPriceEvent({required this.cartId, required this.note});

  @override
  List<Object?> get props => [cartId, note];
}
