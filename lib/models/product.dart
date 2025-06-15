import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String name;
  @JsonKey(name: 'img_url')
  final String? imageUrl;

  @JsonKey(name: 'similarity_score')
  final double similarityScore;

  final ProductMetadata metadata;
  const Product({
    required this.id,
    required this.name,
    required this.similarityScore,
    required this.metadata,
    this.imageUrl,
  });
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  @override
  List<Object?> get props => [id, name, imageUrl, similarityScore, metadata];
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
