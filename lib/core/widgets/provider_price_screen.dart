import 'package:flutter/material.dart';

import '../models/gold_price_entry.dart';
import 'gold_price_table.dart';

class ProviderPriceScreen extends StatelessWidget {
  const ProviderPriceScreen({
    super.key,
    required this.title,
    required this.entries,
    required this.isLoading,
    required this.emptyMessage,
    required this.onRefresh,
    this.errorMessage,
    this.lastUpdatedLabel,
    this.nameFlex = 3,
    this.buyFlex = 2,
    this.sellFlex = 2,
    this.timeFlex = 3,
  });

  final String title;
  final List<GoldPriceEntry> entries;
  final bool isLoading;
  final String emptyMessage;
  final VoidCallback onRefresh;
  final String? errorMessage;
  final String? lastUpdatedLabel;
  final int nameFlex;
  final int buyFlex;
  final int sellFlex;
  final int timeFlex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            children: [
              if (lastUpdatedLabel != null) ...[
                _InfoBanner(
                  icon: Icons.schedule,
                  text: lastUpdatedLabel!,
                  color: Colors.white70,
                ),
                const SizedBox(height: 12),
              ],
              if (errorMessage != null) ...[
                _InfoBanner(
                  icon: Icons.error_outline,
                  text: errorMessage!,
                  color: Colors.orangeAccent,
                  trailing: TextButton(
                    onPressed: onRefresh,
                    child: const Text('Thử lại'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.72,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : entries.isEmpty
                        ? _EmptyState(
                            message: emptyMessage,
                            onRefresh: onRefresh,
                          )
                        : GoldPriceTable(
                            entries: entries,
                            nameFlex: nameFlex,
                            buyFlex: buyFlex,
                            sellFlex: sellFlex,
                            timeFlex: timeFlex,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.color,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.currency_exchange, size: 54, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại dữ liệu'),
          ),
        ],
      ),
    );
  }
}
