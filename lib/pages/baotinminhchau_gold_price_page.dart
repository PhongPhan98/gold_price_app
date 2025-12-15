import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BaoTinMinhChauGoldPriceHomePage extends StatefulWidget {
  const BaoTinMinhChauGoldPriceHomePage({super.key});

  @override
  _BaoTinMinhChauGoldPriceHomePageState createState() => _BaoTinMinhChauGoldPriceHomePageState();
}

class _BaoTinMinhChauGoldPriceHomePageState 
extends State<BaoTinMinhChauGoldPriceHomePage> {
  List<Map<String, String>> goldPrice = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBtmcGoldPrice();
  }

  void fetchBtmcGoldPrice() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(
          'http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dataList = jsonResponse['DataList']['Data'];

        List<Map<String, String>> prices = [];
        for (var data in dataList) {
          prices.add({
            'name': data['@n_${data["@row"]}'] ?? 'Unknown',
            'buyPrice': data['@pb_${data["@row"]}'] ?? '0',
            'sellPrice': data['@ps_${data["@row"]}'] ?? '0',
            'time': data['@d_${data["@row"]}'] ?? 'Unknown',
          });
        }

        setState(() {
          goldPrice = prices;
        });
      } else {
        setState(() {
          goldPrice = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching gold price: $e');
      setState(() {
        goldPrice = [];
      });
    } finally {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giá vàng BTMC',
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
              fetchBtmcGoldPrice();
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
                : goldPrice.isEmpty
                    ? Center(
                        child: Text(
                          'Không có dữ liệu giá vàng BTMC',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      )
                    : Column(
                        children: [
                          Table(
                            border: TableBorder.all(color: Colors.white),
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(3),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color:  Colors.yellow[800],
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
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(3),
                                },
                                children: goldPrice.map((price) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          price['name']!,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          price['buyPrice']!,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          price['sellPrice']!,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          price['time']!,
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
