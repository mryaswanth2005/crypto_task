import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'dart:math' as math;

class PriceChart extends StatefulWidget {
  final List<List<double>> data; // [[timestamp, price], ...]
  final String selectedRange;
  final Function(String) onRangeChanged;
  final String coinId;
  final bool isLoading;

  const PriceChart({
    super.key,
    required this.data,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.coinId,
    this.isLoading = false,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  int? _touchedIndex;

  final List<Map<String, String>> _ranges = [
    {'label': '1D', 'value': '1'},
    {'label': '7D', 'value': '7'},
    {'label': '1M', 'value': '30'},
    {'label': '3M', 'value': '90'},
    {'label': '1Y', 'value': '365'},
  ];


  @override
  Widget build(BuildContext context) {
    final isPositive = _isPositiveChange();
    final chartColor = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;

    return Column(
      children: [
        // Price display when touched
        if (_touchedIndex != null && _touchedIndex! < widget.data.length)
          _buildTouchedPrice(),
        // Chart
        SizedBox(
          height: 220,
          child: widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentCyan,
                    strokeWidth: 2,
                  ),
                )
              : widget.data.isEmpty
                  ? const Center(
                      child: Text(
                        'No chart data available',
                        style: TextStyle(color: AppTheme.textTertiary),
                      ),
                    )
                  : Padding(
                          padding: const EdgeInsets.only(right: 16, top: 8),
                          child: LineChart(
                            _buildChartData(chartColor),
                            duration: const Duration(milliseconds: 800),
                          ),
                        ),
        ),
        const SizedBox(height: 16),
        // Range selector
        _buildRangeSelector(),
      ],
    );
  }

  Widget _buildTouchedPrice() {
    final point = widget.data[_touchedIndex!];
    final timestamp = DateTime.fromMillisecondsSinceEpoch(point[0].toInt());
    final price = point[1];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Text(
            formatCurrency(price),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(Color chartColor) {
    final spots = <FlSpot>[];
    final data = widget.data;

    // Downsample if too many points
    final maxPoints = 100;
    final step = data.length > maxPoints ? data.length ~/ maxPoints : 1;

    for (int i = 0; i < data.length; i += step) {
      spots.add(FlSpot(i.toDouble(), data[i][1]));
    }
    // Always include last point
    if (spots.isNotEmpty &&
        spots.last.x != (data.length - 1).toDouble()) {
      spots.add(FlSpot(
          (data.length - 1).toDouble(), data[data.length - 1][1]));
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }

    final minY = spots.map((s) => s.y).reduce(math.min);
    final maxY = spots.map((s) => s.y).reduce(math.max);
    final padding = (maxY - minY) * 0.1;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppTheme.borderColor.withOpacity(0.3),
          strokeWidth: 0.5,
          dashArray: [5, 5],
        ),
      ),
      titlesData: const FlTitlesData(
        show: true,
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minY: minY - padding,
      maxY: maxY + padding,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              AppTheme.cardBg.withOpacity(0.9),
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                formatCurrency(spot.y),
                TextStyle(
                  color: chartColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            }).toList();
          },
        ),
        touchCallback: (event, response) {
          if (event is FlTapUpEvent || event is FlPanEndEvent || event is FlLongPressEnd) {
            setState(() => _touchedIndex = null);
          } else if (response?.lineBarSpots != null &&
              response!.lineBarSpots!.isNotEmpty) {
            final idx = response.lineBarSpots!.first.x.toInt();
            if (idx >= 0 && idx < widget.data.length) {
              setState(() => _touchedIndex = idx);
            }
          }
        },
        handleBuiltInTouches: true,
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: chartColor.withOpacity(0.5),
                strokeWidth: 1,
                dashArray: [3, 3],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: chartColor,
                    strokeWidth: 2,
                    strokeColor: AppTheme.scaffoldBg,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: chartColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                chartColor.withOpacity(0.25),
                chartColor.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _ranges.map((range) {
          final isSelected = widget.selectedRange == range['value'];
          return GestureDetector(
            onTap: () =>
                widget.onRangeChanged(range['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.accentGradient : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                range['label']!,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.scaffoldBg
                      : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isPositiveChange() {
    if (widget.data.length < 2) return true;
    return widget.data.last[1] >= widget.data.first[1];
  }
}
