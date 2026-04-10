import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_export_adapter.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';

void main() {
  group('JsonBatchHistoryUpsellExportAdapter', () {
    test('serializes full event list into one JSON batch', () async {
      String? captured;
      final adapter = JsonBatchHistoryUpsellExportAdapter(
        onBatch: (jsonBatch) async {
          captured = jsonBatch;
        },
      );

      await adapter.exportEvents([
        HistoryUpsellEvent(
          type: HistoryUpsellEventType.screenViewed,
          range: HistoryRange.sevenDays,
          provider: 'DOJI',
          timestamp: DateTime.utc(2026, 4, 10, 7),
        ),
      ]);

      expect(captured, isNotNull);
      final decoded = json.decode(captured!) as List<dynamic>;
      expect(decoded.length, 1);
      expect(decoded.first['type'], 'screenViewed');
      expect(decoded.first['provider'], 'DOJI');
    });
  });

  group('ConsoleHistoryUpsellExportAdapter', () {
    test('formats log lines with level and event payload', () async {
      final logs = <String>[];
      final adapter = ConsoleHistoryUpsellExportAdapter(
        level: HistoryUpsellLogLevel.debug,
        onLog: logs.add,
      );

      await adapter.exportEvents([
        HistoryUpsellEvent(
          type: HistoryUpsellEventType.premiumCtaTapped,
          range: HistoryRange.thirtyDays,
          provider: 'BTMC',
          timestamp: DateTime.utc(2026, 4, 10, 8),
        ),
      ]);

      expect(logs.length, 1);
      expect(logs.first.contains('[debug]'), isTrue);
      expect(logs.first.contains('history_upsell'), isTrue);
      expect(logs.first.contains('premiumCtaTapped'), isTrue);
    });
  });
}
