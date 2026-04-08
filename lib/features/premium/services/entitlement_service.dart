import '../data/premium_status_storage.dart';
import '../models/premium_status.dart';

class EntitlementService {
  EntitlementService({PremiumStatusStorage? storage})
      : _storage = storage ?? PremiumStatusStorage();

  final PremiumStatusStorage _storage;

  Future<PremiumStatus> getCurrentStatus() async {
    return _storage.loadStatus();
  }

  Future<bool> isPremiumActive() async {
    final status = await getCurrentStatus();
    return status.isPremium;
  }

  Future<PremiumStatus> refreshStatus() async {
    return getCurrentStatus();
  }
}
