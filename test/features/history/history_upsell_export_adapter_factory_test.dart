import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_analytics_config.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_event.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_export_adapter.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_export_adapter_factory.dart';
import 'package:gia_vang_hom_nay/features/history/models/history_range.dart';

void main() {
  group('createHistoryUpsellExportAdapter', () {
    test('returns console adapter when config is console mode', () async {
      final logs = <String>[];
      final adapter = createHistoryUpsellExportAdapter(
        config: const HistoryAnalyticsConfig(
          exportMode: HistoryAnalyticsExportMode.console,
          consoleLogLevel: HistoryUpsellLogLevel.debug,
        ),
        onConsoleLog: logs.add,
      );

      await adapter.exportEvents([
        HistoryUpsellEvent(
          type: HistoryUpsellEventType.screenViewed,
          range: HistoryRange.sevenDays,
          provider: 'DOJI',
          timestamp: DateTime.utc(2026, 4, 10),
        ),
      ]);

      expect(adapter, isA<ConsoleHistoryUpsellExportAdapter>());
      expect(logs, isNotEmpty);
    });

    test('returns json batch adapter when config is json mode', () async {
      String? captured;
      final adapter = createHistoryUpsellExportAdapter(
        config: const HistoryAnalyticsConfig(
          exportMode: HistoryAnalyticsExportMode.jsonBatch,
          consoleLogLevel: HistoryUpsellLogLevel.info,
        ),
        onJsonBatch: (batch) async => captured = batch,
      );

      await adapter.exportEvents([
        HistoryUpsellEvent(
          type: HistoryUpsellEventType.premiumCtaTapped,
          range: HistoryRange.thirtyDays,
          provider: 'BTMC',
          timestamp: DateTime.utc(2026, 4, 10),
        ),
      ]);

      expect(adapter, isA<JsonBatchHistoryUpsellExportAdapter>());
      expect(captured, isNotNull);
      expect(captured!.contains('premiumCtaTapped'), isTrue);
    });
  });
}
