import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../repositories/product_repository.dart';
import '../../services/deepseek_service.dart';
import '../../models/search_request.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ProductRepository _productRepository;
  final DeepSeekService _deepSeekService;

  SearchBloc(this._productRepository, {DeepSeekService? deepSeekService})
    : _deepSeekService = deepSeekService ?? DeepSeekService(),
      super(SearchInitial()) {
    on<SearchProductsEvent>(_onSearchProducts);
    on<LoadMoreProductsEvent>(_onLoadMoreProducts);
    on<ClearSearchEvent>(_onClearSearch);
  }
  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<SearchState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();
    developer.log(
      '🚀 Starting search process for query: "${event.query}"',
      name: 'SearchBloc',
      time: DateTime.now(),
    );

    try {
      // First emit enhancing state
      developer.log('📊 Emitting SearchEnhancing state', name: 'SearchBloc');
      emit(SearchEnhancing(originalQuery: event.query));

      // Enhance the query using DeepSeek
      developer.log(
        '🤖 Starting query enhancement with DeepSeek',
        name: 'SearchBloc',
      );
      final enhanceStopwatch = Stopwatch()..start();

      final enhancedQuery = await _deepSeekService.enhanceSearchQuery(
        event.query,
      );

      enhanceStopwatch.stop();
      developer.log(
        '✨ Query enhanced in ${enhanceStopwatch.elapsedMilliseconds}ms: "${event.query}" → "${enhancedQuery}"',
        name: 'SearchBloc',
      );

      // Then emit loading state with enhanced query
      developer.log('⏳ Emitting SearchLoading state', name: 'SearchBloc');
      emit(SearchLoading(enhancedQuery: enhancedQuery));

      final request = SearchRequest(
        query: enhancedQuery,
        limit: event.limit,
        offset: event.offset,
      );

      developer.log(
        '🔎 Calling ProductRepository with enhanced query',
        name: 'SearchBloc',
      );
      final response = await _productRepository.searchProducts(request);

      if (response.success) {
        final hasMoreData = response.data.data.length >= event.limit;
        stopwatch.stop();

        developer.log(
          '🎉 Search completed successfully in ${stopwatch.elapsedMilliseconds}ms',
          name: 'SearchBloc',
        );
        developer.log(
          '📈 Results: ${response.data.data.length} products, total: ${response.data.totalCount}, hasMore: $hasMoreData',
          name: 'SearchBloc',
        );

        emit(
          SearchSuccess(
            products: response.data.data,
            totalCount: response.data.totalCount,
            originalQuery: event.query,
            enhancedQuery: enhancedQuery,
            durationMs: response.data.durationMs,
            hasMoreData: hasMoreData,
          ),
        );
      } else {
        developer.log(
          '⚠️ Search API returned success=false: ${response.message}',
          name: 'SearchBloc',
          error: response.message,
        );
        emit(SearchError(message: response.message));
      }
    } catch (e) {
      stopwatch.stop();
      developer.log(
        '💥 Search failed after ${stopwatch.elapsedMilliseconds}ms',
        name: 'SearchBloc',
        error: e,
        stackTrace: StackTrace.current,
      );
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProductsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchSuccess) {
      final currentState = state as SearchSuccess;
      developer.log(
        '📄 Loading more products: offset=${event.offset}, current=${currentState.products.length}',
        name: 'SearchBloc',
      );

      try {
        emit(
          SearchLoadingMore(
            currentProducts: currentState.products,
            originalQuery: currentState.originalQuery,
            enhancedQuery: currentState.enhancedQuery,
          ),
        );
        final request = SearchRequest(
          query:
              currentState.enhancedQuery, // Use enhanced query for consistency
          limit: 50,
          offset: event.offset,
        );

        developer.log(
          '🔄 Fetching more products with offset ${event.offset}',
          name: 'SearchBloc',
        );
        final response = await _productRepository.searchProducts(request);

        if (response.success) {
          final allProducts = [...currentState.products, ...response.data.data];
          final hasMoreData = response.data.data.length >= 50;

          developer.log(
            '📦 Loaded ${response.data.data.length} more products, total now: ${allProducts.length}',
            name: 'SearchBloc',
          );

          emit(
            SearchSuccess(
              products: allProducts,
              totalCount: response.data.totalCount,
              originalQuery: currentState.originalQuery,
              enhancedQuery: currentState.enhancedQuery,
              durationMs: response.data.durationMs,
              hasMoreData: hasMoreData,
            ),
          );
        } else {
          developer.log(
            '⚠️ Load more failed: ${response.message}',
            name: 'SearchBloc',
            error: response.message,
          );
          emit(SearchError(message: response.message));
        }
      } catch (e) {
        developer.log(
          '💥 Load more error',
          name: 'SearchBloc',
          error: e,
          stackTrace: StackTrace.current,
        );
        emit(SearchError(message: e.toString()));
      }
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
