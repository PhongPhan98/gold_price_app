import 'package:flutter/material.dart';

import '../../alerts/presentation/alerts_screen.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../compare/presentation/compare_screen.dart';
import '../../gold_prices/presentation/baotinminhchau_gold_price_page.dart';
import '../../gold_prices/presentation/doji_gold_price_page.dart';
import '../../gold_prices/presentation/mihong_gold_price_page.dart';
import '../data/favorite_provider_storage.dart';
import '../data/home_summary_service.dart';
import '../models/provider_summary.dart';
import '../widgets/summary_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _backgroundColor = Color.fromARGB(255, 133, 30, 30);
  static const _accentColor = Color.fromARGB(255, 202, 182, 1);

  final HomeSummaryService _summaryService = HomeSummaryService();
  final FavoriteProviderStorage _favoriteProviderStorage =
      FavoriteProviderStorage();

  Set<String> _favoriteTitles = {'Mi Hồng'};
  late final List<_ProviderMenuItem> _items;
  List<ProviderSummary> _summaries = [];
  bool _isLoadingSummaries = true;

  @override
  void initState() {
    super.initState();
    _items = <_ProviderMenuItem>[
      _ProviderMenuItem(
        title: 'Bảo Tín Minh Châu',
        subtitle: 'Giá vàng SJC, nhẫn tròn trơn và nhiều loại khác',
        icon: Icons.workspace_premium,
        pageBuilder: () => const BaoTinMinhChauGoldPriceHomePage(),
      ),
      _ProviderMenuItem(
        title: 'Mi Hồng',
        subtitle: 'Theo dõi giá mua bán và mức biến động trong ngày',
        icon: Icons.show_chart,
        pageBuilder: () => const MiHongGoldPriceHomePage(),
      ),
      _ProviderMenuItem(
        title: 'Doji',
        subtitle: 'Cập nhật bảng giá từ hệ thống vàng bạc đá quý Doji',
        icon: Icons.account_balance,
        pageBuilder: () => const DojiGoldPriceHomePage(),
      ),
    ];
    _loadFavorites();
    _loadSummaries();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoriteProviderStorage.loadFavorites();
    if (!mounted) {
      return;
    }

    setState(() {
      _favoriteTitles = favorites.isEmpty ? {'Mi Hồng'} : favorites;
    });
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isLoadingSummaries = true;
    });

    final summaries = await _summaryService.fetchSummaries();
    if (!mounted) {
      return;
    }

    setState(() {
      _summaries = summaries;
      _isLoadingSummaries = false;
    });
  }

  Future<void> _toggleFavorite(String title) async {
    setState(() {
      if (_favoriteTitles.contains(title)) {
        _favoriteTitles.remove(title);
      } else {
        _favoriteTitles.add(title);
      }
    });

    await _favoriteProviderStorage.saveFavorites(_favoriteTitles);
  }

  void _openCompareScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompareScreen(summaries: _summaries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summariesByTitle = {
      for (final summary in _summaries) summary.title: summary,
    };

    final orderedItems = [..._items]
      ..sort((a, b) {
        final aFav = _favoriteTitles.contains(a.title);
        final bFav = _favoriteTitles.contains(b.title);
        if (aFav == bFav) {
          return a.title.compareTo(b.title);
        }
        return aFav ? -1 : 1;
      });

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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Cảnh báo giá',
          ),
          IconButton(
            onPressed: _openCompareScreen,
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'So sánh nhanh',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
              );
            },
            icon: const Icon(Icons.workspace_premium_outlined),
            tooltip: 'Nâng cấp Premium',
          ),
          IconButton(
            onPressed: _loadSummaries,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadSummaries,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theo dõi giá vàng nhanh gọn',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Chọn thương hiệu bên dưới để xem giá mua vào, bán ra và thời gian cập nhật mới nhất. Bạn có thể ghim nguồn ưu tiên và so sánh nhanh ngay từ trang chủ.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _TopMetricCard(
                              label: 'Nguồn theo dõi',
                              value: '${orderedItems.length}',
                            ),
                            _TopMetricCard(
                              label: 'Đã ghim',
                              value: '${_favoriteTitles.length}',
                            ),
                            _TopMetricCard(
                              label: 'Trạng thái',
                              value: _isLoadingSummaries
                                  ? 'Đang tải'
                                  : 'Sẵn sàng',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _openCompareScreen,
                              icon: const Icon(Icons.compare_arrows),
                              label: const Text('Mở màn hình so sánh nhanh'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_alert),
                              label: const Text('Thiết lập cảnh báo'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...orderedItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: _ProviderMenuCard(
                        item: item,
                        summary: summariesByTitle[item.title],
                        isLoadingSummary: _isLoadingSummaries,
                        isFavorite: _favoriteTitles.contains(item.title),
                        onToggleFavorite: () => _toggleFavorite(item.title),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
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

class _TopMetricCard extends StatelessWidget {
  const _TopMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderMenuCard extends StatelessWidget {
  const _ProviderMenuCard({
    required this.item,
    required this.summary,
    required this.isLoadingSummary,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final _ProviderMenuItem item;
  final ProviderSummary? summary;
  final bool isLoadingSummary;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color.fromARGB(255, 202, 182, 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 202, 182, 1)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      color: const Color.fromARGB(255, 202, 182, 1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Color.fromARGB(255, 202, 182, 1),
                                  fontFamily: 'Source Sans Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onToggleFavorite,
                              icon: Icon(
                                isFavorite
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                color: isFavorite
                                    ? const Color.fromARGB(255, 202, 182, 1)
                                    : Colors.white54,
                              ),
                              tooltip: isFavorite ? 'Bỏ ghim' : 'Ghim nguồn này',
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.chevron_right,
                    color: Color.fromARGB(255, 202, 182, 1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryPreview(
                summary: summary,
                isLoadingSummary: isLoadingSummary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryPreview extends StatelessWidget {
  const _SummaryPreview({
    required this.summary,
    required this.isLoadingSummary,
  });

  final ProviderSummary? summary;
  final bool isLoadingSummary;

  @override
  Widget build(BuildContext context) {
    if (isLoadingSummary && summary == null) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Đang tải dữ liệu xem nhanh...',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    if (summary == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: summary!.hasError
              ? Colors.orangeAccent.withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary!.topBuyPrice != null || summary!.topSellPrice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (summary!.topBuyPrice != null)
                    SummaryBadge(
                      label: 'Mua vào',
                      value: summary!.topBuyPrice!,
                    ),
                  if (summary!.topSellPrice != null)
                    SummaryBadge(
                      label: 'Bán ra',
                      value: summary!.topSellPrice!,
                    ),
                ],
              ),
            ),
          ...summary!.previewLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $line',
                style: TextStyle(
                  color: summary!.hasError ? Colors.orangeAccent : Colors.white,
                  height: 1.35,
                ),
              ),
            ),
          ),
          if (summary!.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Cập nhật: ${summary!.lastUpdated}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProviderMenuItem {
  const _ProviderMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.pageBuilder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() pageBuilder;
}
