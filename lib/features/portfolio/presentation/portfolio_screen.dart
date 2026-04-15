import 'package:flutter/material.dart';

import '../../home/models/provider_summary.dart';
import '../data/portfolio_storage.dart';
import '../models/portfolio_holding.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({
    super.key,
    required this.summaries,
  });

  final List<ProviderSummary> summaries;

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioStorage _storage = PortfolioStorage();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _avgBuyController = TextEditingController();

  List<PortfolioHolding> _holdings = [];
  String _selectedProvider = 'Mi Hồng';

  @override
  void initState() {
    super.initState();
    if (widget.summaries.isNotEmpty) {
      _selectedProvider = widget.summaries.first.title;
    }
    _loadHoldings();
  }

  Future<void> _loadHoldings() async {
    final holdings = await _storage.loadHoldings();
    if (!mounted) {
      return;
    }

    setState(() {
      _holdings = holdings;
    });
  }

  Future<void> _addHolding() async {
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim());
    final avgBuy = double.tryParse(_avgBuyController.text.trim());

    if (name.isEmpty || quantity == null || avgBuy == null || quantity <= 0 || avgBuy <= 0) {
      _toast('Vui lòng nhập đầy đủ và đúng định dạng');
      return;
    }

    final providers = widget.summaries.map((e) => e.title).toSet().toList();
    final effectiveProvider = providers.contains(_selectedProvider) && providers.isNotEmpty
        ? _selectedProvider
        : (providers.isNotEmpty ? providers.first : 'Mi Hồng');

    final next = PortfolioHolding(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      provider: effectiveProvider,
      quantityChi: quantity,
      avgBuyPrice: avgBuy,
    );

    final updated = [..._holdings, next];
    await _storage.saveHoldings(updated);

    if (!mounted) {
      return;
    }

    setState(() {
      _holdings = updated;
      _nameController.clear();
      _quantityController.clear();
      _avgBuyController.clear();
    });

    _toast('Đã thêm tài sản');
  }

  Future<void> _removeHolding(PortfolioHolding item) async {
    final updated = _holdings.where((e) => e.id != item.id).toList();
    await _storage.saveHoldings(updated);

    if (!mounted) {
      return;
    }

    setState(() {
      _holdings = updated;
    });

    _toast('Đã xóa mục');
  }

  double _resolveCurrentSellPrice(String provider) {
    ProviderSummary? summary;
    for (final item in widget.summaries) {
      if (item.title == provider) {
        summary = item;
        break;
      }
    }
    final raw = summary?.topSellPrice;
    if (raw == null) {
      return 0;
    }

    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }

  String _formatCurrency(double value) {
    final intValue = value.round();
    final raw = intValue.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _avgBuyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalCost = 0;
    double totalCurrent = 0;

    for (final item in _holdings) {
      final currentSell = _resolveCurrentSellPrice(item.provider);
      totalCost += item.avgBuyPrice * item.quantityChi;
      totalCurrent += currentSell * item.quantityChi;
    }

    final totalPnL = totalCurrent - totalCost;
    final providerNames = widget.summaries.map((e) => e.title).toSet().toList();
    final selectedProviderValue =
        providerNames.contains(_selectedProvider) && providerNames.isNotEmpty
            ? _selectedProvider
            : (providerNames.isNotEmpty ? providerNames.first : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio vàng')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan danh mục',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Tổng vốn: ${_formatCurrency(totalCost)} VND'),
                  const SizedBox(height: 4),
                  Text('Giá trị hiện tại: ${_formatCurrency(totalCurrent)} VND'),
                  const SizedBox(height: 4),
                  Text(
                    'P/L: ${_formatCurrency(totalPnL)} VND',
                    style: TextStyle(
                      color: totalPnL >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thêm tài sản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên tài sản (VD: SJC 9999)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedProviderValue,
                    dropdownColor: Colors.black87,
                    items: providerNames
                        .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedProvider = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Nguồn giá tham chiếu'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Số lượng (chỉ)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _avgBuyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Giá mua trung bình / chỉ (VND)'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: providerNames.isEmpty ? null : _addHolding,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm vào portfolio'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Danh sách nắm giữ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_holdings.isEmpty)
            const Text('Chưa có tài sản nào trong portfolio.'),
          ..._holdings.map((item) {
            final currentSell = _resolveCurrentSellPrice(item.provider);
            final cost = item.avgBuyPrice * item.quantityChi;
            final currentValue = currentSell * item.quantityChi;
            final pnl = currentValue - cost;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeHolding(item),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Xóa',
                        ),
                      ],
                    ),
                    Text('Nguồn: ${item.provider}'),
                    Text('Số lượng: ${item.quantityChi} chỉ'),
                    Text('Giá mua TB: ${_formatCurrency(item.avgBuyPrice)} VND'),
                    Text('Giá hiện tại: ${_formatCurrency(currentSell)} VND'),
                    Text(
                      'P/L: ${_formatCurrency(pnl)} VND',
                      style: TextStyle(
                        color: pnl >= 0 ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
