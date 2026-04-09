import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';

void main() {
  group('HistoryRange', () {
    test('point count matches expected period', () {
      expect(HistoryRange.sevenDays.pointCount, 7);
      expect(HistoryRange.thirtyDays.pointCount, 30);
      expect(HistoryRange.ninetyDays.pointCount, 90);
    });

    test('premium requirement is enabled for long ranges', () {
      expect(HistoryRange.sevenDays.premiumRequired, isFalse);
      expect(HistoryRange.thirtyDays.premiumRequired, isTrue);
      expect(HistoryRange.ninetyDays.premiumRequired, isTrue);
    });
  });
}
