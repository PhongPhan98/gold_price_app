import 'dart:async';

import '../models/history_range.dart';
import 'history_upsell_event.dart';
import 'history_upsell_event_storage.dart';
import 'history_upsell_export_adapter.dart';

class HistoryUpsellTracker {
  HistoryUpsellTracker({
    this.storage,
    this.exportAdapter,
    this.maxQueueSize = 100,
    this.flushThreshold = 20,
  });

  final HistoryUpsellEventStorage? storage;
  final HistoryUpsellExportAdapter? exportAdapter;
  final int maxQueueSize;
  final int flushThreshold;

  final List<HistoryUpsellEvent> _events = [];
  bool _exportInProgress = false;

  List<HistoryUpsellEvent> get events => List.unmodifiable(_events);
  int get pendingCount => _events.length;

  Future<void> initialize() async {
    if (storage == null) {
      return;
    }

    final loaded = await storage!.loadEvents();
    _events
      ..clear()
      ..addAll(loaded);
    _enforceQueueCap();
    await _persist();
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
    if (exportAdapter == null || _events.isEmpty || _exportInProgress) {
      return;
    }

    _exportInProgress = true;
    final snapshot = List<HistoryUpsellEvent>.from(_events);

    try {
      await exportAdapter!.exportEvents(snapshot);

      final removeCount = snapshot.length <= _events.length
          ? snapshot.length
          : _events.length;
      _events.removeRange(0, removeCount);
      await _persist();
    } finally {
      _exportInProgress = false;
    }
  }

  void _push(HistoryUpsellEvent event) {
    _events.add(event);
    _enforceQueueCap();

    unawaited(_persist());

    if (flushThreshold > 0 && _events.length >= flushThreshold) {
      unawaited(exportNow());
    }
  }

  void _enforceQueueCap() {
    if (maxQueueSize <= 0) {
      _events.clear();
      return;
    }

    if (_events.length <= maxQueueSize) {
      return;
    }

    final overflow = _events.length - maxQueueSize;
    _events.removeRange(0, overflow);
  }

  Future<void> _persist() async {
    if (storage == null) {
      return;
    }

    await storage!.saveEvents(events);
  }
}
