import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/analytics/history_upsell_batch_transport.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('HttpHistoryUpsellBatchTransport', () {
    test('posts JSON batch to endpoint', () async {
      late http.Request captured;

      final client = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });

      final transport = HttpHistoryUpsellBatchTransport(
        endpoint: Uri.parse('https://example.com/analytics'),
        client: client,
      );

      await transport.sendBatch('[{"type":"screenViewed"}]');

      expect(captured.method, 'POST');
      expect(captured.url.toString(), 'https://example.com/analytics');
      expect(captured.headers['Content-Type']!.startsWith('application/json'), isTrue);
    });

    test('throws when endpoint returns failure status', () async {
      final client = MockClient((request) async => http.Response('error', 500));

      final transport = HttpHistoryUpsellBatchTransport(
        endpoint: Uri.parse('https://example.com/analytics'),
        client: client,
      );

      await expectLater(
        transport.sendBatch('[{"type":"screenViewed"}]'),
        throwsException,
      );
    });
  });
}
