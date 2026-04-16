class PortfolioSnapshot {
  const PortfolioSnapshot({
    required this.dayKey,
    required this.totalCost,
    required this.totalCurrent,
  });

  final String dayKey; // yyyy-MM-dd
  final double totalCost;
  final double totalCurrent;

  double get pnl => totalCurrent - totalCost;

  PortfolioSnapshot copyWith({
    String? dayKey,
    double? totalCost,
    double? totalCurrent,
  }) {
    return PortfolioSnapshot(
      dayKey: dayKey ?? this.dayKey,
      totalCost: totalCost ?? this.totalCost,
      totalCurrent: totalCurrent ?? this.totalCurrent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayKey': dayKey,
      'totalCost': totalCost,
      'totalCurrent': totalCurrent,
    };
  }

  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) {
    return PortfolioSnapshot(
      dayKey: json['dayKey'] as String,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
      totalCurrent: (json['totalCurrent'] as num?)?.toDouble() ?? 0,
    );
  }
}
