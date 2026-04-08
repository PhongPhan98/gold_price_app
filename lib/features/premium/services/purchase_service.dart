import '../models/premium_status.dart';

abstract class PurchaseService {
  Future<PremiumStatus> purchase(PremiumPlan plan);
  Future<PremiumStatus> restorePurchases();
  String productIdForPlan(PremiumPlan plan);
}
