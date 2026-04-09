import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/models/price_history_point.dart';
import 'package:gia_vang_hom_nay/features/history/utils/history_trend_utils.dart';

void main() {
  group('HistoryTrendUtils', () {
    test('returns free-tier teaser insight when not premium', () {
      const points = [
        PriceHistoryPoint(label: 'D-1', value: 100),
        PriceHistoryPoint(label: 'D-2', value: 105),
      ];

      final insight = HistoryTrendUtils.buildTrendInsight(
        points,
        isPremium: false,
      );
      expect(insight.contains('Premium'), isTrue);
    });

    test('returns richer premium insight when premium is active', () {
      const points = [
        PriceHistoryPoint(label: 'D-1', value: 100),
        PriceHistoryPoint(label: 'D-2', value: 105),
      ];

      final insight = HistoryTrendUtils.buildTrendInsight(
        points,
        isPremium: true,
      );
      expect(insight.contains('Phân tích Premium'), isTrue);
      expect(insight.contains('%'), isTrue);
    });

    test('returns insufficient-data message when not enough points', () {
      const points = [PriceHistoryPoint(label: 'D-1', value: 100)];

      final insight = HistoryTrendUtils.buildTrendInsight(
        points,
        isPremium: true,
      );
      expect(insight.contains('Chưa đủ dữ liệu'), isTrue);
    });
  });
}
