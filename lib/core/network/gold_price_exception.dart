class GoldPriceException implements Exception {
  const GoldPriceException(this.message);

  final String message;

  @override
  String toString() => message;
}
