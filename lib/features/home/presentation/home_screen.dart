import 'package:flutter/material.dart';

import '../../gold_prices/presentation/baotinminhchau_gold_price_page.dart';
import '../../gold_prices/presentation/doji_gold_price_page.dart';
import '../../gold_prices/presentation/mihong_gold_price_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _backgroundColor = Color.fromARGB(255, 133, 30, 30);
  static const _accentColor = Color.fromARGB(255, 202, 182, 1);

  @override
  Widget build(BuildContext context) {
    final items = <_ProviderMenuItem>[
      _ProviderMenuItem(
        title: 'Bảo Tín Minh Châu',
        pageBuilder: () => const BaoTinMinhChauGoldPriceHomePage(),
      ),
      _ProviderMenuItem(
        title: 'Mi Hồng',
        pageBuilder: () => const MiHongGoldPriceHomePage(),
      ),
      _ProviderMenuItem(
        title: 'Doji',
        pageBuilder: () => const DojiGoldPriceHomePage(),
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Giá vàng Việt Nam',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: _backgroundColor,
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Chọn thương hiệu để xem giá vàng mới nhất',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: _ProviderMenuCard(item: item),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: _accentColor, width: 1.0),
                ),
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: _accentColor,
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: _backgroundColor,
    );
  }
}

class _ProviderMenuCard extends StatelessWidget {
  const _ProviderMenuCard({required this.item});

  final _ProviderMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.pageBuilder()),
          );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 202, 182, 1)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color.fromARGB(255, 202, 182, 1),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 202, 182, 1),
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color.fromARGB(255, 202, 182, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderMenuItem {
  const _ProviderMenuItem({required this.title, required this.pageBuilder});

  final String title;
  final Widget Function() pageBuilder;
}
