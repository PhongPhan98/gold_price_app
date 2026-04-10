import '../models/history_range.dart';
import 'history_upsell_event.dart';

class HistoryUpsellTracker {
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

  // Scaffold-only in-memory log for now.
  final List<HistoryUpsellEvent> _events = [];

  List<HistoryUpsellEvent> get events => List.unmodifiable(_events);

  void _push(HistoryUpsellEvent event) {
    _events.add(event);
  }
}
