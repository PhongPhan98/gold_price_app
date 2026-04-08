import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/features/premium/models/premium_status.dart';
import 'package:gia_vang_hom_nay/features/premium/services/entitlement_service.dart';
import 'package:gia_vang_hom_nay/features/premium/services/premium_state_controller.dart';

class FakeEntitlementService extends EntitlementService {
  FakeEntitlementService(this.fakeStatus);

  final PremiumStatus fakeStatus;

  @override
  Future<PremiumStatus> refreshStatus() async {
    return fakeStatus;
  }
}

void main() {
  group('PremiumStateController', () {
    test('refresh updates status and premium flag', () async {
      final controller = PremiumStateController(
        entitlementService: FakeEntitlementService(
          const PremiumStatus(plan: PremiumPlan.proYearly, isActive: true),
        ),
      );

      await controller.refresh();

      expect(controller.status.plan, PremiumPlan.proYearly);
      expect(controller.isPremium, isTrue);
    });
  });
}
