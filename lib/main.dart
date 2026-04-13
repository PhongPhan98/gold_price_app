import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const GoldPriceApp());
}

class GoldPriceApp extends StatelessWidget {
  const GoldPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giá vàng Việt Nam',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
