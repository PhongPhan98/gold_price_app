import '../models/history_range.dart';

class HistoryPremiumCopy {
  static String buildRangeValueMessage({
    required HistoryRange range,
    required bool isPremium,
  }) {
    if (isPremium) {
      switch (range) {
        case HistoryRange.sevenDays:
          return '7 ngày: theo dõi biến động ngắn hạn để canh điểm vào/ra nhanh.';
        case HistoryRange.thirtyDays:
          return '30 ngày: thấy rõ nhịp trung hạn và vùng giá quan trọng để tối ưu quyết định.';
        case HistoryRange.ninetyDays:
          return '90 ngày: góc nhìn dài hơn giúp quản trị vị thế và tâm lý tốt hơn.';
      }
    }

    switch (range) {
      case HistoryRange.sevenDays:
        return 'Free đang mở 7 ngày để bạn trải nghiệm nhanh tín hiệu xu hướng.';
      case HistoryRange.thirtyDays:
        return '30 ngày là bản Premium: mở khóa để xem xu hướng trung hạn rõ hơn.';
      case HistoryRange.ninetyDays:
        return '90 ngày là bản Premium: mở khóa để tránh quyết định theo nhiễu ngắn hạn.';
    }
  }

  static List<String> buildValueBullets({required bool isPremium}) {
    if (isPremium) {
      return const [
        'So sánh nhịp biến động theo từng nguồn giá',
        'Theo dõi xu hướng 7/30/90 ngày trong cùng một luồng',
        'Kết hợp insight + cảnh báo để hành động có kỷ luật',
      ];
    }

    return const [
      'Mở 30/90 ngày để thấy bức tranh xu hướng đầy đủ',
      'Nhận insight sâu hơn thay vì chỉ xem số liệu thô',
      'Ghép lịch sử + cảnh báo để không bỏ lỡ vùng giá quan trọng',
    ];
  }

  static String buildRetentionPrompt({required bool isPremium}) {
    if (isPremium) {
      return 'Gợi ý hôm nay: kiểm tra nhanh 30 ngày rồi đối chiếu 90 ngày trước khi ra quyết định lớn.';
    }
    return 'Gợi ý: mở 30 ngày trước, sau đó 90 ngày để thấy khác biệt rõ nhất về chất lượng quyết định.';
  }
}
