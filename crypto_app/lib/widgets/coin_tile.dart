import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/coin.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'sparkline_chart.dart';

class CoinTile extends StatelessWidget {
  final Coin coin;
  final VoidCallback? onTap;
  final Widget? trailing;

  const CoinTile({
    super.key,
    required this.coin,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = (coin.priceChangePercentage24h ?? 0) >= 0;
    final changeColor = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.borderColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 28,
              child: Text(
                '${coin.marketCapRank ?? '-'}',
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: coin.image != null && coin.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: coin.image!,
                      width: 36,
                      height: 36,
                      placeholder: (_, __) => Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _fallbackIcon(),
                    )
                  : _fallbackIcon(),
            ),
            const SizedBox(width: 12),
            // Name + Symbol
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.symbol.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Sparkline
            if (coin.sparklineIn7d != null && coin.sparklineIn7d!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SparklineChart(
                  data: coin.sparklineIn7d!,
                  changePercent: coin.priceChangePercentage24h,
                ),
              ),
            // Price + Change
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(coin.currentPrice),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatPercentage(coin.priceChangePercentage24h),
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 36,
      height: 36,
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
