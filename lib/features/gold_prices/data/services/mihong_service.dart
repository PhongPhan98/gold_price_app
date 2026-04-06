import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/models/gold_price_entry.dart';

class MiHongService {
  String? _laravelSession;

  Future<void> _fetchLaravelSession() async {
    final response = await http.get(Uri.parse('https://www.mihong.vn'));

    final cookies = response.headers['set-cookie'];
    if (cookies == null) {
      return;
    }

    final sessionMatch = RegExp(r'laravel_session=([^;]+)').firstMatch(cookies);
    if (sessionMatch != null) {
      _laravelSession = sessionMatch.group(1);
    }
  }

  Future<List<GoldPriceEntry>> fetchPrices() async {
    if (_laravelSession == null) {
      await _fetchLaravelSession();
    }

    final response = await http.get(
      Uri.parse('https://www.mihong.vn/api/v1/gold/prices/current'),
      headers: {
        'x-requested-with': 'XMLHttpRequest',
        'referer': 'https://www.mihong.vn/vi/gia-vang-trong-nuoc',
        if (_laravelSession != null) 'Cookie': 'laravel_session=$_laravelSession',
      },
    );

    if (response.statusCode != 200) {
      return [];
    }

    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    if (jsonResponse['success'] != true) {
      return [];
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
  }
}
