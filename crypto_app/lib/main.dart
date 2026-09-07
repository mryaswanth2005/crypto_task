import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/coin_provider.dart';
import 'providers/coin_detail_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/market_stats_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.cardBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CryptoScopeApp());
}

class CryptoScopeApp extends StatelessWidget {
  const CryptoScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoinProvider()),
        ChangeNotifierProvider(create: (_) => CoinDetailProvider()),
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider()..loadWatchlist(),
        ),
        ChangeNotifierProvider(create: (_) => MarketStatsProvider()),
      ],
      child: MaterialApp(
        title: 'CryptoScope',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
