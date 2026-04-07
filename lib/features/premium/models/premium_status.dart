enum PremiumPlan {
  free,
  proMonthly,
  proYearly,
}

class PremiumStatus {
  const PremiumStatus({
    required this.plan,
    required this.isActive,
  });

  final PremiumPlan plan;
  final bool isActive;

  bool get isPremium => isActive && plan != PremiumPlan.free;

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.name,
      'isActive': isActive,
    };
  }

  factory PremiumStatus.fromJson(Map<String, dynamic> json) {
    return PremiumStatus(
      plan: PremiumPlan.values.firstWhere(
        (item) => item.name == json['plan'],
        orElse: () => PremiumPlan.free,
      ),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
