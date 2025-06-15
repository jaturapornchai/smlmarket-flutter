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
import '../utils/responsive_utils.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<SearchBloc>().state;
      if (state is SearchSuccess && state.hasMoreData) {
        context.read<SearchBloc>().add(
          LoadMoreProductsEvent(
            query: _currentQuery,
            offset: state.products.length,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      developer.log(
        '🔍 User initiated search for: "$query"',
        name: 'SearchPage',
      );
      _currentQuery = query;
      context.read<SearchBloc>().add(
        SearchProductsEvent(query: query, limit: 50, offset: 0),
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
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchBar(),
              ),
              // Search results
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [_buildEmptyState()],
                      );
                    } else if (state is SearchEnhancing) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [_buildEnhancingState(state)],
                      );
                    } else if (state is SearchLoading) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [_buildLoadingState(state)],
                      );
                    } else if (state is SearchSuccess) {
                      return SingleChildScrollView(
                        child: _buildSuccessState(state),
                      );
                    } else if (state is SearchLoadingMore) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [_buildLoadingMoreState(state)],
                      );
                    } else if (state is SearchError) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [_buildErrorState(state)],
                      );
                    }
                    return const Center(child: Text('Unknown state'));
                  },
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
                  color: Colors.black.withOpacity(0.05),
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
                color: AppColors.primary.withOpacity(0.3),
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
    return SliverFillRemaining(
      child: AnimatedListItem(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_outlined,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'ค้นหาสินค้าที่ต้องการ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
      ),
    );
  }

  Widget _buildEnhancingState(SearchEnhancing state) {
    return SliverFillRemaining(
      child: Center(
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
      ),
    );
  }

  Widget _buildLoadingState(SearchLoading state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
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
        }, childCount: 5),
      ),
    );
  }

  Widget _buildSuccessState(SearchSuccess state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (state.products.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'ไม่พบสินค้าที่ตรงกับคำค้นหา "${state.originalQuery}"',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }
        double maxWidth = constraints.maxWidth;
        double gridColumns = maxWidth / 400;
        double cardWidth = (maxWidth) / gridColumns;
        developer.log(
          'Calculated card width: $cardWidth for grid columns: $gridColumns',
          name: 'SearchPage',
        );
        return Wrap(
          children: state.products.map((product) {
            return Container(
              width: cardWidth,
              child: _buildProductCard(product),
            );
          }).toList(),
        );
      },
    );
    /*return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return _buildSearchInfo(state);
          }

          final productIndex = index - 1;
          if (productIndex >= state.products.length) {
            return state.hasMoreData
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
          return _buildProductCard(state.products[productIndex]);
        }, childCount: state.products.length + 2),
      ),
    );*/
  }

  Widget _buildLoadingMoreState(SearchLoadingMore state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return _buildSearchInfoFromLoadingMore(state);
          }

          final productIndex = index - 1;
          if (productIndex >= state.currentProducts.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildProductCard(state.currentProducts[productIndex]);
        }, childCount: state.currentProducts.length + 2),
      ),
    );
  }

  Widget _buildErrorState(SearchError state) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.withOpacity(0.5),
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
      ),
    );
  }

  Widget _buildSearchInfo(SearchSuccess state) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'พบ ${state.totalCount} รายการ',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'ใช้เวลา ${state.durationMs.toStringAsFixed(1)} ms',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (state.originalQuery != state.enhancedQuery) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คำค้นหาเดิม: "${state.originalQuery}"',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'คำค้นหาที่ปรับปรุง: "${state.enhancedQuery}"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchInfoFromLoadingMore(SearchLoadingMore state) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'ผลการค้นหา "${state.originalQuery}"',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final imageSize = ResponsiveUtils.getProductImageSize(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.isMobile(context)
            ? AppSpacing.md
            : AppSpacing.lg,
      ),
      child: GlassmorphismCard(
        onTap: () {
          NavigationHelper.pushToProductDetail(context, product.metadata.code);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: ProductImage(
                  imageUrl: product.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(product.similarityScore * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'รหัส: ${product.metadata.code}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₿${product.metadata.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(
                        Icons.inventory_outlined,
                        'คงเหลือ: ${product.metadata.balanceQty.toStringAsFixed(0)} ${product.metadata.unit}',
                      ),
                      _buildInfoChip(
                        Icons.business_outlined,
                        product.metadata.supplierCode,
                      ),
                      _buildInfoChip(
                        Icons.attach_money,
                        'ราคา: ₿${product.metadata.price.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ],
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
        color: const Color(0xFFE5E5E5).withOpacity(0.3),
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
