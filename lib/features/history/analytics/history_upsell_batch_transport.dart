import 'package:http/http.dart' as http;

abstract class HistoryUpsellBatchTransport {
  Future<void> sendBatch(String jsonBatch);
}

class HttpHistoryUpsellBatchTransport implements HistoryUpsellBatchTransport {
  HttpHistoryUpsellBatchTransport({
    required this.endpoint,
    http.Client? client,
    this.headers = const <String, String>{},
  }) : _client = client ?? http.Client();

  final Uri endpoint;
  final Map<String, String> headers;
  final http.Client _client;

  @override
  Future<void> sendBatch(String jsonBatch) async {
    final response = await _client.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
      body: jsonBatch,
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to deliver analytics batch: ${response.statusCode}');
    }
  }
}
