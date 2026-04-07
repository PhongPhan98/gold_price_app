import 'package:flutter/material.dart';

import '../../premium/data/premium_status_storage.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../data/price_alert_storage.dart';
import '../models/price_alert.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final PriceAlertStorage _storage = PriceAlertStorage();
  final TextEditingController _targetPriceController = TextEditingController();
  final PremiumStatusStorage _premiumStatusStorage = PremiumStatusStorage();

  List<PriceAlert> _alerts = [];
  String _selectedProvider = 'Mi Hồng';
  PriceAlertDirection _selectedDirection = PriceAlertDirection.above;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alerts = await _storage.loadAlerts();
    if (!mounted) {
      return;
    }
    setState(() {
      _alerts = alerts;
    });
  }

  Future<void> _addAlert() async {
    final premiumStatus = await _premiumStatusStorage.loadStatus();
    final targetPrice = _targetPriceController.text.trim();
    if (targetPrice.isEmpty) {
      return;
    }

    final needsPremium = _alerts.isNotEmpty;
    if (needsPremium && !premiumStatus.isPremium) {
      if (!mounted) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
      );
      return;
    }

    final nextAlert = PriceAlert(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      provider: _selectedProvider,
      targetPrice: targetPrice,
      direction: _selectedDirection,
      isPremium: needsPremium,
    );

    final updatedAlerts = [..._alerts, nextAlert];
    await _storage.saveAlerts(updatedAlerts);
    if (!mounted) {
      return;
    }

    setState(() {
      _alerts = updatedAlerts;
      _targetPriceController.clear();
    });
  }

  Future<void> _toggleAlert(PriceAlert alert) async {
    final updatedAlerts = _alerts
        .map((item) => item.id == alert.id ? item.copyWith(isEnabled: !item.isEnabled) : item)
        .toList();
    await _storage.saveAlerts(updatedAlerts);
    if (!mounted) {
      return;
    }

    setState(() {
      _alerts = updatedAlerts;
    });
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cảnh báo giá'),
        backgroundColor: Colors.yellow[800],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thiết lập cảnh báo giá',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProvider,
                    dropdownColor: Colors.black87,
                    items: const [
                      DropdownMenuItem(value: 'Bảo Tín Minh Châu', child: Text('Bảo Tín Minh Châu')),
                      DropdownMenuItem(value: 'Mi Hồng', child: Text('Mi Hồng')),
                      DropdownMenuItem(value: 'Doji', child: Text('Doji')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedProvider = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Nguồn giá'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PriceAlertDirection>(
                    initialValue: _selectedDirection,
                    dropdownColor: Colors.black87,
                    items: const [
                      DropdownMenuItem(
                        value: PriceAlertDirection.above,
                        child: Text('Khi giá cao hơn mức này'),
                      ),
                      DropdownMenuItem(
                        value: PriceAlertDirection.below,
                        child: Text('Khi giá thấp hơn mức này'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedDirection = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Điều kiện'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _targetPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá mục tiêu',
                      hintText: 'Ví dụ: 98000000',
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _addAlert,
                    icon: const Icon(Icons.add_alert),
                    label: Text(_alerts.isEmpty ? 'Tạo cảnh báo miễn phí' : 'Tạo thêm cảnh báo (Premium)'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _alerts.isEmpty
                        ? 'Bạn đang ở free tier: tạo cảnh báo đầu tiên miễn phí.'
                        : 'Bạn đã dùng hết quota miễn phí. Tạo thêm cảnh báo cần Premium.',
                    style: const TextStyle(color: Colors.white60, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
                      );
                    },
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: const Text('Xem quyền lợi Premium'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Danh sách cảnh báo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_alerts.isEmpty)
              const Text(
                'Chưa có cảnh báo nào. Hãy tạo cảnh báo đầu tiên để tăng khả năng quay lại app mỗi ngày.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ..._alerts.map((alert) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: alert.isPremium
                        ? Colors.orangeAccent.withValues(alpha: 0.45)
                        : Colors.white12,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${alert.provider} • ${alert.targetPrice}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alert.direction == PriceAlertDirection.above
                                ? 'Báo khi giá vượt mức này'
                                : 'Báo khi giá thấp hơn mức này',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (alert.isPremium)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                'Premium feature',
                                style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Switch(
                      value: alert.isEnabled,
                      onChanged: (_) => _toggleAlert(alert),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
