import 'package:flutter/foundation.dart';

import '../models/premium_status.dart';
import 'entitlement_service.dart';

class PremiumStateController extends ChangeNotifier {
  PremiumStateController({EntitlementService? entitlementService})
      : _entitlementService = entitlementService ?? EntitlementService();

  final EntitlementService _entitlementService;

  PremiumStatus _status = const PremiumStatus(
    plan: PremiumPlan.free,
    isActive: false,
  );

  PremiumStatus get status => _status;
  bool get isPremium => _status.isPremium;

  Future<void> refresh() async {
    _status = await _entitlementService.refreshStatus();
    notifyListeners();
  }
}
