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
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, limit, offset];
}

class LoadMoreProductsEvent extends SearchEvent {
  final String query;
  final int offset;

  const LoadMoreProductsEvent({required this.query, required this.offset});

  @override
  List<Object?> get props => [query, offset];
}

class ClearSearchEvent extends SearchEvent {}
