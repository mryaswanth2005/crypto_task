class Coin {
  final String id;
  final String symbol;
  final String name;
  final String? image;
  final double? currentPrice;
  final double? marketCap;
  final int? marketCapRank;
  final double? totalVolume;
  final double? priceChangePercentage24h;
  final double? priceChangePercentage7d;
  final List<double>? sparklineIn7d;
  final double? high24h;
  final double? low24h;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? ath;
  final double? athChangePercentage;

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    this.image,
    this.currentPrice,
    this.marketCap,
    this.marketCapRank,
    this.totalVolume,
    this.priceChangePercentage24h,
    this.priceChangePercentage7d,
    this.sparklineIn7d,
    this.high24h,
    this.low24h,
    this.circulatingSupply,
    this.totalSupply,
    this.ath,
    this.athChangePercentage,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    List<double>? sparkline;
    if (json['sparkline_in_7d'] != null &&
        json['sparkline_in_7d']['price'] != null) {
      sparkline = (json['sparkline_in_7d']['price'] as List)
          .map<double>((e) => (e as num).toDouble())
          .toList();
    }

    return Coin(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] as String?,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      marketCap: (json['market_cap'] as num?)?.toDouble(),
      marketCapRank: json['market_cap_rank'] as int?,
      totalVolume: (json['total_volume'] as num?)?.toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble(),
      priceChangePercentage7d:
          (json['price_change_percentage_7d_in_currency'] as num?)?.toDouble(),
      sparklineIn7d: sparkline,
      high24h: (json['24h_high'] as num?)?.toDouble() ??
          (json['high_24h'] as num?)?.toDouble(),
      low24h: (json['24h_low'] as num?)?.toDouble() ??
          (json['low_24h'] as num?)?.toDouble(),
      circulatingSupply: (json['circulating_supply'] as num?)?.toDouble(),
      totalSupply: (json['total_supply'] as num?)?.toDouble(),
      ath: (json['ath'] as num?)?.toDouble(),
      athChangePercentage:
          (json['ath_change_percentage'] as num?)?.toDouble(),
    );
  }

  /// Create a Coin from search result JSON (different structure)
  factory Coin.fromSearchJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['large'] ?? json['thumb'] ?? '',
      marketCapRank: json['market_cap_rank'] as int?,
    );
  }
}
