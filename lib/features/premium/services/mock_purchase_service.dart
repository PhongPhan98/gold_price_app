import '../config/billing_config.dart';
import '../data/premium_status_storage.dart';
import '../models/premium_status.dart';
import '../models/purchase_result.dart';
import 'purchase_service.dart';

class MockPurchaseService implements PurchaseService {
  MockPurchaseService({PremiumStatusStorage? storage})
      : _storage = storage ?? PremiumStatusStorage();

  final PremiumStatusStorage _storage;

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
