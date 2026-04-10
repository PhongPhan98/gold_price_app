import 'dart:async';

import 'history_upsell_batch_transport.dart';

class HistoryUpsellBatchSender {
  HistoryUpsellBatchSender({
    required this.transport,
    this.maxRetries = 3,
    this.baseRetryDelay = const Duration(milliseconds: 200),
    this.sleep,
  });

  final HistoryUpsellBatchTransport transport;
  final int maxRetries;
  final Duration baseRetryDelay;
  final Future<void> Function(Duration delay)? sleep;

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
        final delivered = await _sendWithBackoff(current);

        if (delivered) {
          _pendingBatches.removeAt(0);
        } else {
          break;
        }
      }
    } finally {
      _isSending = false;
    }
  }

  Future<bool> _sendWithBackoff(String batch) async {
    final attempts = maxRetries < 0 ? 0 : maxRetries;

    for (var attempt = 0; attempt <= attempts; attempt++) {
      try {
        await transport.sendBatch(batch);
        return true;
      } catch (_) {
        if (attempt == attempts) {
          return false;
        }

        final delay = _buildDelay(attempt);
        if (sleep != null) {
          await sleep!(delay);
        } else {
          await Future<void>.delayed(delay);
        }
      }
    }

    return false;
  }

  Duration _buildDelay(int attempt) {
    final multiplier = 1 << attempt;
    return Duration(milliseconds: baseRetryDelay.inMilliseconds * multiplier);
  }
}
