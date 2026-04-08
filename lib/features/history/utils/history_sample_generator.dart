import '../models/price_history_point.dart';

class HistorySampleGenerator {
  static List<PriceHistoryPoint> generateFromBase({
    required double baseValue,
    required String prefixLabel,
  }) {
    final adjustments = <double>[-0.8, -0.3, 0.2, 0.0, 0.6, 1.1, 0.7];
    return adjustments.asMap().entries.map((entry) {
      final index = entry.key;
      final delta = entry.value;
      return PriceHistoryPoint(
        label: '$prefixLabel-${index + 1}',
        value: baseValue + delta,
      );
    }).toList();
  }
}
