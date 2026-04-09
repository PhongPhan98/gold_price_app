import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/history/utils/history_provider_utils.dart';
import 'package:gia_vang_hom_nay/features/home/models/provider_summary.dart';

void main() {
  group('HistoryProviderUtils', () {
    test('ensureProviders returns fallback provider when list is empty', () {
      final providers = HistoryProviderUtils.ensureProviders(const []);

      expect(providers.length, 1);
      expect(providers.first.title, 'Nguồn mặc định');
    });

    test('resolveBaseValue uses topBuyPrice when valid', () {
      const summary = ProviderSummary(
        title: 'Doji',
        subtitle: '',
        previewLines: [],
        lastUpdated: null,
        topBuyPrice: '94,500,000 đ',
        topSellPrice: '95,100,000 đ',
      );

      final value = HistoryProviderUtils.resolveBaseValue(summary);
      expect(value, 94500000);
    });

    test('resolveBaseValue falls back to topSellPrice then default value', () {
      const withSellOnly = ProviderSummary(
        title: 'Mi Hồng',
        subtitle: '',
        previewLines: [],
        lastUpdated: null,
        topBuyPrice: null,
        topSellPrice: '95,300,000 đ',
      );

      const withoutPrices = ProviderSummary(
        title: 'BTMC',
        subtitle: '',
        previewLines: [],
        lastUpdated: null,
        topBuyPrice: null,
        topSellPrice: null,
      );

      expect(HistoryProviderUtils.resolveBaseValue(withSellOnly), 95300000);
      expect(HistoryProviderUtils.resolveBaseValue(withoutPrices), 95000000);
    });
  });
}
