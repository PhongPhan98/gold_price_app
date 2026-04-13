import '../models/premium_offer.dart';
import '../models/premium_status.dart';
import '../models/purchase_result.dart';

abstract class PurchaseService {
  Future<List<PremiumOffer>> fetchOffers();
  Future<PurchaseResult> purchase(PremiumPlan plan);
  Future<PremiumStatus> restorePurchases();
  String productIdForPlan(PremiumPlan plan);
}
