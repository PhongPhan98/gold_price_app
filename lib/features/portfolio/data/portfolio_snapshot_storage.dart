import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/portfolio_snapshot.dart';

class PortfolioSnapshotStorage {
  static const _snapshotKey = 'portfolio_snapshots';

  Future<List<PortfolioSnapshot>> loadSnapshots() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_snapshotKey) ?? const [];

    return raw
        .map((item) => PortfolioSnapshot.fromJson(json.decode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSnapshots(List<PortfolioSnapshot> snapshots) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = snapshots.map((item) => json.encode(item.toJson())).toList();
    await preferences.setStringList(_snapshotKey, payload);
  }
}
