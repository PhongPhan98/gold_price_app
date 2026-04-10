import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'history_upsell_event.dart';

abstract class HistoryUpsellEventStorage {
  Future<List<HistoryUpsellEvent>> loadEvents();

  Future<void> saveEvents(List<HistoryUpsellEvent> events);
}

class SharedPrefsHistoryUpsellEventStorage implements HistoryUpsellEventStorage {
  static const _key = 'history_upsell_events';

  @override
  Future<List<HistoryUpsellEvent>> loadEvents() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_key) ?? const [];

    return raw
        .map((item) => HistoryUpsellEvent.fromMap(
              json.decode(item) as Map<String, dynamic>,
            ))
        .toList();
  }

  @override
  Future<void> saveEvents(List<HistoryUpsellEvent> events) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = events.map((event) => json.encode(event.toMap())).toList();
    await preferences.setStringList(_key, payload);
  }
}
