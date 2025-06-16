// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchRequest _$SearchRequestFromJson(Map<String, dynamic> json) =>
    SearchRequest(
      query: json['query'] as String,
      limit: (json['limit'] as num?)?.toInt() ?? 200,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SearchRequestToJson(SearchRequest instance) =>
    <String, dynamic>{
      'query': instance.query,
      'limit': instance.limit,
      'offset': instance.offset,
    };
