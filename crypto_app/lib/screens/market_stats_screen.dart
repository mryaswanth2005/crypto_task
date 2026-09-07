import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/market_stats_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';
import 'coin_detail_screen.dart';

class MarketStatsScreen extends StatefulWidget {
  const MarketStatsScreen({super.key});

  @override
  State<MarketStatsScreen> createState() => _MarketStatsScreenState();
}

class _MarketStatsScreenState extends State<MarketStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketStatsProvider>();
      if (provider.globalData == null) {
        provider.fetchMarketStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketStatsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const ShimmerLoading(itemCount: 6);
        }
        if (provider.errorMessage.isNotEmpty &&
            provider.globalData == null) {
          return ErrorStateWidget(
            message: provider.errorMessage,
            onRetry: () => provider.fetchMarketStats(),
          );
        }
        final data = provider.globalData;
        if (data == null) return const SizedBox.shrink();

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          color: AppTheme.accentCyan,
          backgroundColor: AppTheme.cardBg,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Global Market Header
                _buildMarketHeader(data),
                const SizedBox(height: 20),
                // Stats Grid
                _buildGlobalStats(data),
                const SizedBox(height: 28),
                // Dominance Section
                _buildSectionTitle('Market Dominance'),
                const SizedBox(height: 12),
                _buildDominanceCards(data),
                const SizedBox(height: 28),
                // Trending Coins
                _buildSectionTitle('Trending 🔥'),
                const SizedBox(height: 12),
                _buildTrendingCoins(provider),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketHeader(dynamic data) {
    final change = data.marketCapChangePercentage24h;
    final isPositive = (change ?? 0) >= 0;
    final changeColor = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentCyan.withOpacity(0.08),
            AppTheme.accentPurple.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Global Market Cap',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatLargeNumber(data.totalMarketCap),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: changeColor,
                size: 18,
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${formatPercentage(change)} (24h)',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStats(dynamic data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        StatCard(
          label: '24h Volume',
          value: formatLargeNumber(data.totalVolume),
          icon: Icons.bar_chart_rounded,
        ),
        StatCard(
          label: 'Active Coins',
          value: data.activeCryptocurrencies?.toString() ?? '--',
          icon: Icons.currency_bitcoin_rounded,
        ),
        StatCard(
          label: 'Markets',
          value: data.markets?.toString() ?? '--',
          icon: Icons.store_rounded,
        ),
        StatCard(
          label: 'BTC Dominance',
          value: '${data.btcDominance?.toStringAsFixed(1) ?? '--'}%',
          icon: Icons.donut_large_rounded,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDominanceCards(dynamic data) {
    return Row(
      children: [
        Expanded(
          child: _buildDominanceCard(
            'BTC',
            data.btcDominance ?? 0,
            const Color(0xFFF7931A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDominanceCard(
            'ETH',
            data.ethDominance ?? 0,
            const Color(0xFF627EEA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDominanceCard(
            'Others',
            100.0 - (data.btcDominance ?? 0.0) - (data.ethDominance ?? 0.0),
            AppTheme.accentCyan,
          ),
        ),
      ],
    );
  }

  Widget _buildDominanceCard(String label, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 5,
                  backgroundColor: AppTheme.surfaceBg,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCoins(MarketStatsProvider provider) {
    if (provider.trendingCoins.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No trending data available',
            style: TextStyle(color: AppTheme.textTertiary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.trendingCoins.length,
        itemBuilder: (context, index) {
          final coin = provider.trendingCoins[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CoinDetailScreen(coinId: coin.id),
                ),
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppTheme.borderColor, width: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: coin.image != null && coin.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: coin.image!,
                            width: 40,
                            height: 40,
                            errorWidget: (_, __, ___) =>
                                _trendingFallback(coin),
                          )
                        : _trendingFallback(coin),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    coin.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coin.symbol.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  if (coin.marketCapRank != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '#${coin.marketCapRank}',
                      style: TextStyle(
                        color: AppTheme.accentCyan.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _trendingFallback(dynamic coin) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          coin.symbol.isNotEmpty ? coin.symbol[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
