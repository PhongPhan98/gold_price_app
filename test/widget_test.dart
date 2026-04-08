import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gia_vang_hom_nay/main.dart';

void main() {
  testWidgets('home screen shows main product actions', (tester) async {
    await tester.pumpWidget(const GoldPriceApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.compare_arrows), findsWidgets);
    expect(find.byIcon(Icons.workspace_premium_outlined), findsOneWidget);
    expect(find.text('Mở màn hình so sánh nhanh'), findsOneWidget);
    expect(find.text('Thiết lập cảnh báo'), findsOneWidget);
    expect(find.text('Xem lịch sử giá'), findsOneWidget);
  });
}
