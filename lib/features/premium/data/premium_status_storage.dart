import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/premium_status.dart';

class PremiumStatusStorage {
  static const _premiumStatusKey = 'premium_status';

  Future<PremiumStatus> loadStatus() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_premiumStatusKey);
    if (raw == null) {
      return const PremiumStatus(plan: PremiumPlan.free, isActive: false);
    }

    return PremiumStatus.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> saveStatus(PremiumStatus status) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_premiumStatusKey, json.encode(status.toJson()));
  }
}
