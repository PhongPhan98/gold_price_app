class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.provider,
    required this.targetPrice,
    required this.direction,
    required this.isPremium,
    this.isEnabled = true,
  });

  final String id;
  final String provider;
  final String targetPrice;
  final PriceAlertDirection direction;
  final bool isPremium;
  final bool isEnabled;

  PriceAlert copyWith({
    String? id,
    String? provider,
    String? targetPrice,
    PriceAlertDirection? direction,
    bool? isPremium,
    bool? isEnabled,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      targetPrice: targetPrice ?? this.targetPrice,
      direction: direction ?? this.direction,
      isPremium: isPremium ?? this.isPremium,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'targetPrice': targetPrice,
      'direction': direction.name,
      'isPremium': isPremium,
      'isEnabled': isEnabled,
    };
  }

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'] as String,
      provider: json['provider'] as String,
      targetPrice: json['targetPrice'] as String,
      direction: PriceAlertDirection.values.firstWhere(
        (item) => item.name == json['direction'],
        orElse: () => PriceAlertDirection.above,
      ),
      isPremium: json['isPremium'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}

enum PriceAlertDirection {
  above,
  below,
}
