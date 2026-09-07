import 'package:flutter/material.dart';
import '../models/coin_detail.dart';
import '../services/api_service.dart';

class CoinDetailProvider extends ChangeNotifier {
  final ApiService _apiService;

  CoinDetail? _coinDetail;
  List<List<double>> _chartData = [];
  bool _isLoading = false;
  bool _isChartLoading = false;
  String _errorMessage = '';
  String _chartErrorMessage = '';
  String _selectedRange = '7';

  CoinDetailProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  CoinDetail? get coinDetail => _coinDetail;
  List<List<double>> get chartData => _chartData;
  bool get isLoading => _isLoading;
  bool get isChartLoading => _isChartLoading;
  String get errorMessage => _errorMessage;
  String get chartErrorMessage => _chartErrorMessage;
  String get selectedRange => _selectedRange;

  /// Fetch coin detail and chart data
  Future<void> fetchCoinDetail(String coinId) async {
    _isLoading = true;
    _errorMessage = '';
    _coinDetail = null;
    _chartData = [];
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchCoinDetail(coinId),
        _apiService.fetchMarketChart(coinId, days: _selectedRange),
      ]);

      _coinDetail = results[0] as CoinDetail;
      _chartData = results[1] as List<List<double>>;
      _isLoading = false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load coin details.';
      _isLoading = false;
    }
    notifyListeners();
  }

  /// Change chart time range
  Future<void> setChartRange(String coinId, String days) async {
    if (_selectedRange == days) return;
    _selectedRange = days;
    _isChartLoading = true;
    _chartErrorMessage = '';
    notifyListeners();

    try {
      _chartData = await _apiService.fetchMarketChart(coinId, days: days);
      _isChartLoading = false;
    } on ApiException catch (e) {
      _chartErrorMessage = e.message;
      _isChartLoading = false;
    } catch (e) {
      _chartErrorMessage = 'Failed to load chart data.';
      _isChartLoading = false;
    }
    notifyListeners();
  }

  void reset() {
    _coinDetail = null;
    _chartData = [];
    _isLoading = false;
    _errorMessage = '';
    _selectedRange = '7';
    notifyListeners();
  }
}
