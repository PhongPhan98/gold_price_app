import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/models/price_history_point.dart';
import 'package:gia_vang_hom_nay/features/history/utils/history_trend_utils.dart';

void main() {
  group('HistoryTrendUtils', () {
    test('returns rising insight when last value is higher', () {
      const points = [
        PriceHistoryPoint(label: 'D-1', value: 100),
        PriceHistoryPoint(label: 'D-2', value: 105),
      ];

      final insight = HistoryTrendUtils.buildTrendInsight(points);
      expect(insight.contains('tăng'), isTrue);
    });

    test('returns falling insight when last value is lower', () {
      const points = [
        PriceHistoryPoint(label: 'D-1', value: 105),
        PriceHistoryPoint(label: 'D-2', value: 100),
      ];

      final insight = HistoryTrendUtils.buildTrendInsight(points);
      expect(insight.contains('giảm'), isTrue);
    });

    test('returns insufficient-data message when not enough points', () {
      const points = [PriceHistoryPoint(label: 'D-1', value: 100)];

      final insight = HistoryTrendUtils.buildTrendInsight(points);
      expect(insight.contains('Chưa đủ dữ liệu'), isTrue);
    });
  });
}
