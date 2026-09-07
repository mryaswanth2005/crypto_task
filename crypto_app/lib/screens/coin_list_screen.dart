import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coin_provider.dart';
import '../models/coin.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_tile.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import 'coin_detail_screen.dart';

class CoinListScreen extends StatefulWidget {
  const CoinListScreen({super.key});

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Market Cap ↓', 'value': 'market_cap_desc'},
    {'label': 'Market Cap ↑', 'value': 'market_cap_asc'},
    {'label': 'Volume ↓', 'value': 'volume_desc'},
    {'label': 'Volume ↑', 'value': 'volume_asc'},
    {'label': 'Price ↓', 'value': 'price_desc'},
    {'label': 'Price ↑', 'value': 'price_asc'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<CoinProvider>();
    if (provider.coins.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchCoins();
      });
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CoinProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sort bar
        _buildSortBar(),
        // Coin list
        Expanded(
          child: Consumer<CoinProvider>(
            builder: (context, provider, _) {
              if (provider.state == LoadingState.loading) {
                return const ShimmerLoading();
              }
              if (provider.state == LoadingState.error &&
                  provider.coins.isEmpty) {
                return ErrorStateWidget(
                  message: provider.errorMessage,
                  onRetry: () => provider.fetchCoins(),
                );
              }
              if (provider.coins.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No coins found',
                  message: 'Try adjusting your filters or check your connection.',
                  icon: Icons.currency_bitcoin_rounded,
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.refresh(),
                color: AppTheme.accentCyan,
                backgroundColor: AppTheme.cardBg,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      provider.coins.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.coins.length) {
                      return _buildLoadingMore(provider);
                    }
                    final coin = provider.coins[index];
                    return CoinTile(
                      coin: coin,
                      onTap: () => _navigateToDetail(coin),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortBar() {
    return Consumer<CoinProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Sort by',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sortOptions.map((option) {
                      final isSelected =
                          provider.sortOrder == option['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              provider.setSortOrder(option['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient:
                                  isSelected ? AppTheme.accentGradient : null,
                              color: isSelected ? null : AppTheme.surfaceBg,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: AppTheme.borderColor,
                                      width: 0.5),
                            ),
                            child: Text(
                              option['label']!,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.scaffoldBg
                                    : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingMore(CoinProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: provider.isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accentCyan,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _navigateToDetail(Coin coin) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoinDetailScreen(coinId: coin.id),
      ),
    );
  }
}
