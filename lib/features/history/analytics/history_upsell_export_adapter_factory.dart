import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'history_analytics_config.dart';
import 'history_upsell_batch_sender.dart';
import 'history_upsell_batch_transport.dart';
import 'history_upsell_export_adapter.dart';

HistoryUpsellExportAdapter createHistoryUpsellExportAdapter({
  HistoryAnalyticsConfig? config,
  void Function(String line)? onConsoleLog,
  Future<void> Function(String jsonBatch)? onJsonBatch,
  HistoryUpsellBatchSender? batchSender,
}) {
  final resolvedConfig = config ?? HistoryAnalyticsConfig.fromBuildMode();

  switch (resolvedConfig.exportMode) {
    case HistoryAnalyticsExportMode.console:
      return ConsoleHistoryUpsellExportAdapter(
        level: resolvedConfig.consoleLogLevel,
        onLog: onConsoleLog,
      );
    case HistoryAnalyticsExportMode.jsonBatch:
      final sender = batchSender ?? _createDefaultBatchSenderFromEnv();

      return JsonBatchHistoryUpsellExportAdapter(
        onBatch: onJsonBatch ?? sender?.enqueue ?? _defaultJsonBatchSink,
      );
  }
}

HistoryUpsellBatchSender? _createDefaultBatchSenderFromEnv() {
  const endpoint = String.fromEnvironment('HISTORY_ANALYTICS_ENDPOINT');
  if (endpoint.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(endpoint);
  if (uri == null) {
    return null;
  }

  return HistoryUpsellBatchSender(
    transport: HttpHistoryUpsellBatchTransport(
      endpoint: uri,
      client: http.Client(),
      headers: const {
        'X-Analytics-Source': 'gold_price_app',
      },
    ),
  );
}

Future<void> _defaultJsonBatchSink(String jsonBatch) async {
  debugPrint('history_analytics_batch_skipped: no transport configured');
}
