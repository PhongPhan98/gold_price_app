import '../../home/models/provider_summary.dart';

class HistoryProviderUtils {
  static List<ProviderSummary> ensureProviders(List<ProviderSummary> summaries) {
    if (summaries.isNotEmpty) {
      return summaries;
    }

    return const [
      ProviderSummary(
        title: 'Nguồn mặc định',
        subtitle: 'Đang chờ dữ liệu',
        previewLines: <String>[],
        lastUpdated: null,
        topBuyPrice: null,
        topSellPrice: null,
      ),
    ];
  }

  static double resolveBaseValue(ProviderSummary summary) {
    final buyValue = _parseCurrency(summary.topBuyPrice);
    if (buyValue != null) {
      return buyValue;
    }

    final sellValue = _parseCurrency(summary.topSellPrice);
    if (sellValue != null) {
      return sellValue;
    }

    return 95000000;
  }

  static double? _parseCurrency(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final numeric = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      return null;
    }

    return double.tryParse(numeric);
  }
}
