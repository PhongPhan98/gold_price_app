import 'package:flutter/foundation.dart';

import 'history_upsell_export_adapter.dart';

enum HistoryAnalyticsExportMode {
  console,
  jsonBatch,
}

class HistoryAnalyticsConfig {
  const HistoryAnalyticsConfig({
    required this.exportMode,
    required this.consoleLogLevel,
  });

  final HistoryAnalyticsExportMode exportMode;
  final HistoryUpsellLogLevel consoleLogLevel;

  factory HistoryAnalyticsConfig.fromBuildMode({bool? isReleaseMode}) {
    final release = isReleaseMode ?? kReleaseMode;
    if (release) {
      return const HistoryAnalyticsConfig(
        exportMode: HistoryAnalyticsExportMode.jsonBatch,
        consoleLogLevel: HistoryUpsellLogLevel.info,
      );
    }

    return const HistoryAnalyticsConfig(
      exportMode: HistoryAnalyticsExportMode.console,
      consoleLogLevel: HistoryUpsellLogLevel.debug,
    );
  }
}
