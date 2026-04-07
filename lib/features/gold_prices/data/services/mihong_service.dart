import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/models/gold_price_entry.dart';
import '../../../../core/network/gold_price_exception.dart';
import '../../../../core/network/network_constants.dart';

class MiHongService {
 
  Future<List<GoldPriceEntry>> fetchPrices() async {
    try {
      final url = 'https://api.mihong.vn/v1/gold-prices?market=domestic';
      
      final response = await http
          .get(
            Uri.parse(url)
          )
          .timeout(NetworkConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw GoldPriceException(
          'Không thể tải dữ liệu Mi Hồng (mã ${response.statusCode}).',
        );
      }

      // API returns a direct array, not wrapped in success/data fields
      final data = json.decode(response.body) as List<dynamic>;
      
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
    } catch (e) {
      throw GoldPriceException(
        'Không thể kết nối tới nguồn giá vàng Mi Hồng. Lỗi: $e',
      );
    }
  }
}
