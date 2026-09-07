class GlobalData {
  final double? totalMarketCap;
  final double? totalVolume;
  final double? marketCapChangePercentage24h;
  final double? btcDominance;
  final double? ethDominance;
  final int? activeCryptocurrencies;
  final int? markets;

  GlobalData({
    this.totalMarketCap,
    this.totalVolume,
    this.marketCapChangePercentage24h,
    this.btcDominance,
    this.ethDominance,
    this.activeCryptocurrencies,
    this.markets,
  });

  factory GlobalData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    double? totalMcap;
    if (data['total_market_cap'] is Map) {
      totalMcap = (data['total_market_cap']['usd'] as num?)?.toDouble();
    }

    double? totalVol;
    if (data['total_volume'] is Map) {
      totalVol = (data['total_volume']['usd'] as num?)?.toDouble();
    }

    double? btcDom;
    if (data['market_cap_percentage'] is Map) {
      btcDom =
          (data['market_cap_percentage']['btc'] as num?)?.toDouble();
    }

    double? ethDom;
    if (data['market_cap_percentage'] is Map) {
      ethDom =
          (data['market_cap_percentage']['eth'] as num?)?.toDouble();
    }

    return GlobalData(
      totalMarketCap: totalMcap,
      totalVolume: totalVol,
      marketCapChangePercentage24h:
          (data['market_cap_change_percentage_24h_usd'] as num?)
              ?.toDouble(),
      btcDominance: btcDom,
      ethDominance: ethDom,
      activeCryptocurrencies:
          data['active_cryptocurrencies'] as int?,
      markets: data['markets'] as int?,
    );
  }
}
