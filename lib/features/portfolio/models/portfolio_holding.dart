class PortfolioHolding {
  const PortfolioHolding({
    required this.id,
    required this.name,
    required this.provider,
    required this.quantityChi,
    required this.avgBuyPrice,
    this.targetProfitPercent,
    this.targetLossPercent,
  });

  final String id;
  final String name;
  final String provider;
  final double quantityChi;
  final double avgBuyPrice;
  final double? targetProfitPercent;
  final double? targetLossPercent;

  PortfolioHolding copyWith({
    String? id,
    String? name,
    String? provider,
    double? quantityChi,
    double? avgBuyPrice,
    double? targetProfitPercent,
    double? targetLossPercent,
    bool clearTargetProfitPercent = false,
    bool clearTargetLossPercent = false,
  }) {
    return PortfolioHolding(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      quantityChi: quantityChi ?? this.quantityChi,
      avgBuyPrice: avgBuyPrice ?? this.avgBuyPrice,
      targetProfitPercent: clearTargetProfitPercent
          ? null
          : (targetProfitPercent ?? this.targetProfitPercent),
      targetLossPercent: clearTargetLossPercent
          ? null
          : (targetLossPercent ?? this.targetLossPercent),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'quantityChi': quantityChi,
      'avgBuyPrice': avgBuyPrice,
      'targetProfitPercent': targetProfitPercent,
      'targetLossPercent': targetLossPercent,
    };
  }

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      quantityChi: (json['quantityChi'] as num?)?.toDouble() ?? 0,
      avgBuyPrice: (json['avgBuyPrice'] as num?)?.toDouble() ?? 0,
      targetProfitPercent: (json['targetProfitPercent'] as num?)?.toDouble(),
      targetLossPercent: (json['targetLossPercent'] as num?)?.toDouble(),
    );
  }
}
