import 'package:intl/intl.dart';

String formatCurrency(double? value, {int decimals = 2}) {
  if (value == null) return '--';
  if (value >= 1) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: decimals)
        .format(value);
  } else if (value >= 0.01) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 4).format(value);
  } else {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 8).format(value);
  }
}

String formatLargeNumber(double? value) {
  if (value == null) return '--';
  if (value >= 1e12) {
    return '\$${(value / 1e12).toStringAsFixed(2)}T';
  } else if (value >= 1e9) {
    return '\$${(value / 1e9).toStringAsFixed(2)}B';
  } else if (value >= 1e6) {
    return '\$${(value / 1e6).toStringAsFixed(2)}M';
  } else if (value >= 1e3) {
    return '\$${(value / 1e3).toStringAsFixed(2)}K';
  }
  return '\$${value.toStringAsFixed(2)}';
}

String formatPercentage(double? value) {
  if (value == null) return '--';
  final prefix = value >= 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}%';
}

String formatSupply(double? value) {
  if (value == null) return '--';
  if (value >= 1e9) {
    return '${(value / 1e9).toStringAsFixed(2)}B';
  } else if (value >= 1e6) {
    return '${(value / 1e6).toStringAsFixed(2)}M';
  } else if (value >= 1e3) {
    return '${(value / 1e3).toStringAsFixed(2)}K';
  }
  return value.toStringAsFixed(0);
}

String formatCompactNumber(double? value) {
  if (value == null) return '--';
  return NumberFormat.compact().format(value);
}
