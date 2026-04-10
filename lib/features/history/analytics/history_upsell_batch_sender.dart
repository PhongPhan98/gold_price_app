import 'history_upsell_batch_transport.dart';

class HistoryUpsellBatchSender {
  HistoryUpsellBatchSender({required this.transport});

  final HistoryUpsellBatchTransport transport;

  final List<String> _pendingBatches = [];
  bool _isSending = false;

  int get pendingCount => _pendingBatches.length;

  Future<void> enqueue(String jsonBatch) async {
    _pendingBatches.add(jsonBatch);
    await flush();
  }

  Future<void> flush() async {
    if (_isSending || _pendingBatches.isEmpty) {
      return;
    }

    _isSending = true;

    try {
      while (_pendingBatches.isNotEmpty) {
        final current = _pendingBatches.first;

        try {
          await transport.sendBatch(current);
          _pendingBatches.removeAt(0);
        } catch (_) {
          break;
        }
      }
    } finally {
      _isSending = false;
    }
  }
}
