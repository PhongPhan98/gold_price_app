import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/alerts/models/price_alert.dart';

void main() {
  group('PriceAlert', () {
    test('copyWith updates selected fields only', () {
      const alert = PriceAlert(
        id: '1',
        provider: 'Mi Hồng',
        targetPrice: '98000000',
        direction: PriceAlertDirection.above,
        isPremium: false,
      );

      final updated = alert.copyWith(isEnabled: false, isPremium: true);

      expect(updated.id, '1');
      expect(updated.provider, 'Mi Hồng');
      expect(updated.targetPrice, '98000000');
      expect(updated.direction, PriceAlertDirection.above);
      expect(updated.isEnabled, isFalse);
      expect(updated.isPremium, isTrue);
    });

    test('toJson/fromJson roundtrip keeps values', () {
      const alert = PriceAlert(
        id: '2',
        provider: 'Doji',
        targetPrice: '100000000',
        direction: PriceAlertDirection.below,
        isPremium: true,
        isEnabled: false,
      );

      final json = alert.toJson();
      final restored = PriceAlert.fromJson(json);

      expect(restored.id, '2');
      expect(restored.provider, 'Doji');
      expect(restored.targetPrice, '100000000');
      expect(restored.direction, PriceAlertDirection.below);
      expect(restored.isPremium, isTrue);
      expect(restored.isEnabled, isFalse);
    });
  });
}
