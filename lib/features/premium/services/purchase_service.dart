import '../models/premium_status.dart';
import '../models/purchase_result.dart';

abstract class PurchaseService {
  Future<PurchaseResult> purchase(PremiumPlan plan);
  Future<PremiumStatus> restorePurchases();
  String productIdForPlan(PremiumPlan plan);
}
