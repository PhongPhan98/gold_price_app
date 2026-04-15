import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/models/gold_price_entry.dart';
import '../../../../core/network/gold_price_exception.dart';
import '../../../../core/network/network_constants.dart';

class BaoTinManhHaiService {
  static const String _graphqlEndpoint = 'https://baotinmanhhai.vn/api/graphql';
  static const String _htmlFallbackUrl = 'http://baotinmanhhai.vn/vi/bang-gia-vang';

  Future<List<GoldPriceEntry>> fetchPrices() async {
    try {
      final entries = await _fetchFromGraphql();
      if (entries.isNotEmpty) {
        return entries;
      }
    } catch (_) {
      // Fallback to HTML parsing below.
    }

    try {
      final entries = await _fetchFromHtml();
      if (entries.isNotEmpty) {
        return entries;
      }
      throw const GoldPriceException(
        'Không tìm thấy dữ liệu giá từ Bảo Tín Mạnh Hải.',
      );
    } on GoldPriceException {
      rethrow;
    } catch (_) {
      throw const GoldPriceException(
        'Không thể kết nối tới nguồn giá vàng Bảo Tín Mạnh Hải. Vui lòng thử lại.',
      );
    }
  }

  Future<List<GoldPriceEntry>> _fetchFromGraphql() async {
    final response = await http
        .post(
          Uri.parse(_graphqlEndpoint),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'operationName': 'GetGoldRates',
            'query':
                '''query GetGoldRates {
  goldRates {
    items {
      code
      name
      vendor_name
      buy_price
      sell_price
      unit
      weight
      trend
      trend_value
      sparkline_data
      sell_sparkline_data
      last_updated
      rate_image
    }
    total_count
    ticker_config {
      max_items
      cta_label
      cta_url
      link_label
      link_url
      ticker_media
    }
  }
}''',
          }),
        )
        .timeout(NetworkConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw GoldPriceException(
        'Không thể tải dữ liệu Bảo Tín Mạnh Hải (mã ${response.statusCode}).',
      );
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

    if (jsonData['errors'] != null) {
      throw const GoldPriceException(
        'Nguồn dữ liệu Bảo Tín Mạnh Hải trả về lỗi.',
      );
    }

    final items = (jsonData['data'] as Map<String, dynamic>?)?['goldRates'];
    final rows = (items as Map<String, dynamic>?)?['items'] as List<dynamic>? ?? [];

    return rows
        .map((item) {
          final row = item as Map<String, dynamic>;
          final trendValue = row['trend_value']?.toString();
          final trend = row['trend']?.toString().toLowerCase();
          final normalizedChange = _normalizeTrendValue(trendValue, trend);
          final buyPrice = _normalizePrice(row['buy_price']);
          final sellPrice = _normalizePrice(row['sell_price']);

          return GoldPriceEntry(
            name: row['name']?.toString() ?? 'N/A',
            buyPrice: buyPrice,
            sellPrice: sellPrice,
            updatedAt: row['last_updated']?.toString() ?? 'N/A',
            buyChange: normalizedChange,
            sellChange: normalizedChange,
          );
        })
        .where((entry) => entry.buyPrice != '-' || entry.sellPrice != '-')
        .toList();
  }

  Future<List<GoldPriceEntry>> _fetchFromHtml() async {
    final response = await http
        .get(Uri.parse(_htmlFallbackUrl))
        .timeout(NetworkConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw GoldPriceException(
        'Không thể tải dữ liệu Bảo Tín Mạnh Hải (mã ${response.statusCode}).',
      );
    }

    final html = response.body;
    final updatedAt = _extractUpdatedAt(html);
    final entries = _extractEntriesFromHtml(html, updatedAt: updatedAt);

    if (entries.isEmpty) {
      throw const GoldPriceException(
        'Không tìm thấy dữ liệu giá từ Bảo Tín Mạnh Hải.',
      );
    }

    return entries;
  }

  List<GoldPriceEntry> _extractEntriesFromHtml(String html, {required String updatedAt}) {
    final rowRegExp = RegExp(
      r'<div class="grid items-center gap-1\.5 lg:gap-4 odd:bg-white even:bg-soft-almond[\s\S]*?<div class="flex items-center justify-center max-md:hidden">',
      caseSensitive: false,
      dotAll: true,
    );

    final nameRegExp = RegExp(r'alt="([^"]+)"', caseSensitive: false);
    final priceRegExp = RegExp(
      r'<span class="text-text-dark font-semibold text-sm md:text-lg">([^<]+)</span>',
      caseSensitive: false,
    );
    final changeRegExp = RegExp(
      r'<span class="text-(?:success|error) font-semibold text-lg">([^<]+)</span>',
      caseSensitive: false,
    );

    final rows = rowRegExp.allMatches(html);
    final entries = <GoldPriceEntry>[];

    for (final row in rows) {
      final block = row.group(0) ?? '';
      final name = nameRegExp.firstMatch(block)?.group(1)?.trim() ?? 'N/A';
      final prices = priceRegExp
          .allMatches(block)
          .map((m) => _normalizePrice(m.group(1) ?? ''))
          .toList();

      if (prices.length < 2) {
        continue;
      }

      // HTML table columns: Bán ra first, Mua vào second.
      final sellPrice = prices[0];
      final buyPrice = prices[1];
      final change = changeRegExp.firstMatch(block)?.group(1)?.trim();

      entries.add(
        GoldPriceEntry(
          name: name,
          buyPrice: buyPrice,
          sellPrice: sellPrice,
          updatedAt: updatedAt,
          buyChange: change,
          sellChange: change,
        ),
      );
    }

    return entries;
  }

  String _extractUpdatedAt(String html) {
    final updatedAtRegExp = RegExp(
      r'\(Cập nhật lúc\s*(?:<!-- -->)?([^<\)]+)(?:<!-- -->)?\)',
      caseSensitive: false,
      dotAll: true,
    );

    final updatedAt = updatedAtRegExp.firstMatch(html)?.group(1)?.trim();
    return (updatedAt == null || updatedAt.isEmpty) ? 'N/A' : updatedAt;
  }

  String _normalizePrice(Object? raw) {
    if (raw == null) {
      return '-';
    }

    final cleaned = raw.toString().replaceAll('\u00A0', '').trim();
    if (cleaned.isEmpty) {
      return '-';
    }

    final digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return cleaned;
    }

    final parsed = int.tryParse(digitsOnly);
    if (parsed == null || parsed <= 1) {
      return '-';
    }

    return _formatThousands(parsed);
  }

  String _formatThousands(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  String? _normalizeTrendValue(String? trendValue, String? trend) {
    if (trendValue == null || trendValue.trim().isEmpty) {
      return null;
    }

    final value = trendValue.trim();
    if (value.startsWith('+') || value.startsWith('-')) {
      return value;
    }

    if (trend == 'up') {
      return '+$value';
    }
    if (trend == 'down') {
      return '-$value';
    }

    return value;
  }
}
