import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_request.g.dart';

@JsonSerializable()
class SearchRequest extends Equatable {
  final String query;
  final int limit;
  final int offset;

  const SearchRequest({required this.query, this.limit = 10, this.offset = 0});

  factory SearchRequest.fromJson(Map<String, dynamic> json) =>
      _$SearchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SearchRequestToJson(this);

  @override
  List<Object?> get props => [query, limit, offset];
}
