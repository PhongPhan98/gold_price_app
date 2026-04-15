class PortfolioHolding {
  const PortfolioHolding({
    required this.id,
    required this.name,
    required this.provider,
    required this.quantityChi,
    required this.avgBuyPrice,
  });

  final String id;
  final String name;
  final String provider;
  final double quantityChi;
  final double avgBuyPrice;

  PortfolioHolding copyWith({
    String? id,
    String? name,
    String? provider,
    double? quantityChi,
    double? avgBuyPrice,
  }) {
    return PortfolioHolding(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      quantityChi: quantityChi ?? this.quantityChi,
      avgBuyPrice: avgBuyPrice ?? this.avgBuyPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'quantityChi': quantityChi,
      'avgBuyPrice': avgBuyPrice,
    };
  }

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      quantityChi: (json['quantityChi'] as num?)?.toDouble() ?? 0,
      avgBuyPrice: (json['avgBuyPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
