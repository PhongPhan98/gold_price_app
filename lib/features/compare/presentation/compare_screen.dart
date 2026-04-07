import 'package:flutter/material.dart';

import '../../home/models/provider_summary.dart';
import '../../home/widgets/summary_badge.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({
    super.key,
    required this.summaries,
  });

  final List<ProviderSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final activeSummaries = summaries.where((item) => !item.hasError).toList();
    final bestBuy = _findBest(activeSummaries, (item) => item.topBuyPrice);
    final bestSell = _findBest(activeSummaries, (item) => item.topSellPrice);

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

  ProviderSummary? _findBest(
    List<ProviderSummary> items,
    String? Function(ProviderSummary item) selector,
  ) {
    ProviderSummary? best;
    int? bestValue;

    for (final item in items) {
      final raw = selector(item);
      final parsed = _parseCurrencyValue(raw);
      if (parsed == null) {
        continue;
      }

      if (bestValue == null || parsed > bestValue) {
        best = item;
        bestValue = parsed;
      }
    }

    return best;
  }

  int? _parseCurrencyValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return null;
    }

    return int.tryParse(digitsOnly);
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
          const Text(
            'Giúp người dùng nhìn ra nơi mua vào / bán ra nổi bật nhất ngay lập tức. Đây là nền tảng tốt cho tính năng premium nâng cao sau này.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
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
          Text(
            title,
            style: const TextStyle(color: Colors.white60),
          ),
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
