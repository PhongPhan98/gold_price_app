import 'package:http/http.dart' as http;

abstract class HistoryUpsellBatchTransport {
  Future<void> sendBatch(String jsonBatch);
}

class HttpHistoryUpsellBatchTransport implements HistoryUpsellBatchTransport {
  HttpHistoryUpsellBatchTransport({
    required this.endpoint,
    http.Client? client,
    this.headers = const <String, String>{},
    this.authToken,
    this.authScheme = 'Bearer',
  }) : _client = client ?? http.Client();

  final Uri endpoint;
  final Map<String, String> headers;
  final String? authToken;
  final String authScheme;
  final http.Client _client;

  @override
  Future<void> sendBatch(String jsonBatch) async {
    final mergedHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...headers,
    };

    if (authToken != null && authToken!.isNotEmpty) {
      mergedHeaders['Authorization'] = '$authScheme $authToken';
    }

    final response = await _client.post(
      endpoint,
      headers: mergedHeaders,
      body: jsonBatch,
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to deliver analytics batch: ${response.statusCode}');
    }
  }
}
