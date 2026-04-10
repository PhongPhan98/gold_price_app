import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_batch_sender.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_batch_transport.dart';

class _FakeBatchTransport implements HistoryUpsellBatchTransport {
  final List<String> sent = [];
  int failuresRemaining = 0;

  @override
  Future<void> sendBatch(String jsonBatch) async {
    if (failuresRemaining > 0) {
      failuresRemaining -= 1;
      throw Exception('temporary failure');
    }
    sent.add(jsonBatch);
  }
}

void main() {
  group('HistoryUpsellBatchSender', () {
    test('enqueues and flushes in order', () async {
      final transport = _FakeBatchTransport();
      final sender = HistoryUpsellBatchSender(transport: transport);

      await sender.enqueue('batch-1');
      await sender.enqueue('batch-2');

      expect(transport.sent, ['batch-1', 'batch-2']);
      expect(sender.pendingCount, 0);
      expect(sender.stats.sentBatches, 2);
      expect(sender.stats.failedBatches, 0);
      expect(sender.stats.retryAttempts, 0);
    });

    test('retries failed batch with backoff and succeeds', () async {
      final transport = _FakeBatchTransport()..failuresRemaining = 2;
      final delays = <Duration>[];

      final sender = HistoryUpsellBatchSender(
        transport: transport,
        maxRetries: 3,
        baseRetryDelay: const Duration(milliseconds: 100),
        sleep: (delay) async => delays.add(delay),
      );

      await sender.enqueue('batch-1');

      expect(transport.sent, ['batch-1']);
      expect(sender.pendingCount, 0);
      expect(delays.length, 2);
      expect(delays[0], const Duration(milliseconds: 100));
      expect(delays[1], const Duration(milliseconds: 200));
      expect(sender.stats.retryAttempts, 2);
      expect(sender.stats.sentBatches, 1);
      expect(sender.stats.failedBatches, 0);
    });

    test('keeps batch pending when retries are exhausted', () async {
      final transport = _FakeBatchTransport()..failuresRemaining = 10;
      final sender = HistoryUpsellBatchSender(
        transport: transport,
        maxRetries: 1,
        baseRetryDelay: const Duration(milliseconds: 50),
        sleep: (_) async {},
      );

      await sender.enqueue('batch-1');

      expect(transport.sent, isEmpty);
      expect(sender.pendingCount, 1);
      expect(sender.stats.failedBatches, 1);
      expect(sender.stats.retryAttempts, 1);

      transport.failuresRemaining = 0;
      await sender.flush();
      expect(transport.sent, ['batch-1']);
      expect(sender.pendingCount, 0);
      expect(sender.stats.sentBatches, 1);
      expect(sender.stats.failedBatches, 1);
    });
  });
}
