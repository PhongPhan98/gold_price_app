import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/core/utils/date_time_formatter.dart';

void main() {
  group('DateTimeFormatter', () {
    test('formats dd/MM/yyyy HH:mm correctly', () {
      final date = DateTime(2026, 4, 7, 6, 5);

      final formatted = DateTimeFormatter.ddMMyyyyHHmm(date);

      expect(formatted, '07/04/2026 06:05');
    });
  });
}
