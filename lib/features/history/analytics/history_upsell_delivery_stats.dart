class HistoryUpsellDeliveryStats {
  const HistoryUpsellDeliveryStats({
    required this.sentBatches,
    required this.failedBatches,
    required this.retryAttempts,
    required this.pendingBatches,
  });

  final int sentBatches;
  final int failedBatches;
  final int retryAttempts;
  final int pendingBatches;
}
