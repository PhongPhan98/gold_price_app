import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/premium/services/mock_purchase_service.dart';
import 'package:gia_vang_hom_nay/features/premium/services/purchase_service_factory.dart';
import 'package:gia_vang_hom_nay/features/premium/services/store_purchase_service.dart';

void main() {
  group('PurchaseServiceFactory', () {
    test('returns mock service when useMock is true', () {
      final service = PurchaseServiceFactory.create(useMock: true);
      expect(service, isA<MockPurchaseService>());
    });

    test('returns store service when useMock is false', () {
      final service = PurchaseServiceFactory.create(useMock: false);
      expect(service, isA<StorePurchaseService>());
    });
  });
}
