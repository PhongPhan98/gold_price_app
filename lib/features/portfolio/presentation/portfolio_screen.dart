import 'dart:math' as math;

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

  Future<void> _persistAndRefresh(List<PortfolioHolding> updated) async {
    await _storage.saveHoldings(updated);
    if (!mounted) {
      return;
    }

    setState(() {
      _holdings = updated;
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

    final providers = _providerNames;
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

    await _persistAndRefresh([..._holdings, next]);

    if (!mounted) {
      return;
    }

    setState(() {
      _nameController.clear();
      _quantityController.clear();
      _avgBuyController.clear();
    });

    _toast('Đã thêm tài sản');
  }

  Future<void> _openEditHoldingDialog(PortfolioHolding item) async {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(text: item.quantityChi.toString());
    final avgBuyController = TextEditingController(text: item.avgBuyPrice.toStringAsFixed(0));
    final providers = _providerNames;

    String selectedProvider = providers.contains(item.provider)
        ? item.provider
        : (providers.isNotEmpty ? providers.first : item.provider);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A1B1B),
              title: const Text('Sửa tài sản'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên tài sản'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProvider,
                      dropdownColor: Colors.black87,
                      items: providers
                          .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() {
                          selectedProvider = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Nguồn giá tham chiếu'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Số lượng (chỉ)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: avgBuyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Giá mua trung bình / chỉ (VND)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    final updatedName = nameController.text.trim();
    final updatedQuantity = double.tryParse(quantityController.text.trim());
    final updatedAvgBuy = double.tryParse(avgBuyController.text.trim());

    if (updatedName.isEmpty || updatedQuantity == null || updatedAvgBuy == null || updatedQuantity <= 0 || updatedAvgBuy <= 0) {
      _toast('Dữ liệu chưa hợp lệ. Không thể cập nhật.');
      return;
    }

    final updated = _holdings
        .map(
          (e) => e.id == item.id
              ? e.copyWith(
                  name: updatedName,
                  provider: selectedProvider,
                  quantityChi: updatedQuantity,
                  avgBuyPrice: updatedAvgBuy,
                )
              : e,
        )
        .toList();

    await _persistAndRefresh(updated);
    _toast('Đã cập nhật tài sản');
  }

  Future<void> _removeHolding(PortfolioHolding item) async {
    final updated = _holdings.where((e) => e.id != item.id).toList();
    await _persistAndRefresh(updated);
    _toast('Đã xóa mục');
  }

  List<String> get _providerNames => widget.summaries.map((e) => e.title).toSet().toList();

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

    final allocationByProvider = <String, double>{};

    for (final item in _holdings) {
      final currentSell = _resolveCurrentSellPrice(item.provider);
      final itemCost = item.avgBuyPrice * item.quantityChi;
      final itemCurrent = currentSell * item.quantityChi;

      totalCost += itemCost;
      totalCurrent += itemCurrent;

      allocationByProvider[item.provider] = (allocationByProvider[item.provider] ?? 0) + itemCurrent;
    }

    final totalPnL = totalCurrent - totalCost;
    final providerNames = _providerNames;
    final selectedProviderValue =
        providerNames.contains(_selectedProvider) && providerNames.isNotEmpty
            ? _selectedProvider
            : (providerNames.isNotEmpty ? providerNames.first : null);

    final allocationItems = allocationByProvider.entries
        .where((e) => e.value > 0)
        .map((e) => _PortfolioAllocationItem(provider: e.key, value: e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                    'Phân bổ theo nguồn giá',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (allocationItems.isEmpty)
                    const Text('Chưa có dữ liệu phân bổ để hiển thị.'),
                  if (allocationItems.isNotEmpty)
                    _PortfolioAllocationChart(
                      items: allocationItems,
                      totalValue: totalCurrent,
                      formatter: _formatCurrency,
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
          if (_holdings.isEmpty) const Text('Chưa có tài sản nào trong portfolio.'),
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
                          onPressed: () => _openEditHoldingDialog(item),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Sửa',
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

class _PortfolioAllocationItem {
  const _PortfolioAllocationItem({
    required this.provider,
    required this.value,
  });

  final String provider;
  final double value;
}

class _PortfolioAllocationChart extends StatelessWidget {
  const _PortfolioAllocationChart({
    required this.items,
    required this.totalValue,
    required this.formatter,
  });

  final List<_PortfolioAllocationItem> items;
  final double totalValue;
  final String Function(double) formatter;

  static const _palette = [
    Color(0xFFE6C200),
    Color(0xFF4CAF50),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
    Color(0xFF26C6DA),
  ];

  @override
  Widget build(BuildContext context) {
    final chartItems = [
      for (var i = 0; i < items.length; i++)
        _ChartSlice(
          label: items[i].provider,
          value: items[i].value,
          color: _palette[i % _palette.length],
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: 170,
            height: 170,
            child: CustomPaint(
              painter: _PieChartPainter(
                slices: chartItems,
                total: totalValue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...chartItems.map((slice) {
          final percent = totalValue <= 0 ? 0 : (slice.value / totalValue) * 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: slice.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${slice.label} • ${percent.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                Text(
                  '${formatter(slice.value)} VND',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ChartSlice {
  const _ChartSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.slices,
    required this.total,
  });

  final List<_ChartSlice> slices;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty || total <= 0) {
      final emptyPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..color = Colors.white24;
      final center = Offset(size.width / 2, size.height / 2);
      final radius = (size.shortestSide / 2) - 12;
      canvas.drawCircle(center, radius, emptyPaint);
      return;
    }

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.shortestSide / 2) - 12,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.butt;

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      paint.color = slice.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.slices != slices;
  }
}
