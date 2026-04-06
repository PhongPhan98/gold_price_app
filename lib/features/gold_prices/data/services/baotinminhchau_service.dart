import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/models/gold_price_entry.dart';

class BaoTinMinhChauService {
  Future<List<GoldPriceEntry>> fetchPrices() async {
    final response = await http.get(
      Uri.parse(
        'http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v',
      ),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final dataList = jsonResponse['DataList']?['Data'] as List<dynamic>? ?? [];

    return dataList.map((data) {
      final row = data['@row'];
      return GoldPriceEntry(
        name: data['@n_$row']?.toString() ?? 'Unknown',
        buyPrice: data['@pb_$row']?.toString() ?? '0',
        sellPrice: data['@ps_$row']?.toString() ?? '0',
        updatedAt: data['@d_$row']?.toString() ?? 'Unknown',
      );
    }).toList();
  }
}
