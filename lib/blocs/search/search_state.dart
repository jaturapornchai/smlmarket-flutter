import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchEnhancing extends SearchState {
  final String originalQuery;

  const SearchEnhancing({required this.originalQuery});

  @override
  List<Object?> get props => [originalQuery];
}

class SearchLoading extends SearchState {
  final String? enhancedQuery;

  const SearchLoading({this.enhancedQuery});

  @override
  List<Object?> get props => [enhancedQuery];
}

class SearchLoadingMore extends SearchState {
  final List<Product> currentProducts;
  final String originalQuery;
  final String enhancedQuery;

  const SearchLoadingMore({
    required this.currentProducts,
    required this.originalQuery,
    required this.enhancedQuery,
  });

  @override
  List<Object?> get props => [currentProducts, originalQuery, enhancedQuery];
}

class SearchSuccess extends SearchState {
  final List<Product> products;
  final int totalCount;
  final String originalQuery;
  final String enhancedQuery;
  final double durationMs;
  final bool hasMoreData;

  const SearchSuccess({
    required this.products,
    required this.totalCount,
    required this.originalQuery,
    required this.enhancedQuery,
    required this.durationMs,
    required this.hasMoreData,
  });

  @override
  List<Object?> get props => [
    products,
    totalCount,
    originalQuery,
    enhancedQuery,
    durationMs,
    hasMoreData,
  ];

  SearchSuccess copyWith({
    List<Product>? products,
    int? totalCount,
    String? originalQuery,
    String? enhancedQuery,
    double? durationMs,
    bool? hasMoreData,
  }) {
    return SearchSuccess(
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      originalQuery: originalQuery ?? this.originalQuery,
      enhancedQuery: enhancedQuery ?? this.enhancedQuery,
      durationMs: durationMs ?? this.durationMs,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
