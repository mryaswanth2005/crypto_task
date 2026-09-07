class CoinDetail {
  final String id;
  final String symbol;
  final String name;
  final String? image;
  final String? description;
  final String? genesisDate;
  final int? marketCapRank;
  final String? homepage;
  final CoinMarketData? marketData;

  CoinDetail({
    required this.id,
    required this.symbol,
    required this.name,
    this.image,
    this.description,
    this.genesisDate,
    this.marketCapRank,
    this.homepage,
    this.marketData,
  });

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['image'] != null) {
      imageUrl = json['image']['large'] ?? json['image']['small'];
    }

    String? desc;
    if (json['description'] != null && json['description']['en'] != null) {
      desc = json['description']['en'];
      // Strip HTML tags
      desc = desc?.replaceAll(RegExp(r'<[^>]*>'), '');
    }

    String? homepage;
    if (json['links'] != null &&
        json['links']['homepage'] != null &&
        (json['links']['homepage'] as List).isNotEmpty) {
      homepage = json['links']['homepage'][0];
    }

    return CoinDetail(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: imageUrl,
      description: desc,
      genesisDate: json['genesis_date'] as String?,
      marketCapRank: json['market_cap_rank'] as int?,
      homepage: homepage,
      marketData: json['market_data'] != null
          ? CoinMarketData.fromJson(json['market_data'])
          : null,
    );
  }
}

class CoinMarketData {
  final double? currentPrice;
  final double? marketCap;
  final double? totalVolume;
  final double? high24h;
  final double? low24h;
  final double? priceChange24h;
  final double? priceChangePercentage24h;
  final double? priceChangePercentage7d;
  final double? priceChangePercentage30d;
  final double? priceChangePercentage1y;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double? ath;
  final double? athChangePercentage;
  final String? athDate;
  final double? atl;
  final double? atlChangePercentage;
  final String? atlDate;
  final double? fullyDilutedValuation;

  CoinMarketData({
    this.currentPrice,
    this.marketCap,
    this.totalVolume,
    this.high24h,
    this.low24h,
    this.priceChange24h,
    this.priceChangePercentage24h,
    this.priceChangePercentage7d,
    this.priceChangePercentage30d,
    this.priceChangePercentage1y,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    this.ath,
    this.athChangePercentage,
    this.athDate,
    this.atl,
    this.atlChangePercentage,
    this.atlDate,
    this.fullyDilutedValuation,
  });

  factory CoinMarketData.fromJson(Map<String, dynamic> json) {
    double? getUsd(String key) {
      if (json[key] is Map) {
        return (json[key]['usd'] as num?)?.toDouble();
      }
      return (json[key] as num?)?.toDouble();
    }

    String? getUsdDate(String key) {
      if (json[key] is Map) {
        return json[key]['usd'] as String?;
      }
      return json[key] as String?;
    }

    return CoinMarketData(
      currentPrice: getUsd('current_price'),
      marketCap: getUsd('market_cap'),
      totalVolume: getUsd('total_volume'),
      high24h: getUsd('high_24h'),
      low24h: getUsd('low_24h'),
      priceChange24h: getUsd('price_change_24h'),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble(),
      priceChangePercentage7d:
          (json['price_change_percentage_7d'] as num?)?.toDouble(),
      priceChangePercentage30d:
          (json['price_change_percentage_30d'] as num?)?.toDouble(),
      priceChangePercentage1y:
          (json['price_change_percentage_1y'] as num?)?.toDouble(),
      circulatingSupply:
          (json['circulating_supply'] as num?)?.toDouble(),
      totalSupply: (json['total_supply'] as num?)?.toDouble(),
      maxSupply: (json['max_supply'] as num?)?.toDouble(),
      ath: getUsd('ath'),
      athChangePercentage:
          (json['ath_change_percentage'] is Map)
              ? (json['ath_change_percentage']['usd'] as num?)?.toDouble()
              : (json['ath_change_percentage'] as num?)?.toDouble(),
      athDate: getUsdDate('ath_date'),
      atl: getUsd('atl'),
      atlChangePercentage:
          (json['atl_change_percentage'] is Map)
              ? (json['atl_change_percentage']['usd'] as num?)?.toDouble()
              : (json['atl_change_percentage'] as num?)?.toDouble(),
      atlDate: getUsdDate('atl_date'),
      fullyDilutedValuation: getUsd('fully_diluted_valuation'),
    );
  }
}
