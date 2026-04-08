import '../models/premium_status.dart';
import '../models/purchase_result.dart';
import 'purchase_service.dart';

class StorePurchaseService implements PurchaseService {
  const StorePurchaseService();

  @override
  Future<PurchaseResult> purchase(PremiumPlan plan) async {
    return PurchaseResult(
      status: PurchaseResultStatus.error,
      premiumStatus: const PremiumStatus(
        plan: PremiumPlan.free,
        isActive: false,
      ),
      message: 'Store billing chưa được tích hợp thật.',
    );
  }

  @override
  Future<PremiumStatus> restorePurchases() async {
    return const PremiumStatus(plan: PremiumPlan.free, isActive: false);
  }

  @override
  String productIdForPlan(PremiumPlan plan) {
    switch (plan) {
      case PremiumPlan.proMonthly:
        return 'gold_price_pro_monthly';
      case PremiumPlan.proYearly:
        return 'gold_price_pro_yearly';
      case PremiumPlan.free:
        return 'free';
    }
  }
}
