import 'package:flutter/material.dart';

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
        child: activeSummaries.isEmpty
            ? const Center(
                child: Text(
                  'Chưa có dữ liệu để so sánh',
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
                    onUpgradeTap: _openPremiumPaywall,
                    isPremium: _premiumStatus.isPremium,
                  ),
                  const SizedBox(height: 16),
                  _AdvancedCompareSection(
                    isPremium: _premiumStatus.isPremium,
                    rankedByBuy: rankedByBuy,
                    rankedBySell: rankedBySell,
                    onUpgradeTap: _openPremiumPaywall,
                  ),
                  const SizedBox(height: 16),
                  ...activeSummaries.map((summary) {
                    final isBestBuy = bestBuy?.title == summary.title;
                    final isBestSell = bestSell?.title == summary.title;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isBestBuy || isBestSell)
                              ? const Color.fromARGB(255, 202, 182, 1)
                              : Colors.white12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  summary.title,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 202, 182, 1),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isBestBuy || isBestSell)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 202, 182, 1)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isBestBuy && isBestSell
                                        ? 'Tốt nhất'
                                        : isBestBuy
                                            ? 'Mua tốt'
                                            : 'Bán tốt',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 202, 182, 1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            summary.subtitle,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (summary.topBuyPrice != null)
                                SummaryBadge(
                                  label: 'Mua vào',
                                  value: summary.topBuyPrice!,
                                  color: isBestBuy
                                      ? Colors.greenAccent
                                      : const Color.fromARGB(255, 202, 182, 1),
                                ),
                              if (summary.topSellPrice != null)
                                SummaryBadge(
                                  label: 'Bán ra',
                                  value: summary.topSellPrice!,
                                  color: isBestSell
                                      ? Colors.greenAccent
                                      : const Color.fromARGB(255, 202, 182, 1),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...summary.previewLines.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '• $line',
                                style: const TextStyle(
                                  color: Colors.white,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                          if (summary.lastUpdated != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Cập nhật: ${summary.lastUpdated}',
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ],
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

class _CompareHeroCard extends StatelessWidget {
  const _CompareHeroCard({
    required this.bestBuyTitle,
    required this.bestBuyValue,
    required this.bestSellTitle,
    required this.bestSellValue,
    required this.onUpgradeTap,
    required this.isPremium,
  });

  final String? bestBuyTitle;
  final String? bestBuyValue;
  final String? bestSellTitle;
  final String? bestSellValue;
  final VoidCallback onUpgradeTap;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromARGB(255, 202, 182, 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan so sánh',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isPremium
                ? 'Bạn đang mở khóa compare nâng cao. Đây là khu vực có thể tăng giá trị trả phí rõ rệt cho người dùng.'
                : 'Giúp người dùng nhìn ra nơi mua vào / bán ra nổi bật nhất ngay lập tức. Compare nâng cao sẽ là tính năng premium mạnh để bán về sau.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onUpgradeTap,
            icon: Icon(isPremium ? Icons.verified : Icons.workspace_premium),
            label: Text(
              isPremium ? 'Bạn đang dùng Compare Premium' : 'Mở khóa compare nâng cao',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : Colors.orangeAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Compare nâng cao',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isPremium ? Colors.greenAccent : Colors.orangeAccent)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPremium ? 'Đã mở khóa' : 'Premium',
                  style: TextStyle(
                    color: isPremium ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isPremium
                ? 'Bạn có thể xem bảng xếp hạng mua vào / bán ra ngay tại đây.'
                : 'Tính năng này sẽ mở khóa bảng xếp hạng và góc nhìn so sánh tốt hơn cho người dùng premium.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          if (!isPremium)
            OutlinedButton.icon(
              onPressed: onUpgradeTap,
              icon: const Icon(Icons.lock_open),
              label: const Text('Nâng cấp để xem compare nâng cao'),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top mua vào',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...rankedByBuy.take(3).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${index + 1}. ${item.title} — ${item.topBuyPrice ?? '--'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Text(
                  'Top bán ra',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...rankedBySell.take(3).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${index + 1}. ${item.title} — ${item.topSellPrice ?? '--'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }),
              ],
            ),
        ],
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
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          Text(
            provider,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color.fromARGB(255, 202, 182, 1),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
