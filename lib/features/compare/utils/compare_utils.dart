import '../../home/models/provider_summary.dart';

class CompareUtils {
  static int? parseCurrencyValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return null;
    }

    return int.tryParse(digitsOnly);
  }

  static ProviderSummary? findBest(
    List<ProviderSummary> items,
    String? Function(ProviderSummary item) selector,
  ) {
    ProviderSummary? best;
    int? bestValue;

    for (final item in items) {
      final raw = selector(item);
      final parsed = parseCurrencyValue(raw);
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
}
