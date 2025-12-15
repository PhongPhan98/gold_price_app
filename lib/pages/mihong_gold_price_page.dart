import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MiHongGoldPriceHomePage extends StatefulWidget {
  const MiHongGoldPriceHomePage({super.key});

  @override
  _MiHongGoldPriceHomePageState createState() =>
      _MiHongGoldPriceHomePageState();
}

class _MiHongGoldPriceHomePageState extends State<MiHongGoldPriceHomePage> {
  List<dynamic> goldPrices = [];
  bool isLoading = false;
  String? laravelSession;

  @override
  void initState() {
    super.initState();
    fetchMiHongGoldPrices();
  }

  Future<void> fetchLaravelSession() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.mihong.vn',
        ),
      );

      if (response.headers.containsKey('set-cookie')) {
        final cookies = response.headers['set-cookie'];
        final sessionMatch = RegExp(
          r'laravel_session=([^;]+)',
        ).firstMatch(cookies!);
        if (sessionMatch != null) {
          laravelSession = sessionMatch.group(1);
          debugPrint('New laravel_session: $laravelSession');
        }
      }
    } catch (e) {
      debugPrint('Error fetching laravel_session: $e');
    }
  }

  Future<void> fetchMiHongGoldPrices() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (laravelSession == null) {
        await fetchLaravelSession();
      }

      final response = await http.get(
        Uri.parse('https://www.mihong.vn/api/v1/gold/prices/current'),
        headers: {
          'x-requested-with': 'XMLHttpRequest',
          'referer': 'https://www.mihong.vn/vi/gia-vang-trong-nuoc',
          if (laravelSession != null)
            'Cookie': 'laravel_session=$laravelSession',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            goldPrices = jsonResponse['data'];
          });
        } else {
          setState(() {
            goldPrices = [];
          });
        }
      } else {
        debugPrint('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giá vàng Mi Hồng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchMiHongGoldPrices();
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.black54],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : goldPrices.isEmpty
                    ? Center(
                        child: Text(
                          'Không có dữ liệu giá vàng Mi Hồng',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      )
                    : Column(
                        children: [
                          Table(
                            border: TableBorder.all(color: Colors.white),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(3),
                              3: FlexColumnWidth(3),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade800,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Tên giá vàng',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Giá mua vào',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Giá bán ra',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Thời gian',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Table(
                                border: TableBorder.all(color: Colors.white),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(3),
                                  3: FlexColumnWidth(3),
                                },
                                children: goldPrices.map((price) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          price['code'] ?? 'N/A',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${price['buyingPrice']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              '${price['buyChange']} (${price['buyChangePercent']}%)',
                                              style: TextStyle(
                                                color:
                                                    (price['buyChange'] > 0)
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${price['sellingPrice']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              '${price['sellChange']} (${price['sellChangePercent']}%)',
                                              style: TextStyle(
                                                color:
                                                    (price['sellChange'] > 0)
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          price['dateTime'] ?? 'N/A',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
