import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_tile.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import 'coin_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WatchlistProvider>();
      if (provider.watchlistCoins.isEmpty && !provider.isEmpty) {
        provider.fetchWatchlistCoins();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const ShimmerLoading(itemCount: 5);
        }

        if (provider.errorMessage.isNotEmpty &&
            provider.watchlistCoins.isEmpty) {
          return ErrorStateWidget(
            message: provider.errorMessage,
            onRetry: () => provider.fetchWatchlistCoins(),
          );
        }

        if (provider.isEmpty) {
          return const EmptyStateWidget(
            title: 'Your watchlist is empty',
            message:
                'Start adding coins to track your favorites.\nTap the ★ icon on any coin to add it here.',
            icon: Icons.star_border_rounded,
          );
        }

        if (provider.watchlistCoins.isEmpty && !provider.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppTheme.accentCyan,
            backgroundColor: AppTheme.cardBg,
            child: ListView(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.accentCyan,
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading ${provider.watchlistIds.length} watched coins...',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          color: AppTheme.accentCyan,
          backgroundColor: AppTheme.cardBg,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: provider.watchlistCoins.length,
            itemBuilder: (context, index) {
              final coin = provider.watchlistCoins[index];
              return Dismissible(
                key: ValueKey(coin.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.lossRed.withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.lossRed,
                    size: 28,
                  ),
                ),
                onDismissed: (_) {
                  provider.removeFromWatchlist(coin.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${coin.name} removed from watchlist'),
                      backgroundColor: AppTheme.cardBg,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: AppTheme.accentCyan,
                        onPressed: () =>
                            provider.addToWatchlist(coin.id),
                      ),
                    ),
                  );
                },
                child: CoinTile(
                  coin: coin,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CoinDetailScreen(coinId: coin.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
