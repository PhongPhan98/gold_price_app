import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/main.dart';

void main() {
  testWidgets('home screen shows app title and provider cards', (tester) async {
    await tester.pumpWidget(const GoldPriceApp());

    expect(find.text('Giá vàng Việt Nam'), findsOneWidget);
    expect(find.text('Theo dõi giá vàng nhanh gọn'), findsOneWidget);
    expect(find.text('Bảo Tín Minh Châu'), findsOneWidget);
    expect(find.text('Mi Hồng'), findsOneWidget);
    expect(find.text('Đã ghim'), findsOneWidget);
    expect(find.text('Đang tải'), findsOneWidget);
  });
}
