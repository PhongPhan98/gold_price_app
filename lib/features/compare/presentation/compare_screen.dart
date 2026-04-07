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
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeSummaries.length,
                itemBuilder: (context, index) {
                  final summary = activeSummaries[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                          summary.title,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 202, 182, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                              SummaryBadge(label: 'Mua vào', value: summary.topBuyPrice!),
                            if (summary.topSellPrice != null)
                              SummaryBadge(label: 'Bán ra', value: summary.topSellPrice!),
                          ],
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
                },
              ),
      ),
    );
  }
}
