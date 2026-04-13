import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../premium/models/premium_status.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../premium/services/premium_state_controller.dart';
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
  final PremiumStateController _premiumStateController = PremiumStateController();

  List<PriceAlert> _alerts = [];
  String _selectedProvider = 'Mi Hồng';
  PriceAlertDirection _selectedDirection = PriceAlertDirection.above;
  PremiumStatus _premiumStatus = const PremiumStatus(
    plan: PremiumPlan.free,
    isActive: false,
  );

  @override
  void initState() {
    super.initState();
    _loadScreenData();
  }

  Future<void> _loadScreenData() async {
    final alerts = await _storage.loadAlerts();
    await _premiumStateController.refresh();
    final premiumStatus = _premiumStateController.status;
    if (!mounted) {
      return;
    }
    setState(() {
      _alerts = alerts;
      _premiumStatus = premiumStatus;
    });
  }

  Future<void> _addAlert() async {
    final targetPrice = _targetPriceController.text.trim();
    if (targetPrice.isEmpty) {
      _showToast('Vui lòng nhập giá mục tiêu');
      return;
    }

    final needsPremium = _alerts.isNotEmpty;
    if (needsPremium && !_premiumStatus.isPremium) {
      if (!mounted) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
      ).then((_) => _loadScreenData());
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

    _showToast('Đã tạo cảnh báo mới');
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

  Future<void> _deleteAlert(PriceAlert alert) async {
    final updatedAlerts = _alerts.where((item) => item.id != alert.id).toList();
    await _storage.saveAlerts(updatedAlerts);
    if (!mounted) {
      return;
    }

    setState(() {
      _alerts = updatedAlerts;
    });
    _showToast('Đã xóa cảnh báo');
  }

  void _openPremiumPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
    ).then((_) => _loadScreenData());
  }

  void _showToast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final freeAlertsUsed = _alerts.where((item) => !item.isPremium).length;
    final premiumAlertsCount = _alerts.where((item) => item.isPremium).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cảnh báo giá'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricChip(label: 'Free', value: '$freeAlertsUsed / 1'),
                  _MetricChip(label: 'Premium', value: '$premiumAlertsCount'),
                  _MetricChip(
                    label: 'Gói',
                    value: _premiumStatus.isPremium ? 'Premium' : 'Free',
                    highlight: _premiumStatus.isPremium,
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
                    'Thiết lập cảnh báo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Giá mục tiêu',
                      hintText: 'Ví dụ: 98000000',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Tạo cảnh báo giá mới',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: _targetPriceController.text.trim().isEmpty ? null : _addAlert,
                      icon: const Icon(Icons.add_alert),
                      label: Text(
                        _alerts.isEmpty
                            ? 'Tạo cảnh báo miễn phí'
                            : _premiumStatus.isPremium
                                ? 'Tạo thêm cảnh báo'
                                : 'Tạo thêm cảnh báo (Premium)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _alerts.isEmpty
                        ? 'Bạn có thể tạo 1 cảnh báo miễn phí.'
                        : _premiumStatus.isPremium
                            ? 'Bạn có thể tạo nhiều cảnh báo hơn.'
                            : 'Bạn đã dùng hết giới hạn miễn phí. Nâng cấp để thêm cảnh báo.',
                    style: const TextStyle(color: Colors.white70, height: 1.35),
                  ),
                  if (!_premiumStatus.isPremium) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _openPremiumPaywall,
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: const Text('Xem quyền lợi Premium'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Danh sách cảnh báo',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_alerts.isEmpty)
            const Text(
              'Chưa có cảnh báo nào. Tạo cảnh báo đầu tiên để theo dõi giá thuận tiện hơn.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ..._alerts.map((alert) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          const SizedBox(height: 4),
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
                                'Cảnh báo Premium',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Semantics(
                          label: 'Bật hoặc tắt cảnh báo',
                          child: Switch(
                            value: alert.isEnabled,
                            onChanged: (_) => _toggleAlert(alert),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteAlert(alert),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.white70,
                          tooltip: 'Xóa cảnh báo',
                        ),
                      ],
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? Colors.greenAccent.withValues(alpha: 0.45) : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.greenAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
