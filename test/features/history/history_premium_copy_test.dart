import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';
import 'package:gia_vang_hom_nay/features/history/utils/history_premium_copy.dart';

void main() {
  group('HistoryPremiumCopy', () {
    test('returns premium-specific value message', () {
      final text = HistoryPremiumCopy.buildRangeValueMessage(
        range: HistoryRange.thirtyDays,
        isPremium: true,
      );

      expect(text.contains('30 ngày'), isTrue);
      expect(text.contains('Premium'), isFalse);
    });

    test('returns free-tier upgrade message', () {
      final text = HistoryPremiumCopy.buildRangeValueMessage(
        range: HistoryRange.ninetyDays,
        isPremium: false,
      );

      expect(text.contains('Premium'), isTrue);
      expect(text.contains('90 ngày'), isTrue);
    });

    test('returns 3 value bullets for both tiers', () {
      final freeBullets = HistoryPremiumCopy.buildValueBullets(isPremium: false);
      final premiumBullets = HistoryPremiumCopy.buildValueBullets(isPremium: true);

      expect(freeBullets.length, 3);
      expect(premiumBullets.length, 3);
    });
  });
}
