import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchProductsEvent extends SearchEvent {
  final String query;
  final int limit;
  final int offset;
  const SearchProductsEvent({
    required this.query,
    this.limit = 200,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, limit, offset];
}

class LoadMoreProductsEvent extends SearchEvent {
  final String query;
  final int offset;
  final int limit;

  const LoadMoreProductsEvent({
    required this.query,
    required this.offset,
    this.limit = 200,
  });

  @override
  List<Object?> get props => [query, offset, limit];
}

class ClearSearchEvent extends SearchEvent {}
