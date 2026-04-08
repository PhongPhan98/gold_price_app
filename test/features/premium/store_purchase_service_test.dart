import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/premium/models/premium_status.dart';
import 'package:gia_vang_hom_nay/features/premium/models/purchase_result.dart';
import 'package:gia_vang_hom_nay/features/premium/services/store_purchase_service.dart';

void main() {
  group('StorePurchaseService', () {
    const service = StorePurchaseService();

    test('purchase returns error until real billing is integrated', () async {
      final result = await service.purchase(PremiumPlan.proMonthly);

      expect(result.status, PurchaseResultStatus.error);
      expect(result.premiumStatus.isPremium, isFalse);
      expect(result.message, 'Store billing chưa được tích hợp thật.');
    });

    test('restore returns free status by default', () async {
      final status = await service.restorePurchases();

      expect(status.plan, PremiumPlan.free);
      expect(status.isPremium, isFalse);
    });
  });
}
