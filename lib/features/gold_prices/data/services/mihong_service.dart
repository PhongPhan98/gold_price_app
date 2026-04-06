import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/models/gold_price_entry.dart';
import '../../../../core/network/gold_price_exception.dart';
import '../../../../core/network/network_constants.dart';

class MiHongService {
  String? _laravelSession;

  Future<void> _fetchLaravelSession() async {
    final response = await http
        .get(Uri.parse('https://www.mihong.vn'))
        .timeout(NetworkConstants.requestTimeout);

    final cookies = response.headers['set-cookie'];
    if (cookies == null) {
      throw const GoldPriceException(
        'Không lấy được phiên làm việc từ Mi Hồng.',
      );
    }

    final sessionMatch = RegExp(r'laravel_session=([^;]+)').firstMatch(cookies);
    if (sessionMatch != null) {
      _laravelSession = sessionMatch.group(1);
      return;
    }

    throw const GoldPriceException(
      'Không tìm thấy phiên truy cập hợp lệ từ Mi Hồng.',
    );
  }

  Future<List<GoldPriceEntry>> fetchPrices() async {
    try {
      if (_laravelSession == null) {
        await _fetchLaravelSession();
      }

      final response = await http
          .get(
            Uri.parse('https://www.mihong.vn/api/v1/gold/prices/current'),
            headers: {
              'x-requested-with': 'XMLHttpRequest',
              'referer': 'https://www.mihong.vn/vi/gia-vang-trong-nuoc',
              if (_laravelSession != null)
                'Cookie': 'laravel_session=$_laravelSession',
            },
          )
          .timeout(NetworkConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw GoldPriceException(
          'Không thể tải dữ liệu Mi Hồng (mã ${response.statusCode}).',
        );
      }

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      if (jsonResponse['success'] != true) {
        throw const GoldPriceException(
          'Mi Hồng chưa trả về dữ liệu hợp lệ.',
        );
      }

      final data = jsonResponse['data'] as List<dynamic>? ?? [];
      return data.map((item) {
        return GoldPriceEntry(
          name: item['code']?.toString() ?? 'N/A',
          buyPrice: item['buyingPrice']?.toString() ?? 'N/A',
          sellPrice: item['sellingPrice']?.toString() ?? 'N/A',
          updatedAt: item['dateTime']?.toString() ?? 'N/A',
          buyChange: item['buyChange']?.toString(),
          sellChange: item['sellChange']?.toString(),
          buyChangePercent: item['buyChangePercent']?.toString(),
          sellChangePercent: item['sellChangePercent']?.toString(),
        );
      }).toList();
    } on GoldPriceException {
      rethrow;
    } catch (_) {
      throw const GoldPriceException(
        'Không thể kết nối tới nguồn giá vàng Mi Hồng. Vui lòng thử lại.',
      );
    }
  }
}
