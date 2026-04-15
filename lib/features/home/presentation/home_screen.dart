import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../alerts/presentation/alerts_screen.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../compare/presentation/compare_screen.dart';
import '../../gold_prices/presentation/baotinminhchau_gold_price_page.dart';
import '../../gold_prices/presentation/doji_gold_price_page.dart';
import '../../gold_prices/presentation/baotinmanhhai_gold_price_page.dart';
import '../../gold_prices/presentation/mihong_gold_price_page.dart';
import '../../history/presentation/history_screen.dart';
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
        subtitle: 'Giá SJC, nhẫn tròn trơn và nhiều loại khác',
        icon: Icons.workspace_premium,
        pageBuilder: () => const BaoTinMinhChauGoldPriceHomePage(),
      ),
      _ProviderMenuItem(
        title: 'Bảo Tín Mạnh Hải',
        subtitle: 'Cập nhật giá vàng trực tiếp từ BTMH',
        icon: Icons.diamond,
        pageBuilder: () => const BaoTinManhHaiGoldPriceHomePage(),
      ),
      _ProviderMenuItem(
        title: 'Mi Hồng',
        subtitle: 'Theo dõi giá mua bán và biến động trong ngày',
        icon: Icons.show_chart,
        pageBuilder: () => const MiHongGoldPriceHomePage(),
      ),
      _ProviderMenuItem(
        title: 'Doji',
        subtitle: 'Bảng giá vàng bạc đá quý Doji',
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
      appBar: AppBar(
        title: const Text(
          'Giá Vàng VN',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          Semantics(
            label: 'Làm mới dữ liệu trang chủ',
            button: true,
            child: IconButton(
              onPressed: _loadSummaries,
              icon: const Icon(Icons.refresh),
              tooltip: 'Làm mới dữ liệu',
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'alerts', child: Text('Cảnh báo giá')),
              PopupMenuItem(value: 'compare', child: Text('So sánh nhanh')),
              PopupMenuItem(value: 'history', child: Text('Lịch sử giá')),
              PopupMenuItem(value: 'premium', child: Text('Nâng cấp Premium')),
            ],
            onSelected: (value) {
              switch (value) {
                case 'alerts':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  );
                  break;
                case 'compare':
                  _openCompareScreen();
                  break;
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(summaries: _summaries),
                    ),
                  );
                  break;
                case 'premium':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PremiumPaywallScreen(),
                    ),
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummaries,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theo dõi giá vàng mỗi ngày',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chạm vào một nguồn để xem giá chi tiết và thời gian cập nhật mới nhất.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _TopMetricCard(
                          label: 'Nguồn',
                          value: '${orderedItems.length}',
                        ),
                        _TopMetricCard(
                          label: 'Đã ghim',
                          value: '${_favoriteTitles.length}',
                        ),
                        _TopMetricCard(
                          label: 'Trạng thái',
                          value: _isLoadingSummaries ? 'Đang tải' : 'Sẵn sàng',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      label: 'Mở màn hình so sánh nhanh',
                      button: true,
                      child: ElevatedButton.icon(
                        onPressed: _openCompareScreen,
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('So sánh nhanh'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingSummaries && _summaries.isEmpty)
              ...List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: _ProviderSkeletonCard(),
                ),
              )
            else
              ...orderedItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _ProviderMenuCard(
                    item: item,
                    summary: summariesByTitle[item.title],
                    isLoadingSummary: _isLoadingSummaries,
                    isFavorite: _favoriteTitles.contains(item.title),
                    onToggleFavorite: () => _toggleFavorite(item.title),
                  ),
                );
              }),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'v1.0.0',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
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
        color: context.appSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.pageBuilder()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: AppTheme.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
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
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Semantics(
                              label: isFavorite ? 'Bỏ ghim nguồn giá' : 'Ghim nguồn giá',
                              button: true,
                              child: IconButton(
                                onPressed: onToggleFavorite,
                                icon: Icon(
                                  isFavorite
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  color: isFavorite
                                      ? AppTheme.accent
                                      : Colors.white54,
                                ),
                                tooltip: isFavorite ? 'Bỏ ghim' : 'Ghim nguồn này',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
          'Đang tải dữ liệu...',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    if (summary == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
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
          ...summary!.previewLines.take(2).map(
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
              padding: const EdgeInsets.only(top: 4),
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


class _ProviderSkeletonCard extends StatelessWidget {
  const _ProviderSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
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
