import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/compare/utils/compare_utils.dart';
import 'package:gia_vang_hom_nay/features/home/models/provider_summary.dart';

void main() {
  group('CompareUtils', () {
    test('parseCurrencyValue extracts digits correctly', () {
      expect(CompareUtils.parseCurrencyValue('98,500,000'), 98500000);
      expect(CompareUtils.parseCurrencyValue(' 100.000.000 đ '), 100000000);
      expect(CompareUtils.parseCurrencyValue(null), isNull);
      expect(CompareUtils.parseCurrencyValue('abc'), isNull);
    });

    test('findBest returns provider with highest selected value', () {
      const items = [
        ProviderSummary(
          title: 'A',
          subtitle: 's1',
          previewLines: ['x'],
          lastUpdated: null,
          topBuyPrice: '90,000,000',
          topSellPrice: '91,000,000',
        ),
        ProviderSummary(
          title: 'B',
          subtitle: 's2',
          previewLines: ['y'],
          lastUpdated: null,
          topBuyPrice: '95,000,000',
          topSellPrice: '94,000,000',
        ),
      ];

      final bestBuy = CompareUtils.findBest(items, (item) => item.topBuyPrice);
      final bestSell = CompareUtils.findBest(items, (item) => item.topSellPrice);

      expect(bestBuy?.title, 'B');
      expect(bestSell?.title, 'B');
    });
  });
}
