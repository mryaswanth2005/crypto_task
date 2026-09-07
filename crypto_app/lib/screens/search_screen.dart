import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/coin.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'coin_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  Timer? _debounce;

  List<Coin> _results = [];
  List<Coin> _trending = [];
  bool _isLoading = false;
  bool _isTrendingLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    try {
      final trending = await _apiService.fetchTrending();
      if (mounted) {
        setState(() {
          _trending = trending;
          _isTrendingLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTrendingLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _error = '';
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _apiService.searchCoins(query);
        if (mounted) {
          setState(() {
            _results = results;
            _isLoading = false;
            _error = '';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Search failed. Try again.';
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor, width: 0.5),
            ),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search coins...',
                hintStyle: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textTertiary,
                  size: 22,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textTertiary,
                          size: 20,
                        ),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentCyan,
          strokeWidth: 2,
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          _error,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    // Show search results if query is active
    if (_controller.text.isNotEmpty) {
      if (_results.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppTheme.textTertiary.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'No coins found',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) =>
            _buildSearchResult(_results[index]),
      );
    }

    // Show trending when search is empty
    return _buildTrendingSection();
  }

  Widget _buildSearchResult(Coin coin) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CoinDetailScreen(coinId: coin.id),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: coin.image != null && coin.image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coin.image!,
                width: 36,
                height: 36,
                errorWidget: (_, __, ___) => _searchFallback(coin),
              )
            : _searchFallback(coin),
      ),
      title: Text(
        coin.name,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        coin.symbol.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textTertiary,
          fontSize: 13,
        ),
      ),
      trailing: coin.marketCapRank != null
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '#${coin.marketCapRank}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTrendingSection() {
    if (_isTrendingLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentCyan,
          strokeWidth: 2,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Trending',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6),
              Text('🔥', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Most searched coins in the last 24h',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _trending.length,
            (i) => _buildSearchResult(_trending[i]),
          ),
        ],
      ),
    );
  }

  Widget _searchFallback(Coin coin) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          coin.symbol.isNotEmpty ? coin.symbol[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
