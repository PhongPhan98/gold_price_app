import 'premium_status.dart';

enum PurchaseResultStatus {
  success,
  cancelled,
  pending,
  error,
}

class PurchaseResult {
  const PurchaseResult({
    required this.status,
    required this.premiumStatus,
    this.message,
  });

  final PurchaseResultStatus status;
  final PremiumStatus premiumStatus;
  final String? message;

  bool get isSuccess => status == PurchaseResultStatus.success;
}
