import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/portfolio_holding.dart';

class PortfolioStorage {
  static const _portfolioKey = 'portfolio_holdings';

  Future<List<PortfolioHolding>> loadHoldings() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_portfolioKey) ?? const [];

    return raw
        .map((item) => PortfolioHolding.fromJson(json.decode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHoldings(List<PortfolioHolding> holdings) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = holdings.map((item) => json.encode(item.toJson())).toList();
    await preferences.setStringList(_portfolioKey, payload);
  }
}
