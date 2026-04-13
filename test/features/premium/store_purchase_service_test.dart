import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/premium/data/premium_status_storage.dart';
import 'package:gia_vang_hom_nay/features/premium/models/premium_status.dart';
import 'package:gia_vang_hom_nay/features/premium/models/purchase_result.dart';
import 'package:gia_vang_hom_nay/features/premium/services/in_app_billing_gateway.dart';
import 'package:gia_vang_hom_nay/features/premium/services/store_purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBillingGateway implements InAppBillingGateway {
  bool available = true;
  List<StoreProduct> products = const [];
  List<StorePurchaseUpdate> buyUpdates = const [];
  List<StorePurchaseUpdate> restoreUpdates = const [];

  final StreamController<List<StorePurchaseUpdate>> _controller =
      StreamController<List<StorePurchaseUpdate>>.broadcast();

  @override
  Future<void> buy(StoreProduct product) async {
    if (buyUpdates.isNotEmpty) {
      _controller.add(buyUpdates);
    }
  }

  @override
  Future<void> completePurchase(StorePurchaseUpdate purchaseUpdate) async {}

  @override
  Future<bool> isAvailable() async => available;

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseUpdates => _controller.stream;

  @override
  Future<List<StoreProduct>> queryProducts(Set<String> productIds) async => products;

  @override
  Future<void> restorePurchases() async {
    if (restoreUpdates.isNotEmpty) {
      _controller.add(restoreUpdates);
    }
  }
}

void main() {
  group('StorePurchaseService', () {
    late _FakeBillingGateway gateway;
    late PremiumStatusStorage storage;
    late StorePurchaseService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      gateway = _FakeBillingGateway();
      storage = PremiumStatusStorage();
      service = StorePurchaseService(gateway: gateway, storage: storage);
    });

    test('fetchOffers returns mapped store offers', () async {
      gateway.products = const [
        StoreProduct(
          id: 'gold_price_pro_monthly',
          title: 'Monthly Plan',
          description: 'Monthly access',
          price: r'$1.99',
          raw: Object(),
        ),
      ];

      final offers = await service.fetchOffers();

      expect(offers.length, 1);
      expect(offers.first.plan, PremiumPlan.proMonthly);
      expect(offers.first.priceLabel, r'$1.99');
    });

    test('purchase returns error when store is unavailable', () async {
      gateway.available = false;

      final result = await service.purchase(PremiumPlan.proMonthly);

      expect(result.status, PurchaseResultStatus.error);
      expect(result.premiumStatus.isPremium, isFalse);
    });

    test('purchase returns success and persists premium status', () async {
      gateway.products = const [
        StoreProduct(
          id: 'gold_price_pro_monthly',
          title: 'Monthly',
          description: 'desc',
          price: r'$1.99',
          raw: Object(),
        ),
      ];
      gateway.buyUpdates = const [
        StorePurchaseUpdate(
          productId: 'gold_price_pro_monthly',
          status: StorePurchaseStatus.purchased,
        ),
      ];

      final result = await service.purchase(PremiumPlan.proMonthly);
      final persisted = await storage.loadStatus();

      expect(result.status, PurchaseResultStatus.success);
      expect(result.premiumStatus.plan, PremiumPlan.proMonthly);
      expect(persisted.plan, PremiumPlan.proMonthly);
      expect(persisted.isPremium, isTrue);
    });

    test('purchase returns cancelled when user cancels', () async {
      gateway.products = const [
        StoreProduct(
          id: 'gold_price_pro_monthly',
          title: 'Monthly',
          description: 'desc',
          price: r'$1.99',
          raw: Object(),
        ),
      ];
      gateway.buyUpdates = const [
        StorePurchaseUpdate(
          productId: 'gold_price_pro_monthly',
          status: StorePurchaseStatus.cancelled,
        ),
      ];

      final result = await service.purchase(PremiumPlan.proMonthly);

      expect(result.status, PurchaseResultStatus.cancelled);
      expect(result.premiumStatus.isPremium, isFalse);
    });

    test('restore updates premium status from restored purchases', () async {
      gateway.restoreUpdates = const [
        StorePurchaseUpdate(
          productId: 'gold_price_pro_yearly',
          status: StorePurchaseStatus.restored,
        ),
      ];

      final status = await service.restorePurchases();

      expect(status.plan, PremiumPlan.proYearly);
      expect(status.isPremium, isTrue);
    });
  });
}
