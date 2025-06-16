import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String name;
  @JsonKey(name: 'similarity_score')
  final double similarityScore;
  final String code;
  @JsonKey(name: 'balance_qty')
  final double balanceQty;
  final double price;
  @JsonKey(name: 'supplier_code')
  final String supplierCode;
  final String unit;
  @JsonKey(name: 'img_url')
  final String? imageUrl;
  @JsonKey(name: 'search_priority')
  final int searchPriority;

  const Product({
    required this.id,
    required this.name,
    required this.similarityScore,
    required this.code,
    required this.balanceQty,
    required this.price,
    required this.supplierCode,
    required this.unit,
    this.imageUrl,
    required this.searchPriority,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    similarityScore,
    code,
    balanceQty,
    price,
    supplierCode,
    unit,
    imageUrl,
    searchPriority,
  ];

  // Helper getters for backward compatibility
  ProductMetadata get metadata => ProductMetadata(
    code: code,
    unit: unit,
    balanceQty: balanceQty,
    supplierCode: supplierCode,
    price: price,
  );
}

@JsonSerializable()
class ProductMetadata extends Equatable {
  final String code;
  final String unit;
  @JsonKey(name: 'balance_qty')
  final double balanceQty;
  @JsonKey(name: 'supplier_code')
  final String supplierCode;
  final double price;

  const ProductMetadata({
    required this.code,
    required this.unit,
    required this.balanceQty,
    required this.supplierCode,
    required this.price,
  });

  factory ProductMetadata.fromJson(Map<String, dynamic> json) =>
      _$ProductMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ProductMetadataToJson(this);

  @override
  List<Object?> get props => [code, unit, balanceQty, supplierCode, price];
}
