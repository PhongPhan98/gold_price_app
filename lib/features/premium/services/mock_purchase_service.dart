import '../config/billing_config.dart';
import '../data/premium_status_storage.dart';
import '../models/premium_offer.dart';
import '../models/premium_status.dart';
import '../models/purchase_result.dart';
import 'purchase_service.dart';

class MockPurchaseService implements PurchaseService {
  MockPurchaseService({PremiumStatusStorage? storage})
      : _storage = storage ?? PremiumStatusStorage();

  final PremiumStatusStorage _storage;

  @override
  Future<List<PremiumOffer>> fetchOffers() async {
    return const [
      PremiumOffer(
        plan: PremiumPlan.proMonthly,
        productId: BillingConfig.monthlyProductId,
        title: 'Pro Monthly',
        description: 'Gói premium theo tháng',
        priceLabel: '49.000đ / tháng',
      ),
      PremiumOffer(
        plan: PremiumPlan.proYearly,
        productId: BillingConfig.yearlyProductId,
        title: 'Pro Yearly',
        description: 'Gói premium theo năm',
        priceLabel: '399.000đ / năm',
      ),
    ];
  }

  @override
  Future<PurchaseResult> purchase(PremiumPlan plan) async {
    final status = PremiumStatus(plan: plan, isActive: true);
    await _storage.saveStatus(status);
    return PurchaseResult(
      status: PurchaseResultStatus.success,
      premiumStatus: status,
      message: plan == PremiumPlan.proMonthly
          ? 'Mock purchase monthly thành công.'
          : 'Mock purchase yearly thành công.',
    );
  }

  @override
  Future<PremiumStatus> restorePurchases() async {
    return _storage.loadStatus();
  }

  @override
  String productIdForPlan(PremiumPlan plan) {
    return BillingConfig.productIdForPlan(plan);
  }
}
