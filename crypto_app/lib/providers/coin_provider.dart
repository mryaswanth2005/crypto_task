import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/api_service.dart';

enum LoadingState { idle, loading, loaded, error, loadingMore }

class CoinProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Coin> _coins = [];
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  String _sortOrder = 'market_cap_desc';
  String _searchQuery = '';

  CoinProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<Coin> get coins => _coins;
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  bool get isLoading => _state == LoadingState.loading;
  bool get isLoadingMore => _state == LoadingState.loadingMore;

  /// Fetch the first page of coins
  Future<void> fetchCoins() async {
    _state = LoadingState.loading;
    _currentPage = 1;
    _errorMessage = '';
    notifyListeners();

    try {
      final coins = await _apiService.fetchCoins(
        page: 1,
        order: _sortOrder,
      );
      _coins = coins;
      _hasMore = coins.length >= 50;
      _state = coins.isEmpty ? LoadingState.idle : LoadingState.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = LoadingState.error;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  /// Load next page for infinite scroll
  Future<void> loadMore() async {
    if (_state == LoadingState.loadingMore || !_hasMore) return;

    _state = LoadingState.loadingMore;
    notifyListeners();

    try {
      _currentPage++;
      final newCoins = await _apiService.fetchCoins(
        page: _currentPage,
        order: _sortOrder,
      );
      _coins.addAll(newCoins);
      _hasMore = newCoins.length >= 50;
      _state = LoadingState.loaded;
    } on ApiException catch (e) {
      _currentPage--;
      _errorMessage = e.message;
      _state = LoadingState.loaded; // Keep existing data visible
    } catch (e) {
      _currentPage--;
      _state = LoadingState.loaded;
    }
    notifyListeners();
  }

  /// Change sort order and refetch
  void setSortOrder(String order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    fetchCoins();
  }

  /// Refresh (pull-to-refresh)
  Future<void> refresh() async {
    await fetchCoins();
  }
}
