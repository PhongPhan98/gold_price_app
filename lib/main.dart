import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart' as xml;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giá vàng Việt Nam',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> items = ['Bảo Tín Minh Châu', 'Mi Hồng', "Doji"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(
            fontSize: 35, // Set the title to bold
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,

        backgroundColor: const Color.fromARGB(255, 133, 30, 30),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 100.0,
          ), // Add 20px padding at the topr
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
                items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        if (item == 'Bảo Tín Minh Châu') {
                          // Navigate to GoldPriceNotificationApp
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GoldPriceNotificationApp(),
                            ),
                          );
                        } else if (item == 'Mi Hồng') {
                          // Navigate to MiHongGoldPricePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MiHongGoldPricePage(),
                            ),
                          );
                        } else if (item == 'Doji') {
                          // Navigate to DojiGoldPricePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DojiGoldPricePage(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 35,
                          color: const Color.fromARGB(255, 202, 182, 1),
                          fontFamily: 'Source Sans Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 133, 30, 30),
    );
  }
}

class GoldPriceNotificationApp extends StatelessWidget {
  const GoldPriceNotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giá vàng BTMC',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: GoldPriceHomePage(),
    );
  }
}

class GoldPriceHomePage extends StatefulWidget {
  const GoldPriceHomePage({super.key});

  @override
  _GoldPriceHomePageState createState() => _GoldPriceHomePageState();
}

class _GoldPriceHomePageState extends State<GoldPriceHomePage> {
  List<Map<String, String>> goldPrice = [];
  bool isLoading = false; // Add a loading state

  @override
  void initState() {
    super.initState();
    fetchBtmcGoldPrice();
  }

  void fetchBtmcGoldPrice() async {
    try {
      setState(() {
        isLoading = true; // Show loading indicator
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
      // Delay for 1 second before hiding the loading indicator
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isLoading = false; // Hide loading indicator
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
            fontWeight: FontWeight.bold, // Set the title to bold
          ),
        ),

        backgroundColor: Colors.yellow[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ); // Navigate back to the previous page
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchBtmcGoldPrice(); // Call the API again
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward), // Add a link icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MiHongGoldPricePage()),
              ); // Navigate to MihongGoldPrice page
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              isLoading
                  ? Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator
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
                      // Fixed Header
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
                      // Scrollable Rows
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
                            children:
                                goldPrice.map((price) {
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
    );
  }
}

class MiHongGoldPricePage extends StatelessWidget {
  const MiHongGoldPricePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giá vàng Mi Hồng',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: MiHongGoldPriceHomePage(),
    );
  }
}

class MiHongGoldPriceHomePage extends StatefulWidget {
  const MiHongGoldPriceHomePage({super.key});

  @override
  _MiHongGoldPriceHomePageState createState() =>
      _MiHongGoldPriceHomePageState();
}

class _MiHongGoldPriceHomePageState extends State<MiHongGoldPriceHomePage> {
  List<dynamic> goldPrices = [];
  bool isLoading = false; // Add a loading state
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
        ), // Replace with the session initialization endpoint
      );

      if (response.headers.containsKey('set-cookie')) {
        // Extract the laravel_session from the Set-Cookie header
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
      // Ensure we have a valid laravel_session
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
            fontWeight: FontWeight.bold, // Set the title to bold
          ),
        ),

        backgroundColor: Colors.yellow[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ); // Navigate back to the previous page
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchMiHongGoldPrices(); // Call the API again
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              isLoading
                  ? Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator
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
                      // Fixed Header
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
                      // Scrollable Rows
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
                            children:
                                goldPrices.map((price) {
                                  return TableRow(
                                    children: [
                                      // Code Column
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          price['code'] ?? 'N/A',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // Buying Price and Buy Change Column
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
                                      // Selling Price and Sell Change Column
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
                                      // Date Time Column
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
    );
  }
}

/// VÀNG DOJI PAGE
class DojiGoldPricePage extends StatelessWidget {
  const DojiGoldPricePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giá vàng Doji',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: DojiGoldPriceHomePage(),
    );
  }
}

class DojiGoldPriceHomePage extends StatefulWidget {
  const DojiGoldPriceHomePage({super.key});

  @override
  _DojiGoldPriceHomePageState createState() => _DojiGoldPriceHomePageState();
}

class _DojiGoldPriceHomePageState extends State<DojiGoldPriceHomePage> {
  List<dynamic> goldPrices = [];
  bool isLoading = false; // Add a loading state
  String? laravelSession;

  @override
  void initState() {
    super.initState();
    fetchDojiGoldPrices();
  }

  Future<void> fetchDojiGoldPrices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://giavang.doji.vn/api/giavang/?api_key=258fbd2a72ce8481089d88c678e9fe4f',
        ),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);

        // Parse the XML document
        final document = xml.XmlDocument.parse(decodedBody);

        // Extract only the <Row> elements inside <JewelryList>
        final jewelryList = document.findAllElements('JewelryList').first;
        final rows = jewelryList.findAllElements('Row');

        List<Map<String, String>> prices =
            rows.map((row) {
              return {
                'name': row.getAttribute('Name') ?? 'Unknown',
                'sellPrice': row.getAttribute('Sell') ?? '-',
                'buyPrice': row.getAttribute('Buy') ?? '-',
              };
            }).toList();

        setState(() {
          debugPrint('goldPrices fetch data: ${prices}');
          goldPrices = prices;
        });
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
          'Giá vàng Doji',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Set the title to bold
          ),
        ),

        backgroundColor: Colors.yellow[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ); // Navigate back to the previous page
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchDojiGoldPrices(); // Call the API again
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              isLoading
                  ? Center(
                    child:
                        CircularProgressIndicator(), // Show loading indicator
                  )
                  : goldPrices.isEmpty
                  ? Center(
                    child: Text(
                      'Không có dữ liệu giá vàng Doji',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  )
                  : Column(
                    children: [
                      // Fixed Header
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
                      // Scrollable Rows
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
                            children:
                                goldPrices.map((price) {
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
                                          "${DateTime.now().toLocal()}",
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
    );
  }
}
