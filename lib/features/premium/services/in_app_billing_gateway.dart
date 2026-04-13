import 'package:in_app_purchase/in_app_purchase.dart';

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.raw,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final Object raw;
}

enum StorePurchaseStatus {
  pending,
  purchased,
  restored,
  cancelled,
  error,
}

class StorePurchaseUpdate {
  const StorePurchaseUpdate({
    required this.productId,
    required this.status,
    this.errorMessage,
    this.pendingCompletePurchase = false,
    this.raw,
  });

  final String productId;
  final StorePurchaseStatus status;
  final String? errorMessage;
  final bool pendingCompletePurchase;
  final Object? raw;
}

abstract class InAppBillingGateway {
  Future<bool> isAvailable();
  Future<List<StoreProduct>> queryProducts(Set<String> productIds);
  Stream<List<StorePurchaseUpdate>> get purchaseUpdates;
  Future<void> buy(StoreProduct product);
  Future<void> restorePurchases();
  Future<void> completePurchase(StorePurchaseUpdate purchaseUpdate);
}

class RealInAppBillingGateway implements InAppBillingGateway {
  RealInAppBillingGateway({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  @override
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  @override
  Future<List<StoreProduct>> queryProducts(Set<String> productIds) async {
    final response = await _inAppPurchase.queryProductDetails(productIds);
    return response.productDetails
        .map(
          (item) => StoreProduct(
            id: item.id,
            title: item.title,
            description: item.description,
            price: item.price,
            raw: item,
          ),
        )
        .toList();
  }

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseUpdates {
    return _inAppPurchase.purchaseStream.map(
      (items) => items.map(_mapPurchase).toList(),
    );
  }

  @override
  Future<void> buy(StoreProduct product) async {
    final details = product.raw as ProductDetails;
    final param = PurchaseParam(productDetails: details);
    await _inAppPurchase.buyNonConsumable(purchaseParam: param);
  }

  @override
  Future<void> restorePurchases() => _inAppPurchase.restorePurchases();

  @override
  Future<void> completePurchase(StorePurchaseUpdate purchaseUpdate) async {
    final raw = purchaseUpdate.raw;
    if (raw is PurchaseDetails) {
      await _inAppPurchase.completePurchase(raw);
    }
  }

  StorePurchaseUpdate _mapPurchase(PurchaseDetails item) {
    final status = switch (item.status) {
      PurchaseStatus.pending => StorePurchaseStatus.pending,
      PurchaseStatus.purchased => StorePurchaseStatus.purchased,
      PurchaseStatus.restored => StorePurchaseStatus.restored,
      PurchaseStatus.canceled => StorePurchaseStatus.cancelled,
      PurchaseStatus.error => StorePurchaseStatus.error,
    };

    return StorePurchaseUpdate(
      productId: item.productID,
      status: status,
      errorMessage: item.error?.message,
      pendingCompletePurchase: item.pendingCompletePurchase,
      raw: item,
    );
  }
}
