import '../models/premium_status.dart';

class BillingConfig {
  static const monthlyProductId = 'gold_price_pro_monthly';
  static const yearlyProductId = 'gold_price_pro_yearly';

  static String productIdForPlan(PremiumPlan plan) {
    switch (plan) {
      case PremiumPlan.proMonthly:
        return monthlyProductId;
      case PremiumPlan.proYearly:
        return yearlyProductId;
      case PremiumPlan.free:
        return 'free';
    }
  }
}
