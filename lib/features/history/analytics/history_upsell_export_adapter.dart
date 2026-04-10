import 'dart:convert';

import 'history_upsell_event.dart';

enum HistoryUpsellLogLevel {
  debug,
  info,
}

abstract class HistoryUpsellExportAdapter {
  Future<void> exportEvents(List<HistoryUpsellEvent> events);
}

class NoopHistoryUpsellExportAdapter implements HistoryUpsellExportAdapter {
  const NoopHistoryUpsellExportAdapter();

  @override
  Future<void> exportEvents(List<HistoryUpsellEvent> events) async {}
}

class JsonBatchHistoryUpsellExportAdapter implements HistoryUpsellExportAdapter {
  JsonBatchHistoryUpsellExportAdapter({
    required this.onBatch,
  });

  final Future<void> Function(String jsonBatch) onBatch;

  @override
  Future<void> exportEvents(List<HistoryUpsellEvent> events) async {
    final payload = events.map((event) => event.toMap()).toList();
    await onBatch(json.encode(payload));
  }
}

class ConsoleHistoryUpsellExportAdapter implements HistoryUpsellExportAdapter {
  ConsoleHistoryUpsellExportAdapter({
    this.level = HistoryUpsellLogLevel.info,
    this.onLog,
  });

  final HistoryUpsellLogLevel level;
  final void Function(String line)? onLog;

  @override
  Future<void> exportEvents(List<HistoryUpsellEvent> events) async {
    for (final event in events) {
      final line = '[${level.name}] history_upsell ${json.encode(event.toMap())}';
      if (onLog != null) {
        onLog!(line);
      }
    }
  }
}
