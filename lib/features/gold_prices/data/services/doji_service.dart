import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../../../../core/models/gold_price_entry.dart';

class DojiService {
  Future<List<GoldPriceEntry>> fetchPrices() async {
    final response = await http.get(
      Uri.parse(
        'http://giavang.doji.vn/api/giavang/?api_key=258fbd2a72ce8481089d88c678e9fe4f',
      ),
    );

    if (response.statusCode != 200) {
      return [];
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
        updatedAt: _formatDateTime(DateTime.now()),
      );
    }).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
