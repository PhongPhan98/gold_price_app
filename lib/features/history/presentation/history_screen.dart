import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/models/provider_summary.dart';
import '../../premium/models/premium_status.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../premium/services/premium_state_controller.dart';
import '../analytics/history_upsell_event_storage.dart';
import '../analytics/history_upsell_export_adapter_factory.dart';
import '../analytics/history_upsell_tracker.dart';
import '../models/history_range.dart';
import '../models/price_history_point.dart';
import '../utils/history_premium_copy.dart';
import '../utils/history_provider_utils.dart';
import '../utils/history_sample_generator.dart';
import '../utils/history_trend_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.summaries,
  });

  final List<ProviderSummary> summaries;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with WidgetsBindingObserver {
  final PremiumStateController _premiumStateController = PremiumStateController();
  final HistoryUpsellTracker _upsellTracker = HistoryUpsellTracker(
    storage: SharedPrefsHistoryUpsellEventStorage(),
    exportAdapter: createHistoryUpsellExportAdapter(),
    flushThreshold: 8,
  );
  late final List<ProviderSummary> _providers;

  PremiumStatus _premiumStatus = const PremiumStatus(
    plan: PremiumPlan.free,
    isActive: false,
  );
  int _selectedProviderIndex = 0;
  HistoryRange _selectedRange = HistoryRange.sevenDays;

  @override
  void initState() {
    super.initState();
    _providers = HistoryProviderUtils.ensureProviders(widget.summaries);
    WidgetsBinding.instance.addObserver(this);
    _loadPremiumStatus();
    unawaited(_initUpsellTracking());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_upsellTracker.exportNow());
    }
  }

  Future<void> _initUpsellTracking() async {
    await _upsellTracker.initialize();
    final firstProvider = _providers.first.title;
    _upsellTracker.trackScreenViewed(
      range: _selectedRange,
      provider: firstProvider,
    );
  }

  Future<void> _loadPremiumStatus() async {
    await _premiumStateController.refresh();
    if (!mounted) {
      return;
    }
    setState(() {
      _premiumStatus = _premiumStateController.status;
    });
  }

  void _openPremiumPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
    ).then((_) {
      _loadPremiumStatus();
      unawaited(_upsellTracker.exportNow());
    });
  }

  void _onRangeChanged(HistoryRange? value) {
    if (value == null) {
      return;
    }

    if (value.premiumRequired && !_premiumStatus.isPremium) {
      final provider = _providers[_selectedProviderIndex].title;
      _upsellTracker.trackPremiumRangeTapped(
        range: value,
        provider: provider,
      );
      _openPremiumPaywall();
      return;
    }

    setState(() {
      _selectedRange = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedProvider = _providers[_selectedProviderIndex];
    final providerName = selectedProvider.title;
    final baseValue = HistoryProviderUtils.resolveBaseValue(selectedProvider);
    final sampleHistory = HistorySampleGenerator.generateFromBase(
      baseValue: baseValue,
      prefixLabel: 'D',
      range: _selectedRange,
    );
    final insight = HistoryTrendUtils.buildTrendInsight(
      sampleHistory,
      isPremium: _premiumStatus.isPremium,
    );
    final rangeValueMessage = HistoryPremiumCopy.buildRangeValueMessage(
      range: _selectedRange,
      isPremium: _premiumStatus.isPremium,
    );
    final valueBullets = HistoryPremiumCopy.buildValueBullets(
      isPremium: _premiumStatus.isPremium,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giá'),
      ),
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
                    'Lịch sử và xu hướng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chọn nhà cung cấp và khoảng thời gian để xem xu hướng giá.',
                    style: TextStyle(color: Colors.white70, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedProviderIndex,
                    dropdownColor: Colors.black87,
                    key: ValueKey(_selectedProviderIndex),
                    decoration: const InputDecoration(labelText: 'Nhà cung cấp'),
                    style: const TextStyle(color: Colors.white),
                    items: _providers.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedProviderIndex = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<HistoryRange>(
                    initialValue: _selectedRange,
                    dropdownColor: Colors.black87,
                    key: ValueKey(_selectedRange),
                    decoration: const InputDecoration(labelText: 'Khoảng thời gian'),
                    style: const TextStyle(color: Colors.white),
                    items: HistoryRange.values.map((range) {
                      final premiumTag = range.premiumRequired ? ' (Premium)' : '';
                      return DropdownMenuItem<HistoryRange>(
                        value: range,
                        child: Text('${range.label}$premiumTag'),
                      );
                    }).toList(),
                    onChanged: _onRangeChanged,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nguồn: $providerName • Dải: ${_selectedRange.label}',
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(rangeValueMessage, style: const TextStyle(color: Colors.white70, height: 1.35)),
                  const SizedBox(height: 10),
                  ...valueBullets.take(2).map((bullet) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _premiumStatus.isPremium ? Icons.check_circle_outline : Icons.star_outline,
                            size: 18,
                            color: _premiumStatus.isPremium ? Colors.greenAccent : AppTheme.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bullet,
                              style: const TextStyle(color: Colors.white70, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (!_premiumStatus.isPremium) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        final provider = _providers[_selectedProviderIndex].title;
                        _upsellTracker.trackPremiumCtaTapped(
                          range: _selectedRange,
                          provider: provider,
                        );
                        _openPremiumPaywall();
                      },
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: const Text('Mở khóa dải 30/90 ngày'),
                    ),
                  ],
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
                    'Insight xu hướng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight,
                    style: TextStyle(
                      color: _premiumStatus.isPremium ? Colors.greenAccent : Colors.orangeAccent,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _HistoryPreviewCard(
            points: sampleHistory,
            isPremium: _premiumStatus.isPremium,
          ),
        ],
      ),
    );
  }
}

class _HistoryPreviewCard extends StatelessWidget {
  const _HistoryPreviewCard({
    required this.points,
    required this.isPremium,
  });

  final List<PriceHistoryPoint> points;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final visiblePoints = isPremium ? points : points.take(7).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPremium ? 'Dữ liệu mở rộng' : 'Bản xem trước (7 ngày)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...visiblePoints.map((point) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 58,
                      child: Text(point.label, style: const TextStyle(color: Colors.white60)),
                    ),
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: ((point.value % 100000000) / 100000000).clamp(0.15, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isPremium ? Colors.greenAccent : Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      point.value.toStringAsFixed(0),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }),
            if (!isPremium)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Mở khóa Premium để xem thêm mốc 30/90 ngày.',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
