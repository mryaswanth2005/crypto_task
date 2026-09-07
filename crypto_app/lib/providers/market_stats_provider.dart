import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../models/global_data.dart';
import '../services/api_service.dart';

class MarketStatsProvider extends ChangeNotifier {
  final ApiService _apiService;

  GlobalData? _globalData;
  List<Coin> _trendingCoins = [];
  bool _isLoading = false;
  String _errorMessage = '';

  MarketStatsProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  GlobalData? get globalData => _globalData;
  List<Coin> get trendingCoins => _trendingCoins;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Fetch global stats and trending coins
  Future<void> fetchMarketStats() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchGlobalData(),
        _apiService.fetchTrending(),
      ]);

      _globalData = results[0] as GlobalData;
      _trendingCoins = results[1] as List<Coin>;
      _isLoading = false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load market statistics.';
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchMarketStats();
  }
}
