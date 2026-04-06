import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/main.dart';

void main() {
  testWidgets('home screen shows app title and providers', (tester) async {
    await tester.pumpWidget(const GoldPriceApp());

    expect(find.text('Giá vàng Việt Nam'), findsOneWidget);
    expect(find.text('Bảo Tín Minh Châu'), findsOneWidget);
    expect(find.text('Mi Hồng'), findsOneWidget);
    expect(find.text('Doji'), findsOneWidget);
  });
}
