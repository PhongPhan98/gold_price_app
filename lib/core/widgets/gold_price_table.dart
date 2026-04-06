import 'package:flutter/material.dart';

import '../models/gold_price_entry.dart';

class GoldPriceTable extends StatelessWidget {
  const GoldPriceTable({
    super.key,
    required this.entries,
    this.nameHeader = 'Tên giá vàng',
    this.buyHeader = 'Giá mua vào',
    this.sellHeader = 'Giá bán ra',
    this.timeHeader = 'Thời gian',
    this.nameFlex = 3,
    this.buyFlex = 2,
    this.sellFlex = 2,
    this.timeFlex = 3,
  });

  final List<GoldPriceEntry> entries;
  final String nameHeader;
  final String buyHeader;
  final String sellHeader;
  final String timeHeader;
  final int nameFlex;
  final int buyFlex;
  final int sellFlex;
  final int timeFlex;

  @override
  Widget build(BuildContext context) {
    final columnWidths = <int, TableColumnWidth>{
      0: FlexColumnWidth(nameFlex.toDouble()),
      1: FlexColumnWidth(buyFlex.toDouble()),
      2: FlexColumnWidth(sellFlex.toDouble()),
      3: FlexColumnWidth(timeFlex.toDouble()),
    };

    return Column(
      children: [
        Table(
          border: TableBorder.all(color: Colors.white),
          columnWidths: columnWidths,
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.yellow[800]),
              children: [
                _buildHeaderCell(nameHeader),
                _buildHeaderCell(buyHeader),
                _buildHeaderCell(sellHeader),
                _buildHeaderCell(timeHeader),
              ],
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(color: Colors.white),
              columnWidths: columnWidths,
              children: entries.map(_buildDataRow).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildDataRow(GoldPriceEntry entry) {
    return TableRow(
      children: [
        _buildValueCell(entry.name),
        _buildPriceCell(
          value: entry.buyPrice,
          change: entry.buyChange,
          changePercent: entry.buyChangePercent,
        ),
        _buildPriceCell(
          value: entry.sellPrice,
          change: entry.sellChange,
          changePercent: entry.sellChangePercent,
        ),
        _buildValueCell(entry.updatedAt),
      ],
    );
  }

  Widget _buildValueCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPriceCell({
    required String value,
    String? change,
    String? changePercent,
  }) {
    if (change == null && changePercent == null) {
      return _buildValueCell(value);
    }

    final changeText = [
      if (change != null) change,
      if (changePercent != null) '($changePercent%)',
    ].join(' ');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (changeText.isNotEmpty)
            Text(
              changeText,
              style: TextStyle(
                color: _getChangeColor(change),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Color _getChangeColor(String? change) {
    if (change == null) {
      return Colors.white;
    }

    final normalized = change.toString().trim();
    if (normalized.startsWith('-')) {
      return Colors.red;
    }
    if (normalized == '0' || normalized == '0.0' || normalized == '0.00') {
      return Colors.white;
    }
    return Colors.green;
  }
}
