import 'package:flutter/material.dart';

import '../models/gold_price_entry.dart';
import 'gold_price_table.dart';

class ProviderPriceScreen extends StatelessWidget {
  const ProviderPriceScreen({
    super.key,
    required this.title,
    required this.entries,
    required this.isLoading,
    required this.emptyMessage,
    required this.onRefresh,
    this.nameFlex = 3,
    this.buyFlex = 2,
    this.sellFlex = 2,
    this.timeFlex = 3,
  });

  final String title;
  final List<GoldPriceEntry> entries;
  final bool isLoading;
  final String emptyMessage;
  final VoidCallback onRefresh;
  final int nameFlex;
  final int buyFlex;
  final int sellFlex;
  final int timeFlex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.black54],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                    ? Center(
                        child: Text(
                          emptyMessage,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : GoldPriceTable(
                        entries: entries,
                        nameFlex: nameFlex,
                        buyFlex: buyFlex,
                        sellFlex: sellFlex,
                        timeFlex: timeFlex,
                      ),
          ),
        ),
      ),
    );
  }
}
