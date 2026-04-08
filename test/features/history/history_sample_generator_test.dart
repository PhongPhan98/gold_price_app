import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/utils/history_sample_generator.dart';

void main() {
  group('HistorySampleGenerator', () {
    test('generates seven ordered points from base value', () {
      final points = HistorySampleGenerator.generateFromBase(
        baseValue: 100,
        prefixLabel: 'D',
      );

      expect(points.length, 7);
      expect(points.first.label, 'D-1');
      expect(points.last.label, 'D-7');
      expect(points[0].value, 99.2);
      expect(points[6].value, 100.7);
    });
  });
}
