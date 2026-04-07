import '../data/premium_status_storage.dart';
import '../models/premium_status.dart';
import 'purchase_service.dart';

class MockPurchaseService implements PurchaseService {
  MockPurchaseService({PremiumStatusStorage? storage})
      : _storage = storage ?? PremiumStatusStorage();

  final PremiumStatusStorage _storage;

  @override
  Future<PremiumStatus> purchase(PremiumPlan plan) async {
    final status = PremiumStatus(plan: plan, isActive: true);
    await _storage.saveStatus(status);
    return status;
  }

  @override
  Future<PremiumStatus> restorePurchases() async {
    return _storage.loadStatus();
  }
}
