import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_batch_sender.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_batch_transport.dart';

class _FakeBatchTransport implements HistoryUpsellBatchTransport {
  final List<String> sent = [];
  bool failNext = false;

  @override
  Future<void> sendBatch(String jsonBatch) async {
    if (failNext) {
      failNext = false;
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
    });

    test('keeps failed batch and retries later', () async {
      final transport = _FakeBatchTransport()..failNext = true;
      final sender = HistoryUpsellBatchSender(transport: transport);

      await sender.enqueue('batch-1');
      expect(sender.pendingCount, 1);
      expect(transport.sent, isEmpty);

      await sender.flush();
      expect(transport.sent, ['batch-1']);
      expect(sender.pendingCount, 0);
    });
  });
}
