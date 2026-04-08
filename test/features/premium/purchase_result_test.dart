import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/premium/models/premium_status.dart';
import 'package:gia_vang_hom_nay/features/premium/models/purchase_result.dart';

void main() {
  group('PurchaseResult', () {
    test('isSuccess is true only for success state', () {
      const success = PurchaseResult(
        status: PurchaseResultStatus.success,
        premiumStatus: PremiumStatus(plan: PremiumPlan.proMonthly, isActive: true),
      );
      const failed = PurchaseResult(
        status: PurchaseResultStatus.error,
        premiumStatus: PremiumStatus(plan: PremiumPlan.free, isActive: false),
      );

      expect(success.isSuccess, isTrue);
      expect(failed.isSuccess, isFalse);
    });
  });
}
