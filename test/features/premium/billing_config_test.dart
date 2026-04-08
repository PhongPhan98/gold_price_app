import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/premium/config/billing_config.dart';
import 'package:gia_vang_hom_nay/features/premium/models/premium_status.dart';

void main() {
  group('BillingConfig', () {
    test('returns correct product ids for plans', () {
      expect(
        BillingConfig.productIdForPlan(PremiumPlan.proMonthly),
        'gold_price_pro_monthly',
      );
      expect(
        BillingConfig.productIdForPlan(PremiumPlan.proYearly),
        'gold_price_pro_yearly',
      );
      expect(BillingConfig.productIdForPlan(PremiumPlan.free), 'free');
    });
  });
}
