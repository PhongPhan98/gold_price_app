import 'history_upsell_event.dart';

abstract class HistoryUpsellExportAdapter {
  Future<void> exportEvents(List<HistoryUpsellEvent> events);
}

class NoopHistoryUpsellExportAdapter implements HistoryUpsellExportAdapter {
  const NoopHistoryUpsellExportAdapter();

  @override
  Future<void> exportEvents(List<HistoryUpsellEvent> events) async {}
}
