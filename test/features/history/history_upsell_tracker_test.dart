import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event_storage.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_export_adapter.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_tracker.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';

class _FakeStorage implements HistoryUpsellEventStorage {
  List<HistoryUpsellEvent> saved = [];

  @override
  Future<List<HistoryUpsellEvent>> loadEvents() async {
    return List<HistoryUpsellEvent>.from(saved);
  }

  @override
  Future<void> saveEvents(List<HistoryUpsellEvent> events) async {
    saved = List<HistoryUpsellEvent>.from(events);
  }
}

class _FakeExportAdapter implements HistoryUpsellExportAdapter {
  List<HistoryUpsellEvent> exported = [];

  @override
  Future<void> exportEvents(List<HistoryUpsellEvent> events) async {
    exported = List<HistoryUpsellEvent>.from(events);
  }
}

void main() {
  group('HistoryUpsellTracker', () {
    test('tracks screen viewed and premium actions in order', () {
      final tracker = HistoryUpsellTracker();

      tracker.trackScreenViewed(
        range: HistoryRange.sevenDays,
        provider: 'Mi Hồng',
      );
      tracker.trackPremiumRangeTapped(
        range: HistoryRange.thirtyDays,
        provider: 'Mi Hồng',
      );
      tracker.trackPremiumCtaTapped(
        range: HistoryRange.thirtyDays,
        provider: 'Mi Hồng',
      );

      expect(tracker.events.length, 3);
      expect(tracker.events[0].type, HistoryUpsellEventType.screenViewed);
      expect(
        tracker.events[1].type,
        HistoryUpsellEventType.premiumRangeTapped,
      );
      expect(
        tracker.events[2].type,
        HistoryUpsellEventType.premiumCtaTapped,
      );
    });

    test('initialize loads persisted events and exportNow forwards payload', () async {
      final storage = _FakeStorage();
      final exporter = _FakeExportAdapter();
      final tracker = HistoryUpsellTracker(
        storage: storage,
        exportAdapter: exporter,
      );

      storage.saved = [
        HistoryUpsellEvent(
          type: HistoryUpsellEventType.screenViewed,
          range: HistoryRange.sevenDays,
          provider: 'DOJI',
          timestamp: DateTime.utc(2026, 4, 10),
        ),
      ];

      await tracker.initialize();
      await tracker.exportNow();

      expect(tracker.events.length, 1);
      expect(exporter.exported.length, 1);
      expect(exporter.exported.first.provider, 'DOJI');
    });
  });
}
