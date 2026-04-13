import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/models/provider_summary.dart';
import '../../home/widgets/summary_badge.dart';
import '../../premium/models/premium_status.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../premium/services/premium_state_controller.dart';
import '../utils/compare_utils.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({
    super.key,
    required this.summaries,
  });

  final List<ProviderSummary> summaries;

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
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
    final status = _premiumStateController.status;
    if (!mounted) {
      return;
    }

    setState(() {
      _premiumStatus = status;
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
    final activeSummaries = widget.summaries.where((item) => !item.hasError).toList();
    final bestBuy = CompareUtils.findBest(activeSummaries, (item) => item.topBuyPrice);
    final bestSell = CompareUtils.findBest(activeSummaries, (item) => item.topSellPrice);
    final rankedByBuy = [...activeSummaries]
      ..sort((a, b) => (CompareUtils.parseCurrencyValue(b.topBuyPrice) ?? 0)
          .compareTo(CompareUtils.parseCurrencyValue(a.topBuyPrice) ?? 0));
    final rankedBySell = [...activeSummaries]
      ..sort((a, b) => (CompareUtils.parseCurrencyValue(b.topSellPrice) ?? 0)
          .compareTo(CompareUtils.parseCurrencyValue(a.topSellPrice) ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh nhanh'),
      ),
      body: activeSummaries.isEmpty
          ? const Center(
              child: Text(
                'Chưa có dữ liệu để so sánh',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CompareHeroCard(
                  bestBuyTitle: bestBuy?.title,
                  bestBuyValue: bestBuy?.topBuyPrice,
                  bestSellTitle: bestSell?.title,
                  bestSellValue: bestSell?.topSellPrice,
                ),
                const SizedBox(height: 12),
                _AdvancedCompareSection(
                  isPremium: _premiumStatus.isPremium,
                  rankedByBuy: rankedByBuy,
                  rankedBySell: rankedBySell,
                  onUpgradeTap: _openPremiumPaywall,
                ),
                const SizedBox(height: 12),
                ...activeSummaries.map((summary) {
                  final isBestBuy = bestBuy?.title == summary.title;
                  final isBestSell = bestSell?.title == summary.title;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  summary.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isBestBuy || isBestSell)
                                _BestBadge(
                                  label: isBestBuy && isBestSell
                                      ? 'Tốt nhất'
                                      : isBestBuy
                                          ? 'Mua tốt'
                                          : 'Bán tốt',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            summary.subtitle,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (summary.topBuyPrice != null)
                                SummaryBadge(
                                  label: 'Mua vào',
                                  value: summary.topBuyPrice!,
                                  color: isBestBuy ? Colors.greenAccent : AppTheme.accent,
                                ),
                              if (summary.topSellPrice != null)
                                SummaryBadge(
                                  label: 'Bán ra',
                                  value: summary.topSellPrice!,
                                  color: isBestSell ? Colors.greenAccent : AppTheme.accent,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...summary.previewLines.take(2).map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '• $line',
                                style: const TextStyle(color: Colors.white70, height: 1.35),
                              ),
                            ),
                          ),
                          if (summary.lastUpdated != null)
                            Text(
                              'Cập nhật: ${summary.lastUpdated}',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
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

class _CompareHeroCard extends StatelessWidget {
  const _CompareHeroCard({
    required this.bestBuyTitle,
    required this.bestBuyValue,
    required this.bestSellTitle,
    required this.bestSellValue,
  });

  final String? bestBuyTitle;
  final String? bestBuyValue;
  final String? bestSellTitle;
  final String? bestSellValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan hôm nay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'So sánh nhanh để chọn mức mua vào và bán ra phù hợp nhất.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CompareHighlightCard(
                  title: 'Mua vào nổi bật',
                  provider: bestBuyTitle ?? 'Chưa xác định',
                  value: bestBuyValue ?? '--',
                ),
                _CompareHighlightCard(
                  title: 'Bán ra nổi bật',
                  provider: bestSellTitle ?? 'Chưa xác định',
                  value: bestSellValue ?? '--',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedCompareSection extends StatelessWidget {
  const _AdvancedCompareSection({
    required this.isPremium,
    required this.rankedByBuy,
    required this.rankedBySell,
    required this.onUpgradeTap,
  });

  final bool isPremium;
  final List<ProviderSummary> rankedByBuy;
  final List<ProviderSummary> rankedBySell;
  final VoidCallback onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Xếp hạng chi tiết',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _BestBadge(label: isPremium ? 'Premium' : 'Free'),
              ],
            ),
            const SizedBox(height: 10),
            if (!isPremium) ...[
              const Text(
                'Nâng cấp để xem bảng xếp hạng đầy đủ theo từng nguồn.',
                style: TextStyle(color: Colors.white70, height: 1.35),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onUpgradeTap,
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Mở khóa so sánh nâng cao'),
              ),
            ] else ...[
              const Text('Top mua vào', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...rankedByBuy.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${index + 1}. ${item.title} — ${item.topBuyPrice ?? '--'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }),
              const SizedBox(height: 10),
              const Text('Top bán ra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...rankedBySell.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${index + 1}. ${item.title} — ${item.topSellPrice ?? '--'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompareHighlightCard extends StatelessWidget {
  const _CompareHighlightCard({
    required this.title,
    required this.provider,
    required this.value,
  });

  final String title;
  final String provider;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 6),
          Text(
            provider,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BestBadge extends StatelessWidget {
  const _BestBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
      ),
    );
  }
}
