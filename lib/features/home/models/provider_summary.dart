class ProviderSummary {
  const ProviderSummary({
    required this.title,
    required this.subtitle,
    required this.previewLines,
    required this.lastUpdated,
    required this.topBuyPrice,
    required this.topSellPrice,
    this.hasError = false,
  });

  final String title;
  final String subtitle;
  final List<String> previewLines;
  final String? lastUpdated;
  final String? topBuyPrice;
  final String? topSellPrice;
  final bool hasError;
}
