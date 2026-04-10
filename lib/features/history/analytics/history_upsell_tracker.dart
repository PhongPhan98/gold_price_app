import 'dart:async';

import '../models/history_range.dart';
import 'history_upsell_event.dart';
import 'history_upsell_event_storage.dart';
import 'history_upsell_export_adapter.dart';

class HistoryUpsellTracker {
  HistoryUpsellTracker({
    this.storage,
    this.exportAdapter,
  });

  final HistoryUpsellEventStorage? storage;
  final HistoryUpsellExportAdapter? exportAdapter;

  final List<HistoryUpsellEvent> _events = [];

  List<HistoryUpsellEvent> get events => List.unmodifiable(_events);

  Future<void> initialize() async {
    if (storage == null) {
      return;
    }

    final loaded = await storage!.loadEvents();
    _events
      ..clear()
      ..addAll(loaded);
  }

  void trackScreenViewed({
    required HistoryRange range,
    required String provider,
  }) {
    _push(
      HistoryUpsellEvent(
        type: HistoryUpsellEventType.screenViewed,
        range: range,
        provider: provider,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  void trackPremiumRangeTapped({
    required HistoryRange range,
    required String provider,
  }) {
    _push(
      HistoryUpsellEvent(
        type: HistoryUpsellEventType.premiumRangeTapped,
        range: range,
        provider: provider,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  void trackPremiumCtaTapped({
    required HistoryRange range,
    required String provider,
  }) {
    _push(
      HistoryUpsellEvent(
        type: HistoryUpsellEventType.premiumCtaTapped,
        range: range,
        provider: provider,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> exportNow() async {
    if (exportAdapter == null) {
      return;
    }

    await exportAdapter!.exportEvents(events);
  }

  void _push(HistoryUpsellEvent event) {
    _events.add(event);

    if (storage != null) {
      unawaited(storage!.saveEvents(events));
    }
  }
}
