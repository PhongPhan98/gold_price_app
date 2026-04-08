import '../models/price_history_point.dart';

class HistoryTrendUtils {
  static String buildTrendInsight(List<PriceHistoryPoint> points) {
    if (points.length < 2) {
      return 'Chưa đủ dữ liệu để phân tích xu hướng.';
    }

    final first = points.first.value;
    final last = points.last.value;
    final delta = last - first;

    if (delta > 0) {
      return 'Xu hướng đang tăng nhẹ, phù hợp để theo dõi cơ hội chốt lời hoặc cảnh báo giá cao hơn.';
    }
    if (delta < 0) {
      return 'Xu hướng đang giảm, phù hợp để theo dõi cơ hội mua vào tốt hơn.';
    }
    return 'Xu hướng đang đi ngang, cần thêm dữ liệu để kết luận rõ hơn.';
  }
}
