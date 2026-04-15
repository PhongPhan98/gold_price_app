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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              _buildHeaderCell(nameHeader, flex: nameFlex),
              _buildHeaderCell(buyHeader, flex: buyFlex),
              _buildHeaderCell(sellHeader, flex: sellFlex),
              _buildHeaderCell(timeHeader, flex: timeFlex),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildValueCell(entry.name, flex: nameFlex),
                    _buildPriceCell(
                      value: entry.buyPrice,
                      change: entry.buyChange,
                      changePercent: entry.buyChangePercent,
                      flex: buyFlex,
                    ),
                    _buildPriceCell(
                      value: entry.sellPrice,
                      change: entry.sellChange,
                      changePercent: entry.sellChangePercent,
                      flex: sellFlex,
                    ),
                    _buildValueCell(entry.updatedAt, flex: timeFlex),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildValueCell(String value, {required int flex}) {
    final displayValue = _displayPriceValue(value);
    return Expanded(
      flex: flex,
      child: Text(
        displayValue,
        style: TextStyle(
          color: displayValue == 'Liên hệ' ? Colors.orangeAccent : Colors.white,
          fontSize: 14,
          fontStyle: displayValue == 'Liên hệ' ? FontStyle.italic : FontStyle.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPriceCell({
    required String value,
    String? change,
    String? changePercent,
    required int flex,
  }) {
    if (change == null && changePercent == null) {
      return _buildValueCell(value, flex: flex);
    }

    final changeText = [
      if (change != null) change,
      if (changePercent != null) '($changePercent%)',
    ].join(' ');

    final changeColor = _getChangeColor(change);
    final icon = _getChangeIcon(change);

    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(
            _displayPriceValue(value),
            style: TextStyle(
              color: _displayPriceValue(value) == 'Liên hệ' ? Colors.orangeAccent : Colors.white,
              fontSize: 14,
              fontStyle: _displayPriceValue(value) == 'Liên hệ' ? FontStyle.italic : FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
          if (changeText.isNotEmpty && _displayPriceValue(value) != 'Liên hệ')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: changeColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    changeText,
                    style: TextStyle(color: changeColor, fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _displayPriceValue(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty || normalized == '-' || normalized == '0' || normalized == '0.0' || normalized == '0.00') {
      return 'Liên hệ';
    }

    return raw;
  }

  Color _getChangeColor(String? change) {
    if (change == null) {
      return Colors.white;
    }

    final normalized = change.trim();
    if (normalized.startsWith('-')) {
      return Colors.redAccent;
    }
    if (normalized == '0' || normalized == '0.0' || normalized == '0.00') {
      return Colors.white70;
    }
    return Colors.greenAccent;
  }

  IconData _getChangeIcon(String? change) {
    if (change == null) {
      return Icons.remove;
    }

    final normalized = change.trim();
    if (normalized.startsWith('-')) {
      return Icons.arrow_downward_rounded;
    }
    if (normalized == '0' || normalized == '0.0' || normalized == '0.00') {
      return Icons.remove;
    }
    return Icons.arrow_upward_rounded;
  }
}
