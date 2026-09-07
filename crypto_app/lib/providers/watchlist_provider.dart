import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin.dart';
import '../services/api_service.dart';

class WatchlistProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<String> _watchlistIds = [];
  List<Coin> _watchlistCoins = [];
  bool _isLoading = false;
  String _errorMessage = '';

  WatchlistProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<String> get watchlistIds => _watchlistIds;
  List<Coin> get watchlistCoins => _watchlistCoins;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _watchlistIds.isEmpty;

  bool isInWatchlist(String coinId) => _watchlistIds.contains(coinId);

  /// Load saved watchlist IDs from SharedPreferences
  Future<void> loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    _watchlistIds = prefs.getStringList('watchlist') ?? [];
    notifyListeners();
    if (_watchlistIds.isNotEmpty) {
      await fetchWatchlistCoins();
    }
  }

  /// Save watchlist IDs to SharedPreferences
  Future<void> _saveWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('watchlist', _watchlistIds);
  }

  /// Add a coin to watchlist
  Future<void> addToWatchlist(String coinId) async {
    if (!_watchlistIds.contains(coinId)) {
      _watchlistIds.add(coinId);
      await _saveWatchlist();
      notifyListeners();
      await fetchWatchlistCoins();
    }
  }

  /// Remove a coin from watchlist
  Future<void> removeFromWatchlist(String coinId) async {
    _watchlistIds.remove(coinId);
    _watchlistCoins.removeWhere((c) => c.id == coinId);
    await _saveWatchlist();
    notifyListeners();
  }

  /// Toggle watchlist status
  Future<void> toggleWatchlist(String coinId) async {
    if (isInWatchlist(coinId)) {
      await removeFromWatchlist(coinId);
    } else {
      await addToWatchlist(coinId);
    }
  }

  /// Fetch market data for all watchlisted coins
  Future<void> fetchWatchlistCoins() async {
    if (_watchlistIds.isEmpty) {
      _watchlistCoins = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Fetch all coins and filter by watchlist IDs
      final allCoins = await _apiService.fetchCoins(perPage: 250);
      _watchlistCoins = allCoins
          .where((coin) => _watchlistIds.contains(coin.id))
          .toList();
      _isLoading = false;
    } on Exception catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Refresh watchlist data
  Future<void> refresh() async {
    await fetchWatchlistCoins();
  }
}
