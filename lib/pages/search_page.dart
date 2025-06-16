import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../blocs/search/search_bloc.dart';
import '../blocs/search/search_event.dart';
import '../blocs/search/search_state.dart';
import '../models/product.dart';
import '../routes/navigation_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';
import '../widgets/product_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _currentQuery = '';
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) {
      developer.log(
        '⏸️ Scroll ignored - hasClients: ${_scrollController.hasClients}, isLoadingMore: $_isLoadingMore',
        name: 'SearchPage',
      );
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final threshold = maxScroll - 300; // Reduced threshold to 300px

    developer.log(
      '📍 Scroll - Current: ${currentScroll.toStringAsFixed(1)}, Max: ${maxScroll.toStringAsFixed(1)}, Threshold: ${threshold.toStringAsFixed(1)}',
      name: 'SearchPage',
    );

    if (currentScroll >= threshold) {
      final state = context.read<SearchBloc>().state;
      developer.log(
        '🎯 Threshold reached! State: ${state.runtimeType}, HasMoreData: ${state is SearchSuccess ? state.hasMoreData : 'N/A'}',
        name: 'SearchPage',
      );

      if (state is SearchSuccess && state.hasMoreData) {
        setState(() {
          _isLoadingMore = true;
        });

        developer.log(
          '📜 Load more triggered for: "$_currentQuery", offset: ${state.products.length}',
          name: 'SearchPage',
        );
        context.read<SearchBloc>().add(
          LoadMoreProductsEvent(
            query: _currentQuery,
            offset: state.products.length,
            limit: 200,
          ),
        );
      } else {
        developer.log(
          '⚠️ Cannot load more - State: ${state.runtimeType}, HasMoreData: ${state is SearchSuccess ? state.hasMoreData : 'N/A'}',
          name: 'SearchPage',
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      developer.log(
        '🔍 User initiated search for: "$query"',
        name: 'SearchPage',
      );
      _currentQuery = query;
      // Reset load more flag when starting new search
      developer.log(
        '🔄 Resetting _isLoadingMore flag for new search',
        name: 'SearchPage',
      );
      setState(() {
        _isLoadingMore = false;
      });
      context.read<SearchBloc>().add(
        SearchProductsEvent(query: query, limit: 200, offset: 0),
      );
    } else {
      developer.log('⚠️ Empty search query, ignoring', name: 'SearchPage');
    }
  }

  void _clearSearch() {
    developer.log('🧹 Clearing search', name: 'SearchPage');
    _searchController.clear();
    _currentQuery = '';
    context.read<SearchBloc>().add(ClearSearchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Fixed search bar at the top
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchBar(),
              ),
              // Content area
              Expanded(
                child: BlocListener<SearchBloc, SearchState>(
                  listener: (context, state) {
                    developer.log(
                      '👂 BlocListener - State changed to: ${state.runtimeType}',
                      name: 'SearchPage',
                    );

                    // Reset loading more flag when search completes, fails, or load more completes
                    if (state is SearchSuccess) {
                      developer.log(
                        '✅ SearchSuccess - Resetting isLoadingMore flag. Products count: ${state.products.length}',
                        name: 'SearchPage',
                      );
                      setState(() {
                        _isLoadingMore = false;
                      });
                    } else if (state is SearchError) {
                      developer.log(
                        '❌ SearchError - Resetting isLoadingMore flag. Error: ${state.message}',
                        name: 'SearchPage',
                      );
                      setState(() {
                        _isLoadingMore = false;
                      });
                    } else if (state is SearchLoading) {
                      developer.log(
                        '🔄 SearchLoading - Resetting isLoadingMore flag for new search',
                        name: 'SearchPage',
                      );
                      setState(() {
                        _isLoadingMore = false;
                      });
                    }
                  },
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is SearchInitial) {
                        return _buildEmptyState();
                      } else if (state is SearchEnhancing) {
                        return _buildEnhancingState(state);
                      } else if (state is SearchLoading) {
                        return _buildLoadingState(state);
                      } else if (state is SearchSuccess) {
                        return _buildSuccessState(state);
                      } else if (state is SearchLoadingMore) {
                        return _buildLoadingMoreState(state);
                      } else if (state is SearchError) {
                        return _buildErrorState(state);
                      }
                      return const Center(child: Text('Unknown state'));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาสินค้า เช่น oil, motor, coil...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _performSearch,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AnimatedListItem(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_outlined,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'ค้นหาสินค้าที่ต้องการ',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'พิมพ์ชื่อสินค้าหรือคำค้นหาในช่องด้านบน',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancingState(SearchEnhancing state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerLoading(
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E5E5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'กำลังปรับปรุงคำค้นหา...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'คำค้นหา: "${state.originalQuery}"',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(SearchLoading state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ShimmerLoading(
            child: GlassmorphismCard(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessState(SearchSuccess state) {
    if (state.products.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบสินค้าที่ตรงกับคำค้นหา "${state.originalQuery}"',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Search Info Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchInfoCard(state),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Products Grid (Shopee style)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.crossAxisExtent;
              int crossAxisCount;

              // Responsive grid columns like Shopee
              if (screenWidth > 1200) {
                crossAxisCount = 6;
              } else if (screenWidth > 900) {
                crossAxisCount = 5;
              } else if (screenWidth > 600) {
                crossAxisCount = 4;
              } else if (screenWidth > 400) {
                crossAxisCount = 3;
              } else {
                crossAxisCount = 2;
              }

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75, // Shopee-like ratio
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.products.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildProductCard(state.products[index]);
                  },
                  childCount:
                      state.products.length + (state.hasMoreData ? 1 : 0),
                ),
              );
            },
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }

  Widget _buildLoadingMoreState(SearchLoadingMore state) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Search Info Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchInfoFromLoadingMore(state),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Products Grid with Loading
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.crossAxisExtent;
              int crossAxisCount;

              if (screenWidth > 1200) {
                crossAxisCount = 6;
              } else if (screenWidth > 900) {
                crossAxisCount = 5;
              } else if (screenWidth > 600) {
                crossAxisCount = 4;
              } else if (screenWidth > 400) {
                crossAxisCount = 3;
              } else {
                crossAxisCount = 2;
              }

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= state.currentProducts.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildProductCard(state.currentProducts[index]);
                }, childCount: state.currentProducts.length + 1),
              );
            },
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }

  Widget _buildErrorState(SearchError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'เกิดข้อผิดพลาด',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            text: 'ลองใหม่',
            onPressed: _performSearch,
            icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInfoFromLoadingMore(SearchLoadingMore state) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original Query
          Row(
            children: [
              Icon(Icons.search, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'คำค้นหา: "${state.originalQuery}"',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Enhanced Query if different from original
          if (state.enhancedQuery != state.originalQuery) ...[
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber[600], size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'คำค้นหาที่ปรับปรุงโดย AI: "${state.enhancedQuery}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Loading more indicator
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'กำลังโหลดสินค้าเพิ่มเติม...',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInfoCard(SearchSuccess state) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original Query
          Row(
            children: [
              Icon(Icons.search, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'คำค้นหา: "${state.originalQuery}"',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Enhanced Query if different from original
          if (state.enhancedQuery != state.originalQuery) ...[
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber[600], size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'คำค้นหาที่ปรับปรุงโดย AI: "${state.enhancedQuery}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Results info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'พบ ${state.totalCount} รายการ',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'ค้นหาใน ${state.durationMs.toStringAsFixed(0)} ms',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(0),
        onTap: () {
          NavigationHelper.pushToProductDetail(context, product.metadata.code);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image on top
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: ProductImage(
                  imageUrl: product.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Product Info below
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Product code
                    Text(
                      'รหัส: ${product.metadata.code}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Stock info
                    _buildInfoChip(
                      Icons.inventory_outlined,
                      'คงเหลือ: ${product.metadata.balanceQty.toStringAsFixed(0)} ${product.metadata.unit}',
                    ),
                    const Spacer(),

                    // Price at bottom
                    Text(
                      '₿${product.metadata.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
