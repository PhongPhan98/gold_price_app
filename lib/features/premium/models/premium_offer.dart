import 'premium_status.dart';

class PremiumOffer {
  const PremiumOffer({
    required this.plan,
    required this.productId,
    required this.title,
    required this.description,
    required this.priceLabel,
  });

  final PremiumPlan plan;
  final String productId;
  final String title;
  final String description;
  final String priceLabel;
}
