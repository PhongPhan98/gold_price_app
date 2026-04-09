import '../models/price_history_point.dart';

class HistoryTrendUtils {
  static String buildTrendInsight(
    List<PriceHistoryPoint> points, {
    required bool isPremium,
  }) {
    if (points.length < 2) {
      return 'Chưa đủ dữ liệu để phân tích xu hướng.';
    }

    final first = points.first.value;
    final last = points.last.value;
    final delta = last - first;
    final deltaPercent = first == 0 ? 0 : (delta / first) * 100;

    if (!isPremium) {
      if (delta > 0) {
        return 'Xu hướng đang tăng nhẹ trong bản xem trước 7 ngày. Nâng cấp Premium để mở khóa insight dài hạn 30/90 ngày.';
      }
      if (delta < 0) {
        return 'Xu hướng đang giảm trong bản xem trước 7 ngày. Nâng cấp Premium để theo dõi thêm xu hướng dài hạn.';
      }
      return 'Xu hướng đang đi ngang trong bản xem trước. Premium sẽ mở khóa phân tích sâu hơn.';
    }

    final movement = delta > 0
        ? 'tăng'
        : delta < 0
            ? 'giảm'
            : 'đi ngang';

    return 'Phân tích Premium: xu hướng đang $movement ${delta.abs().toStringAsFixed(1)} (${deltaPercent.abs().toStringAsFixed(2)}%) so với đầu kỳ. Có thể dùng tín hiệu này để tối ưu điểm vào/ra.';
  }
}
