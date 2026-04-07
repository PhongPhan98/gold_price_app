import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/price_alert.dart';

class PriceAlertStorage {
  static const _alertsKey = 'price_alerts';

  Future<List<PriceAlert>> loadAlerts() async {
    final preferences = await SharedPreferences.getInstance();
    final rawAlerts = preferences.getStringList(_alertsKey) ?? const [];
    return rawAlerts
        .map((item) => PriceAlert.fromJson(json.decode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAlerts(List<PriceAlert> alerts) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = alerts.map((item) => json.encode(item.toJson())).toList();
    await preferences.setStringList(_alertsKey, payload);
  }
}
