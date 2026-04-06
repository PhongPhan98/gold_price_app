import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../../../../core/models/gold_price_entry.dart';
import '../../../../core/network/gold_price_exception.dart';
import '../../../../core/network/network_constants.dart';
import '../../../../core/utils/date_time_formatter.dart';

class DojiService {
  Future<List<GoldPriceEntry>> fetchPrices() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'http://giavang.doji.vn/api/giavang/?api_key=258fbd2a72ce8481089d88c678e9fe4f',
            ),
          )
          .timeout(NetworkConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw GoldPriceException(
          'Không thể tải dữ liệu Doji (mã ${response.statusCode}).',
        );
      }

      final decodedBody = utf8.decode(response.bodyBytes);
      final document = xml.XmlDocument.parse(decodedBody);
      final jewelryList = document.findAllElements('JewelryList').firstOrNull;
      final rows = jewelryList?.findAllElements('Row') ?? const Iterable.empty();

      return rows.map((row) {
        return GoldPriceEntry(
          name: row.getAttribute('Name') ?? 'Unknown',
          buyPrice: row.getAttribute('Buy') ?? '-',
          sellPrice: row.getAttribute('Sell') ?? '-',
          updatedAt: DateTimeFormatter.ddMMyyyyHHmm(DateTime.now()),
        );
      }).toList();
    } on GoldPriceException {
      rethrow;
    } catch (_) {
      throw const GoldPriceException(
        'Không thể kết nối tới nguồn giá vàng Doji. Vui lòng thử lại.',
      );
    }
  }
}
