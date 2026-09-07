import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/coin_detail_provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/price_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';

class CoinDetailScreen extends StatefulWidget {
  final String coinId;

  const CoinDetailScreen({super.key, required this.coinId});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoinDetailProvider>().fetchCoinDetail(widget.coinId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Consumer<CoinDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const SafeArea(child: ShimmerDetailLoading());
          }
          if (provider.errorMessage.isNotEmpty && provider.coinDetail == null) {
            return SafeArea(
              child: Column(
                children: [
                  _buildAppBar(null),
                  Expanded(
                    child: ErrorStateWidget(
                      message: provider.errorMessage,
                      onRetry: () =>
                          provider.fetchCoinDetail(widget.coinId),
                    ),
                  ),
                ],
              ),
            );
          }

          final coin = provider.coinDetail;
          if (coin == null) return const SizedBox.shrink();
          final market = coin.marketData;

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: AppTheme.scaffoldBg,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (coin.image != null)
                      CachedNetworkImage(
                        imageUrl: coin.image!,
                        width: 28,
                        height: 28,
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    const SizedBox(width: 8),
                    Text(coin.name),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        coin.symbol.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  Consumer<WatchlistProvider>(
                    builder: (context, watchlist, _) {
                      final isWatched = watchlist.isInWatchlist(widget.coinId);
                      return IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isWatched
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            key: ValueKey(isWatched),
                            color: isWatched
                                ? Colors.amber
                                : AppTheme.textSecondary,
                            size: 28,
                          ),
                        ),
                        onPressed: () =>
                            watchlist.toggleWatchlist(widget.coinId),
                      );
                    },
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Header
                      _buildPriceHeader(market),
                      const SizedBox(height: 24),
                      // Chart
                      PriceChart(
                        data: provider.chartData,
                        selectedRange: provider.selectedRange,
                        isLoading: provider.isChartLoading,
                        coinId: widget.coinId,
                        onRangeChanged: (range) =>
                            provider.setChartRange(widget.coinId, range),
                      ),
                      const SizedBox(height: 28),
                      // Stats Section
                      _buildSectionTitle('Market Statistics'),
                      const SizedBox(height: 12),
                      _buildStatsGrid(market),
                      const SizedBox(height: 28),
                      // Supply Section
                      _buildSectionTitle('Supply Information'),
                      const SizedBox(height: 12),
                      _buildSupplyInfo(market),
                      const SizedBox(height: 28),
                      // Price Range
                      _buildSectionTitle('24h Range'),
                      const SizedBox(height: 12),
                      _buildPriceRange(market),
                      // Description
                      if (coin.description != null &&
                          coin.description!.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _buildSectionTitle('About ${coin.name}'),
                        const SizedBox(height: 12),
                        _buildDescription(coin.description!),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(dynamic coin) {
    return AppBar(
      backgroundColor: AppTheme.scaffoldBg,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(coin?.name ?? ''),
    );
  }

  Widget _buildPriceHeader(dynamic market) {
    if (market == null) return const SizedBox.shrink();
    final change = market.priceChangePercentage24h;
    final isPositive = (change ?? 0) >= 0;
    final changeColor = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCurrency(market.currentPrice),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: changeColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                formatPercentage(change),
                style: TextStyle(
                  color: changeColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '24h',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildStatsGrid(dynamic market) {
    if (market == null) return const SizedBox.shrink();
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        StatCard(
          label: 'Market Cap',
          value: formatLargeNumber(market.marketCap),
          icon: Icons.pie_chart_rounded,
        ),
        StatCard(
          label: '24h Volume',
          value: formatLargeNumber(market.totalVolume),
          icon: Icons.bar_chart_rounded,
        ),
        StatCard(
          label: 'All-Time High',
          value: formatCurrency(market.ath),
          icon: Icons.arrow_upward_rounded,
          valueColor: AppTheme.gainGreen,
        ),
        StatCard(
          label: 'All-Time Low',
          value: formatCurrency(market.atl),
          icon: Icons.arrow_downward_rounded,
          valueColor: AppTheme.lossRed,
        ),
        StatCard(
          label: 'FDV',
          value: formatLargeNumber(market.fullyDilutedValuation),
          icon: Icons.account_balance_rounded,
        ),
        StatCard(
          label: '7d Change',
          value: formatPercentage(market.priceChangePercentage7d),
          icon: Icons.show_chart_rounded,
          valueColor: (market.priceChangePercentage7d ?? 0) >= 0
              ? AppTheme.gainGreen
              : AppTheme.lossRed,
        ),
      ],
    );
  }

  Widget _buildSupplyInfo(dynamic market) {
    if (market == null) return const SizedBox.shrink();

    final circulating = market.circulatingSupply ?? 0.0;
    final maxSup = market.maxSupply ?? market.totalSupply ?? 0.0;
    final progress = maxSup > 0 ? (circulating / maxSup).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          _buildSupplyRow(
              'Circulating Supply', formatSupply(market.circulatingSupply)),
          const SizedBox(height: 12),
          _buildSupplyRow(
              'Total Supply', formatSupply(market.totalSupply)),
          const SizedBox(height: 12),
          _buildSupplyRow('Max Supply', formatSupply(market.maxSupply)),
          if (maxSup > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.surfaceBg,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.accentCyan),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% in circulation',
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupplyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRange(dynamic market) {
    if (market == null) return const SizedBox.shrink();
    final low = market.low24h ?? 0.0;
    final high = market.high24h ?? 0.0;
    final current = market.currentPrice ?? 0.0;
    final range = high - low;
    final progress = range > 0 ? ((current - low) / range).clamp(0.0, 1.0) : 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatCurrency(low),
                style: const TextStyle(
                  color: AppTheme.lossRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatCurrency(high),
                style: const TextStyle(
                  color: AppTheme.gainGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [AppTheme.lossRed, AppTheme.gainGreen],
                  ),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 64) * progress - 6,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Low',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
              ),
              const Text(
                'High',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Text(
        description.length > 500
            ? '${description.substring(0, 500)}...'
            : description,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }
}
