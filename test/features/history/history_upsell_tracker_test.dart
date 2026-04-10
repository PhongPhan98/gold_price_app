import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_tracker.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';

void main() {
  group('HistoryUpsellTracker', () {
    test('tracks screen viewed and premium actions in order', () {
      final tracker = HistoryUpsellTracker();

      tracker.trackScreenViewed(
        range: HistoryRange.sevenDays,
        provider: 'Mi Hồng',
      );
      tracker.trackPremiumRangeTapped(
        range: HistoryRange.thirtyDays,
        provider: 'Mi Hồng',
      );
      tracker.trackPremiumCtaTapped(
        range: HistoryRange.thirtyDays,
        provider: 'Mi Hồng',
      );

      expect(tracker.events.length, 3);
      expect(tracker.events[0].type, HistoryUpsellEventType.screenViewed);
      expect(
        tracker.events[1].type,
        HistoryUpsellEventType.premiumRangeTapped,
      );
      expect(
        tracker.events[2].type,
        HistoryUpsellEventType.premiumCtaTapped,
      );
    });
  });
}
