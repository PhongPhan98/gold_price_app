import 'package:flutter/material.dart';

import '../../home/models/provider_summary.dart';
import '../../premium/models/premium_status.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../premium/services/premium_state_controller.dart';
import '../models/price_history_point.dart';
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
  PremiumStatus _premiumStatus = const PremiumStatus(
    plan: PremiumPlan.free,
    isActive: false,
  );

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
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

  @override
  Widget build(BuildContext context) {
    final firstSummary = widget.summaries.isNotEmpty ? widget.summaries.first : null;
    final providerName = firstSummary?.title ?? 'Nguồn mặc định';
    final baseValue = double.tryParse(
          (firstSummary?.topBuyPrice ?? '0').replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        95000000;
    final sampleHistory = HistorySampleGenerator.generateFromBase(
      baseValue: baseValue,
      prefixLabel: 'D',
    );
    final insight = HistoryTrendUtils.buildTrendInsight(sampleHistory);

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
                  Text(
                    'Nguồn đang xem: $providerName',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _premiumStatus.isPremium
                        ? 'Bạn đang mở khóa nền tảng lịch sử giá. Đây sẽ là một trong những premium feature mạnh nhất để giữ chân người dùng.'
                        : 'Lịch sử giá và xu hướng là premium feature định hướng ra quyết định tốt hơn. Free tier hiện chỉ xem được bản xem trước.',
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _openPremiumPaywall,
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
                      'Premium sẽ mở khóa insight mạnh hơn, nhiều mốc thời gian hơn và khả năng đọc xu hướng sâu hơn.',
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
    final visiblePoints = isPremium ? points : points.take(3).toList();

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
            isPremium ? 'Dữ liệu xu hướng mở rộng' : 'Bản xem trước xu hướng',
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
                    width: 48,
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
              'Premium sẽ mở khóa thêm mốc thời gian, xu hướng dài hơn và insight tốt hơn.',
              style: TextStyle(color: Colors.orangeAccent, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
