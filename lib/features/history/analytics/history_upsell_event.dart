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

  factory HistoryUpsellEvent.fromMap(Map<String, dynamic> map) {
    final rawType = map['type'] as String?;
    final rawRange = map['range'] as String?;

    final type = HistoryUpsellEventType.values.firstWhere(
      (item) => item.name == rawType,
      orElse: () => HistoryUpsellEventType.screenViewed,
    );

    final range = HistoryRange.values.firstWhere(
      (item) => item.name == rawRange,
      orElse: () => HistoryRange.sevenDays,
    );

    return HistoryUpsellEvent(
      type: type,
      range: range,
      provider: map['provider'] as String? ?? 'unknown',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }
}
