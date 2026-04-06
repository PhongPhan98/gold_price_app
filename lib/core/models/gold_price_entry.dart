class GoldPriceEntry {
  const GoldPriceEntry({
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.updatedAt,
    this.buyChange,
    this.sellChange,
    this.buyChangePercent,
    this.sellChangePercent,
  });

  final String name;
  final String buyPrice;
  final String sellPrice;
  final String updatedAt;
  final String? buyChange;
  final String? sellChange;
  final String? buyChangePercent;
  final String? sellChangePercent;

  bool get hasChangeDetails =>
      buyChange != null ||
      sellChange != null ||
      buyChangePercent != null ||
      sellChangePercent != null;
}
