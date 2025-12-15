import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart' as xml;
import 'pages/baotinminhchau_gold_price_page.dart' as baotinminhchau;
import 'pages/mihong_gold_price_page.dart' as mihong;
import 'pages/doji_gold_price_page.dart' as doji;

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
      resizeToAvoidBottomInset: false,
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
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 100.0,
                ), 
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => baotinminhchau.BaoTinMinhChauGoldPriceHomePage(),
                                ),
                              );
                            } else if (item == 'Mi Hồng') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => mihong.MiHongGoldPriceHomePage(),
                                ),
                              );
                            } else if (item == 'Doji') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => doji.DojiGoldPriceHomePage(),
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
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: const Color.fromARGB(255, 202, 182, 1),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 202, 182, 1),
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 133, 30, 30),
    );
  }
}
