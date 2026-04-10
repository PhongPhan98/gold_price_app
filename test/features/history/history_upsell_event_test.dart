import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';

void main() {
  test('HistoryUpsellEvent toMap contains canonical fields', () {
    final event = HistoryUpsellEvent(
      type: HistoryUpsellEventType.premiumCtaTapped,
      range: HistoryRange.thirtyDays,
      provider: 'DOJI',
      timestamp: DateTime.utc(2026, 4, 10, 1, 2, 3),
    );

    final payload = event.toMap();

    expect(payload['type'], 'premiumCtaTapped');
    expect(payload['range'], 'thirtyDays');
    expect(payload['provider'], 'DOJI');
    expect(payload['timestamp'], '2026-04-10T01:02:03.000Z');
  });
}
