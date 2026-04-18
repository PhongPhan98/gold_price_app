import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../alerts/presentation/alerts_screen.dart';
import '../../premium/presentation/premium_paywall_screen.dart';
import '../../compare/presentation/compare_screen.dart';
import '../../gold_prices/presentation/baotinminhchau_gold_price_page.dart';
import '../../gold_prices/presentation/doji_gold_price_page.dart';
import '../../gold_prices/presentation/baotinmanhhai_gold_price_page.dart';
import '../../gold_prices/presentation/mihong_gold_price_page.dart';
import '../../history/presentation/history_screen.dart';
import '../../portfolio/presentation/portfolio_screen.dart';
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
  final GlobalKey _insightCardBoundaryKey = GlobalKey();

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

  double? _parsePrice(String? raw) {
    if (raw == null) {
      return null;
    }

    final normalized = raw.trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'liên hệ') {
      return null;
    }

    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }

    final value = double.tryParse(digits);
    if (value == null || value <= 0) {
      return null;
    }

    return value;
  }

  String _formatCompactVnd(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      final reverseIndex = rounded.length - i;
      buffer.write(rounded[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  String _timeLabelNow() {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$dd/$mm $hh:$min';
  }

  _DailyInsightData _buildDailyInsight(List<ProviderSummary> summaries) {
    if (summaries.isEmpty) {
      return _DailyInsightData(
        title: 'Insight hôm nay',
        buyHint: 'Chưa có dữ liệu để phân tích.',
        sellHint: 'Hãy kéo để làm mới dữ liệu.',
        meta: 'Đợi dữ liệu mới...',
        generatedAt: _timeLabelNow(),
      );
    }

    ProviderSummary? bestBuyForUser; // lowest sell price
    double? lowestSell;

    ProviderSummary? bestSellForUser; // highest buy price
    double? highestBuy;

    for (final item in summaries) {
      if (item.hasError) {
        continue;
      }

      final sell = _parsePrice(item.topSellPrice);
      if (sell != null && (lowestSell == null || sell < lowestSell)) {
        lowestSell = sell;
        bestBuyForUser = item;
      }

      final buy = _parsePrice(item.topBuyPrice);
      if (buy != null && (highestBuy == null || buy > highestBuy)) {
        highestBuy = buy;
        bestSellForUser = item;
      }
    }

    final buyHint = bestBuyForUser == null || lowestSell == null
        ? 'Mua vào: chưa đủ dữ liệu so sánh.'
        : 'Mua vào tốt: ${bestBuyForUser.title} (${_formatCompactVnd(lowestSell)}đ/chỉ)';

    final sellHint = bestSellForUser == null || highestBuy == null
        ? 'Bán ra: chưa đủ dữ liệu so sánh.'
        : 'Bán ra tốt: ${bestSellForUser.title} (${_formatCompactVnd(highestBuy)}đ/chỉ)';

    final activeCount = summaries.where((s) => !s.hasError).length;
    final meta = 'So sánh $activeCount/${summaries.length} nguồn khả dụng';

    return _DailyInsightData(
      title: 'Insight hôm nay',
      buyHint: buyHint,
      sellHint: sellHint,
      meta: meta,
      generatedAt: _timeLabelNow(),
    );
  }

  String _buildShareText(_DailyInsightData insight) {
    final lines = [
      '✨ Cập nhật giá vàng hôm nay',
      '🟢 ${insight.buyHint}',
      '🔵 ${insight.sellHint}',
      '📊 ${insight.meta}',
      '🕒 Cập nhật: ${insight.generatedAt}',
      '📍 Nguồn: Giá Vàng VN',
    ];

    return lines.join('\n');
  }

  String _buildShareTextShort(_DailyInsightData insight) {
    return '✨ Giá vàng hôm nay\n🟢 ${insight.buyHint}\n🔵 ${insight.sellHint}\n🕒 ${insight.generatedAt}\n#GiaVang #GiaVangVN';
  }

  Future<void> _copyInsightShareText(_DailyInsightData insight) async {
    final text = _buildShareText(insight);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã copy nội dung chia sẻ (đầy đủ)')),
    );
  }

  Future<void> _copyInsightShareTextShort(_DailyInsightData insight) async {
    final text = _buildShareTextShort(insight);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã copy nội dung chia sẻ (ngắn)')),
    );
  }

  Future<void> _shareInsightAsImage(_DailyInsightData insight) async {
    try {
      final boundary =
          _insightCardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa thể tạo ảnh, vui lòng thử lại.')),
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tạo được ảnh chia sẻ.')),
        );
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/insight_gold_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: _buildShareTextShort(insight),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chia sẻ ảnh thất bại.')),
      );
    }
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

    final insight = _buildDailyInsight(_summaries);

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
              PopupMenuItem(value: 'portfolio', child: Text('Portfolio vàng')),
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
                case 'portfolio':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PortfolioScreen(summaries: _summaries),
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
            RepaintBoundary(
              key: _insightCardBoundaryKey,
              child: _DailyInsightCard(
                insight: insight,
                onCopyShare: () => _copyInsightShareText(insight),
                onCopyShareShort: () => _copyInsightShareTextShort(insight),
                onShareImage: () => _shareInsightAsImage(insight),
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


class _DailyInsightData {
  const _DailyInsightData({
    required this.title,
    required this.buyHint,
    required this.sellHint,
    required this.meta,
    required this.generatedAt,
  });

  final String title;
  final String buyHint;
  final String sellHint;
  final String meta;
  final String generatedAt;
}

class _DailyInsightCard extends StatelessWidget {
  const _DailyInsightCard({
    required this.insight,
    required this.onCopyShare,
    required this.onCopyShareShort,
    required this.onShareImage,
  });

  final _DailyInsightData insight;
  final VoidCallback onCopyShare;
  final VoidCallback onCopyShareShort;
  final VoidCallback onShareImage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3A2921),
              const Color(0xFF231717),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Text(
                    insight.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    insight.generatedAt,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '• ${insight.buyHint}',
                style: const TextStyle(color: Colors.white, height: 1.35),
              ),
              const SizedBox(height: 6),
              Text(
                '• ${insight.sellHint}',
                style: const TextStyle(color: Colors.white, height: 1.35),
              ),
              const SizedBox(height: 10),
              Text(
                insight.meta,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onCopyShare,
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Copy bản đầy đủ'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onCopyShareShort,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Copy bản ngắn'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onShareImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Chia sẻ ảnh'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Giá Vàng VN • Daily Insight',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
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
