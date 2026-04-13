import 'dart:async';

import '../config/billing_config.dart';
import '../data/premium_status_storage.dart';
import '../models/premium_offer.dart';
import '../models/premium_status.dart';
import '../models/purchase_result.dart';
import 'in_app_billing_gateway.dart';
import 'purchase_service.dart';

class StorePurchaseService implements PurchaseService {
  StorePurchaseService({
    InAppBillingGateway? gateway,
    PremiumStatusStorage? storage,
  })  : _gateway = gateway,
        _storage = storage ?? PremiumStatusStorage();

  InAppBillingGateway? _gateway;
  final PremiumStatusStorage _storage;

  InAppBillingGateway get _resolvedGateway => _gateway ??= RealInAppBillingGateway();

  @override
  Future<List<PremiumOffer>> fetchOffers() async {
    final available = await _resolvedGateway.isAvailable();
    if (!available) {
      return const [];
    }

    final products = await _resolvedGateway.queryProducts({
      BillingConfig.monthlyProductId,
      BillingConfig.yearlyProductId,
    });

    return products
        .map(
          (item) => PremiumOffer(
            plan: _planForProductId(item.id),
            productId: item.id,
            title: item.title,
            description: item.description,
            priceLabel: item.price,
          ),
        )
        .where((offer) => offer.plan != PremiumPlan.free)
        .toList();
  }

  @override
  Future<PurchaseResult> purchase(PremiumPlan plan) async {
    if (plan == PremiumPlan.free) {
      return const PurchaseResult(
        status: PurchaseResultStatus.error,
        premiumStatus: PremiumStatus(plan: PremiumPlan.free, isActive: false),
        message: 'Không thể mua gói free.',
      );
    }

    final available = await _resolvedGateway.isAvailable();
    if (!available) {
      return const PurchaseResult(
        status: PurchaseResultStatus.error,
        premiumStatus: PremiumStatus(plan: PremiumPlan.free, isActive: false),
        message: 'Store billing hiện không khả dụng trên thiết bị này.',
      );
    }

    final productId = productIdForPlan(plan);
    final products = await _resolvedGateway.queryProducts({productId});
    if (products.isEmpty) {
      return PurchaseResult(
        status: PurchaseResultStatus.error,
        premiumStatus: const PremiumStatus(plan: PremiumPlan.free, isActive: false),
        message: 'Không tìm thấy sản phẩm trên store: $productId',
      );
    }

    final product = products.first;
    final completer = Completer<PurchaseResult>();

    late final StreamSubscription<List<StorePurchaseUpdate>> subscription;
    subscription = _resolvedGateway.purchaseUpdates.listen((updates) async {
      for (final update in updates) {
        if (update.productId != productId) {
          continue;
        }

        switch (update.status) {
          case StorePurchaseStatus.pending:
            break;
          case StorePurchaseStatus.cancelled:
            if (!completer.isCompleted) {
              completer.complete(
                const PurchaseResult(
                  status: PurchaseResultStatus.cancelled,
                  premiumStatus: PremiumStatus(plan: PremiumPlan.free, isActive: false),
                  message: 'Người dùng đã hủy giao dịch.',
                ),
              );
            }
            break;
          case StorePurchaseStatus.error:
            if (!completer.isCompleted) {
              completer.complete(
                PurchaseResult(
                  status: PurchaseResultStatus.error,
                  premiumStatus: const PremiumStatus(plan: PremiumPlan.free, isActive: false),
                  message: update.errorMessage ?? 'Không thể xử lý thanh toán trên store.',
                ),
              );
            }
            break;
          case StorePurchaseStatus.purchased:
          case StorePurchaseStatus.restored:
            final status = _statusForProductId(update.productId);
            await _storage.saveStatus(status);
            if (update.pendingCompletePurchase) {
              await _resolvedGateway.completePurchase(update);
            }
            if (!completer.isCompleted) {
              completer.complete(
                PurchaseResult(
                  status: PurchaseResultStatus.success,
                  premiumStatus: status,
                  message: 'Thanh toán thành công qua store.',
                ),
              );
            }
            break;
        }
      }
    });

    try {
      await _resolvedGateway.buy(product);
      final result = await completer.future.timeout(
        const Duration(seconds: 90),
        onTimeout: () => const PurchaseResult(
          status: PurchaseResultStatus.pending,
          premiumStatus: PremiumStatus(plan: PremiumPlan.free, isActive: false),
          message: 'Giao dịch đang chờ xác nhận từ store.',
        ),
      );
      return result;
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<PremiumStatus> restorePurchases() async {
    final available = await _resolvedGateway.isAvailable();
    if (!available) {
      return _storage.loadStatus();
    }

    final completer = Completer<PremiumStatus>();

    late final StreamSubscription<List<StorePurchaseUpdate>> subscription;
    subscription = _resolvedGateway.purchaseUpdates.listen((updates) async {
      for (final update in updates) {
        if (update.status == StorePurchaseStatus.purchased ||
            update.status == StorePurchaseStatus.restored) {
          final restoredStatus = _statusForProductId(update.productId);
          await _storage.saveStatus(restoredStatus);
          if (update.pendingCompletePurchase) {
            await _resolvedGateway.completePurchase(update);
          }
          if (!completer.isCompleted) {
            completer.complete(restoredStatus);
          }
        }
      }
    });

    try {
      await _resolvedGateway.restorePurchases();
      final status = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: _storage.loadStatus,
      );
      return status;
    } finally {
      await subscription.cancel();
    }
  }

  @override
  String productIdForPlan(PremiumPlan plan) {
    return BillingConfig.productIdForPlan(plan);
  }

  PremiumPlan _planForProductId(String productId) {
    if (productId == BillingConfig.monthlyProductId) {
      return PremiumPlan.proMonthly;
    }
    if (productId == BillingConfig.yearlyProductId) {
      return PremiumPlan.proYearly;
    }
    return PremiumPlan.free;
  }

  PremiumStatus _statusForProductId(String productId) {
    final plan = _planForProductId(productId);
    return PremiumStatus(plan: plan, isActive: plan != PremiumPlan.free);
  }
}
