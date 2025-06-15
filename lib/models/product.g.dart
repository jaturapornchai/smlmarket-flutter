// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  similarityScore: (json['similarity_score'] as num).toDouble(),
  metadata: ProductMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
  imageUrl: json['img_url'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'img_url': instance.imageUrl,
  'similarity_score': instance.similarityScore,
  'metadata': instance.metadata,
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
