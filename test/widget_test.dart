import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/main.dart';

void main() {
  testWidgets('home screen shows app title and actions', (tester) async {
    await tester.pumpWidget(const GoldPriceApp());

    expect(find.text('Giá vàng Việt Nam'), findsOneWidget);
    expect(find.text('Theo dõi giá vàng nhanh gọn'), findsOneWidget);
    expect(find.text('Mở màn hình so sánh nhanh'), findsOneWidget);
    expect(find.text('Thiết lập cảnh báo'), findsOneWidget);
    expect(find.text('Mở màn hình so sánh nhanh'), findsOneWidget);
    expect(find.byIcon(Icons.compare_arrows), findsWidgets);
    expect(find.byIcon(Icons.workspace_premium_outlined), findsOneWidget);
    expect(find.text('Đã ghim'), findsOneWidget);
  });
}
