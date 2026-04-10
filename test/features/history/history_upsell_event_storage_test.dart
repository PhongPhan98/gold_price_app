import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event_storage.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('SharedPrefsHistoryUpsellEventStorage saves and loads events', () async {
    SharedPreferences.setMockInitialValues({});

    final storage = SharedPrefsHistoryUpsellEventStorage();
    final events = [
      HistoryUpsellEvent(
        type: HistoryUpsellEventType.premiumCtaTapped,
        range: HistoryRange.thirtyDays,
        provider: 'BTMC',
        timestamp: DateTime.utc(2026, 4, 10, 3, 4, 5),
      ),
    ];

    await storage.saveEvents(events);
    final loaded = await storage.loadEvents();

    expect(loaded.length, 1);
    expect(loaded.first.type, HistoryUpsellEventType.premiumCtaTapped);
    expect(loaded.first.range, HistoryRange.thirtyDays);
    expect(loaded.first.provider, 'BTMC');
  });
}
