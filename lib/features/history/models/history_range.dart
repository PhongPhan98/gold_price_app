enum HistoryRange {
  sevenDays,
  thirtyDays,
  ninetyDays,
}

extension HistoryRangeX on HistoryRange {
  int get pointCount {
    switch (this) {
      case HistoryRange.sevenDays:
        return 7;
      case HistoryRange.thirtyDays:
        return 30;
      case HistoryRange.ninetyDays:
        return 90;
    }
  }

  String get label {
    switch (this) {
      case HistoryRange.sevenDays:
        return '7 ngày';
      case HistoryRange.thirtyDays:
        return '30 ngày';
      case HistoryRange.ninetyDays:
        return '90 ngày';
    }
  }

  bool get premiumRequired {
    return this != HistoryRange.sevenDays;
  }
}
