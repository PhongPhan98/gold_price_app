import 'mock_purchase_service.dart';
import 'purchase_service.dart';
import 'store_purchase_service.dart';

class PurchaseServiceFactory {
  static PurchaseService create({bool useMock = true}) {
    if (useMock) {
      return MockPurchaseService();
    }
    return const StorePurchaseService();
  }
}
