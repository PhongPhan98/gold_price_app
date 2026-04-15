import 'package:http/http.dart' as http;

import '../../../../core/models/gold_price_entry.dart';
import '../../../../core/network/gold_price_exception.dart';
import '../../../../core/network/network_constants.dart';

class BaoTinManhHaiService {
  Future<List<GoldPriceEntry>> fetchPrices() async {
    try {
      final response = await http
          .get(Uri.parse('http://baotinmanhhai.vn/vi/bang-gia-vang'))
          .timeout(NetworkConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw GoldPriceException(
          'Không thể tải dữ liệu Bảo Tín Mạnh Hải (mã ${response.statusCode}).',
        );
      }

      final html = response.body;
      final updatedAt = _extractUpdatedAt(html);
      final entries = _extractEntries(html, updatedAt: updatedAt);

      if (entries.isEmpty) {
        throw const GoldPriceException(
          'Không tìm thấy dữ liệu giá từ Bảo Tín Mạnh Hải.',
        );
      }

      return entries;
    } on GoldPriceException {
      rethrow;
    } catch (_) {
      throw const GoldPriceException(
        'Không thể kết nối tới nguồn giá vàng Bảo Tín Mạnh Hải. Vui lòng thử lại.',
      );
    }
  }

  List<GoldPriceEntry> _extractEntries(String html, {required String updatedAt}) {
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

      // Website columns: Bán ra trước, Mua vào sau.
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

  String _normalizePrice(String raw) {
    final cleaned = raw.replaceAll('\u00A0', '').trim();
    if (cleaned.isEmpty) {
      return '-';
    }

    return cleaned;
  }
}
