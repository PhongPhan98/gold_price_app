import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/home/models/provider_summary.dart';

void main() {
  group('ProviderSummary', () {
    test('stores summary fields correctly', () {
      const summary = ProviderSummary(
        title: 'Doji',
        subtitle: 'Preview subtitle',
        previewLines: ['line 1', 'line 2'],
        lastUpdated: '07/04/2026 06:00',
        topBuyPrice: '98,000,000',
        topSellPrice: '100,000,000',
        hasError: true,
      );

      expect(summary.title, 'Doji');
      expect(summary.subtitle, 'Preview subtitle');
      expect(summary.previewLines, ['line 1', 'line 2']);
      expect(summary.lastUpdated, '07/04/2026 06:00');
      expect(summary.topBuyPrice, '98,000,000');
      expect(summary.topSellPrice, '100,000,000');
      expect(summary.hasError, isTrue);
    });
  });
}
