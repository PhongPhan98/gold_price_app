import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';
import 'package:gia_vang_hom_nay/features/history/utils/history_sample_generator.dart';

void main() {
  group('HistorySampleGenerator', () {
    test('generates seven ordered points from base value by default', () {
      final points = HistorySampleGenerator.generateFromBase(
        baseValue: 100,
        prefixLabel: 'D',
      );

      expect(points.length, 7);
      expect(points.first.label, 'D-1');
      expect(points.last.label, 'D-7');
      expect(points.first.value, greaterThan(0));
    });

    test('generates 30 points for 30-day range', () {
      final points = HistorySampleGenerator.generateFromBase(
        baseValue: 100,
        prefixLabel: 'D',
        range: HistoryRange.thirtyDays,
      );

      expect(points.length, 30);
      expect(points.last.label, 'D-30');
    });
  });
}
