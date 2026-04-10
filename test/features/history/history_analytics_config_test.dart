import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_analytics_config.dart';

void main() {
  group('HistoryAnalyticsConfig', () {
    test('uses console mode for non-release builds', () {
      final config = HistoryAnalyticsConfig.fromBuildMode(isReleaseMode: false);

      expect(config.exportMode, HistoryAnalyticsExportMode.console);
    });

    test('uses json batch mode for release builds', () {
      final config = HistoryAnalyticsConfig.fromBuildMode(isReleaseMode: true);

      expect(config.exportMode, HistoryAnalyticsExportMode.jsonBatch);
    });
  });
}
