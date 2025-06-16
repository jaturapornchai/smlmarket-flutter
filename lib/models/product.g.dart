// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  similarityScore: (json['similarity_score'] as num).toDouble(),
  code: json['code'] as String,
  balanceQty: (json['balance_qty'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  supplierCode: json['supplier_code'] as String,
  unit: json['unit'] as String,
  imageUrl: json['img_url'] as String?,
  searchPriority: (json['search_priority'] as num).toInt(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'similarity_score': instance.similarityScore,
  'code': instance.code,
  'balance_qty': instance.balanceQty,
  'price': instance.price,
  'supplier_code': instance.supplierCode,
  'unit': instance.unit,
  'img_url': instance.imageUrl,
  'search_priority': instance.searchPriority,
};

ProductMetadata _$ProductMetadataFromJson(Map<String, dynamic> json) =>
    ProductMetadata(
      code: json['code'] as String,
      unit: json['unit'] as String,
      balanceQty: (json['balance_qty'] as num).toDouble(),
      supplierCode: json['supplier_code'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductMetadataToJson(ProductMetadata instance) =>
    <String, dynamic>{
      'code': instance.code,
      'unit': instance.unit,
      'balance_qty': instance.balanceQty,
      'supplier_code': instance.supplierCode,
      'price': instance.price,
    };
