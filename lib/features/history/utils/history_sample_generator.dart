import '../models/history_range.dart';
import '../models/price_history_point.dart';

class HistorySampleGenerator {
  static List<PriceHistoryPoint> generateFromBase({
    required double baseValue,
    required String prefixLabel,
    HistoryRange range = HistoryRange.sevenDays,
  }) {
    final points = <PriceHistoryPoint>[];
    final count = range.pointCount;

    for (var i = 0; i < count; i++) {
      final oscillation = (i % 6 - 2) * 0.35;
      final momentum = i * 0.08;
      final value = baseValue + oscillation + momentum;

      points.add(
        PriceHistoryPoint(
          label: '$prefixLabel-${i + 1}',
          value: value,
        ),
      );
    }

    return points;
  }
}
