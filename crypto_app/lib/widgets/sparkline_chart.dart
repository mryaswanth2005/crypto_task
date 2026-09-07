import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final double? changePercent;
  final double width;
  final double height;

  const SparklineChart({
    super.key,
    required this.data,
    this.changePercent,
    this.width = 70,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    final isPositive = (changePercent ?? 0) >= 0;
    final color = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;

    // Downsample data for performance
    final sampledData = _downsample(data, 20);

    final spots = <FlSpot>[];
    for (int i = 0; i < sampledData.length; i++) {
      spots.add(FlSpot(i.toDouble(), sampledData[i]));
    }

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          clipData: const FlClipData.all(),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }

  List<double> _downsample(List<double> data, int targetSize) {
    if (data.length <= targetSize) return data;
    final step = data.length / targetSize;
    return List.generate(
      targetSize,
      (i) => data[(i * step).floor().clamp(0, data.length - 1)],
    );
  }
}
