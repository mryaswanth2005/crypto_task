import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/coin.dart';
import '../models/coin_detail.dart';
import '../models/global_data.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static String get _baseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://127.0.0.1:3000/api';
  }

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> _get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint')
          .replace(queryParameters: queryParams);
      final response = await _client
          .get(uri)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw ApiException('Request timed out. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          return json['data'];
        }
        return json;
      } else if (response.statusCode == 429) {
        throw ApiException(
          'Rate limited. Please wait a moment.',
          statusCode: 429,
        );
      } else {
        throw ApiException(
          'Server error (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: Unable to connect to server.');
    }
  }

  /// Fetch paginated list of coins with market data
  Future<List<Coin>> fetchCoins({
    int page = 1,
    int perPage = 50,
    String vsCurrency = 'usd',
    String order = 'market_cap_desc',
  }) async {
    final data = await _get(
      '/coins/markets',
      queryParams: {
        'vs_currency': vsCurrency,
        'order': order,
        'per_page': perPage.toString(),
        'page': page.toString(),
        'sparkline': 'true',
        'price_change_percentage': '24h,7d',
      },
    );

    if (data is List) {
      return data.map<Coin>((json) => Coin.fromJson(json)).toList();
    }
    return [];
  }

  /// Fetch detailed info for a single coin
  Future<CoinDetail> fetchCoinDetail(String id) async {
    final data = await _get('/coins/$id');
    return CoinDetail.fromJson(data);
  }

  /// Fetch historical price chart data
  /// Returns list of [timestamp, price] pairs
  Future<List<List<double>>> fetchMarketChart(
    String id, {
    String vsCurrency = 'usd',
    String days = '7',
  }) async {
    final data = await _get(
      '/coins/$id/market_chart',
      queryParams: {'vs_currency': vsCurrency, 'days': days},
    );

    if (data is Map && data['prices'] != null) {
      return (data['prices'] as List).map<List<double>>((point) {
        return [(point[0] as num).toDouble(), (point[1] as num).toDouble()];
      }).toList();
    }
    return [];
  }

  /// Fetch global market statistics
  Future<GlobalData> fetchGlobalData() async {
    final data = await _get('/global');
    return GlobalData.fromJson(data);
  }

  /// Search coins by query string
  Future<List<Coin>> searchCoins(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _get('/search', queryParams: {'query': query});
    if (data is Map && data['coins'] != null) {
      return (data['coins'] as List)
          .map<Coin>((json) => Coin.fromSearchJson(json))
          .toList();
    }
    return [];
  }

  /// Fetch trending coins
  Future<List<Coin>> fetchTrending() async {
    final data = await _get('/trending');
    if (data is Map && data['coins'] != null) {
      return (data['coins'] as List).map<Coin>((json) {
        final item = json['item'] ?? json;
        return Coin.fromSearchJson(item);
      }).toList();
    }
    return [];
  }

  void dispose() {
    _client.close();
  }
}
