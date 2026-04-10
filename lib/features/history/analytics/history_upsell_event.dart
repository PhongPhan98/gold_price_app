import '../models/history_range.dart';

enum HistoryUpsellEventType {
  screenViewed,
  premiumRangeTapped,
  premiumCtaTapped,
}

class HistoryUpsellEvent {
  const HistoryUpsellEvent({
    required this.type,
    required this.range,
    required this.provider,
    required this.timestamp,
  });

  final HistoryUpsellEventType type;
  final HistoryRange range;
  final String provider;
  final DateTime timestamp;

  Map<String, Object> toMap() {
    return {
      'type': type.name,
      'range': range.name,
      'provider': provider,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
