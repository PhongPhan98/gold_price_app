import 'package:flutter/material.dart';

import '../../home/models/provider_summary.dart';
import '../../premium/models/premium_status.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../premium/services/premium_state_controller.dart';
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

class _HistoryScreenState extends State<HistoryScreen> {
  final PremiumStateController _premiumStateController = PremiumStateController();
  final HistoryUpsellTracker _upsellTracker = HistoryUpsellTracker();
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
    _loadPremiumStatus();
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
    ).then((_) => _loadPremiumStatus());
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
    final retentionPrompt = HistoryPremiumCopy.buildRetentionPrompt(
      isPremium: _premiumStatus.isPremium,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giá'),
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
                border: Border.all(
                  color: _premiumStatus.isPremium
                      ? Colors.greenAccent.withValues(alpha: 0.4)
                      : Colors.orangeAccent.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lịch sử và xu hướng giá',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Chọn nhà cung cấp để xem trend riêng theo nguồn.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedProviderIndex,
                    dropdownColor: Colors.black87,
                    key: ValueKey(_selectedProviderIndex),
                    decoration: InputDecoration(
                      labelText: 'Nhà cung cấp',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                    decoration: InputDecoration(
                      labelText: 'Khoảng thời gian',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                  const SizedBox(height: 12),
                  Text(
                    'Nguồn đang xem: $providerName • Dải: ${_selectedRange.label}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rangeValueMessage,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  ...valueBullets.map((bullet) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _premiumStatus.isPremium
                                ? Icons.check_circle_outline
                                : Icons.star_outline,
                            size: 18,
                            color: _premiumStatus.isPremium
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
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
                  const SizedBox(height: 10),
                  Text(
                    retentionPrompt,
                    style: TextStyle(
                      color: _premiumStatus.isPremium
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      final provider = _providers[_selectedProviderIndex].title;
                      _upsellTracker.trackPremiumCtaTapped(
                        range: _selectedRange,
                        provider: provider,
                      );
                      _openPremiumPaywall();
                    },
                    icon: Icon(
                      _premiumStatus.isPremium
                          ? Icons.verified
                          : Icons.workspace_premium,
                    ),
                    label: Text(
                      _premiumStatus.isPremium
                          ? 'Bạn đang dùng History Premium'
                          : 'Mở khóa lịch sử nâng cao',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                    'Insight xu hướng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    insight,
                    style: TextStyle(
                      color: _premiumStatus.isPremium
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      height: 1.4,
                    ),
                  ),
                  if (!_premiumStatus.isPremium) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Premium sẽ mở khóa insight mạnh hơn, dải 30/90 ngày và khả năng đọc xu hướng sâu hơn.',
                      style: TextStyle(color: Colors.white60, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _HistoryPreviewCard(
              points: sampleHistory,
              isPremium: _premiumStatus.isPremium,
            ),
          ],
        ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPremium ? 'Dữ liệu xu hướng mở rộng' : 'Bản xem trước xu hướng (7 ngày)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
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
                    child: Text(
                      point.label,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 202, 182, 1)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ((point.value % 100000000) / 100000000)
                            .clamp(0.15, 1.0),
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
          if (!isPremium) ...[
            const SizedBox(height: 12),
            const Text(
              'Premium sẽ mở khóa thêm mốc thời gian 30/90 ngày, xu hướng dài hơn và insight tốt hơn.',
              style: TextStyle(color: Colors.orangeAccent, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
