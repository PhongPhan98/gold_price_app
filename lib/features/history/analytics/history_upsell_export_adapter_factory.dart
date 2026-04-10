import 'history_analytics_config.dart';
import 'history_upsell_export_adapter.dart';

HistoryUpsellExportAdapter createHistoryUpsellExportAdapter({
  HistoryAnalyticsConfig? config,
  void Function(String line)? onConsoleLog,
  Future<void> Function(String jsonBatch)? onJsonBatch,
}) {
  final resolvedConfig = config ?? HistoryAnalyticsConfig.fromBuildMode();

  switch (resolvedConfig.exportMode) {
    case HistoryAnalyticsExportMode.console:
      return ConsoleHistoryUpsellExportAdapter(
        level: resolvedConfig.consoleLogLevel,
        onLog: onConsoleLog,
      );
    case HistoryAnalyticsExportMode.jsonBatch:
      return JsonBatchHistoryUpsellExportAdapter(
        onBatch: onJsonBatch ?? _defaultJsonBatchSink,
      );
  }
}

Future<void> _defaultJsonBatchSink(String jsonBatch) async {
  // Intentionally no-op for now.
  // This is the boundary where Firebase/Amplitude/Mixpanel batch delivery plugs in.
}
