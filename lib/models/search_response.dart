import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'search_response.g.dart';

@JsonSerializable()
class SearchResponse extends Equatable {
  final bool success;
  final String message;
  final SearchData? data;

  const SearchResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable()
class SearchData extends Equatable {
  final List<Product>? data;
  @JsonKey(name: 'total_count')
  final int totalCount;
  final String query;
  @JsonKey(name: 'duration_ms')
  final double durationMs;

  const SearchData({
    this.data,
    required this.totalCount,
    required this.query,
    required this.durationMs,
  });

  // Helper getter to return empty list if data is null
  List<Product> get products => data ?? [];

  factory SearchData.fromJson(Map<String, dynamic> json) =>
      _$SearchDataFromJson(json);
  Map<String, dynamic> toJson() => _$SearchDataToJson(this);

  @override
  List<Object?> get props => [data, totalCount, query, durationMs];
}
