// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    SearchResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: SearchData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

SearchData _$SearchDataFromJson(Map<String, dynamic> json) => SearchData(
  data: (json['data'] as List<dynamic>)
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['total_count'] as num).toInt(),
  query: json['query'] as String,
  durationMs: (json['duration_ms'] as num).toDouble(),
);

Map<String, dynamic> _$SearchDataToJson(SearchData instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total_count': instance.totalCount,
      'query': instance.query,
      'duration_ms': instance.durationMs,
    };
