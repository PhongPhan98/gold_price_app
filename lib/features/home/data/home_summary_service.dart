import '../../gold_prices/data/services/baotinminhchau_service.dart';
import '../../gold_prices/data/services/doji_service.dart';
import '../../gold_prices/data/services/baotinmanhhai_service.dart';
import '../../gold_prices/data/services/mihong_service.dart';
import '../models/provider_summary.dart';

class HomeSummaryService {
  HomeSummaryService({
    BaoTinMinhChauService? baotinMinhChauService,
    BaoTinManhHaiService? baotinManhHaiService,
    MiHongService? miHongService,
    DojiService? dojiService,
  })  : _baotinMinhChauService = baotinMinhChauService ?? BaoTinMinhChauService(),
        _baotinManhHaiService = baotinManhHaiService ?? BaoTinManhHaiService(),
        _miHongService = miHongService ?? MiHongService(),
        _dojiService = dojiService ?? DojiService();

  final BaoTinMinhChauService _baotinMinhChauService;
  final BaoTinManhHaiService _baotinManhHaiService;
  final MiHongService _miHongService;
  final DojiService _dojiService;

  Future<List<ProviderSummary>> fetchSummaries() async {
    final results = await Future.wait([
      _buildBaoTinMinhChauSummary(),
      _buildBaoTinManhHaiSummary(),
      _buildMiHongSummary(),
      _buildDojiSummary(),
    ]);

    return results;
  }

  Future<ProviderSummary> _buildBaoTinMinhChauSummary() async {
    try {
      final prices = await _baotinMinhChauService.fetchPrices();
      final preview = prices.take(2).map((item) {
        return '${item.name}: ${_displayPrice(item.buyPrice)} / ${_displayPrice(item.sellPrice)}';
      }).toList();
      final first = prices.isNotEmpty ? prices.first : null;

      return ProviderSummary(
        title: 'Bảo Tín Minh Châu',
        subtitle: 'Giá vàng SJC, nhẫn tròn trơn và nhiều loại khác',
        previewLines: preview.isEmpty ? ['Chưa có dữ liệu hiển thị'] : preview,
        lastUpdated: first?.updatedAt,
        topBuyPrice: _displayPrice(first?.buyPrice),
        topSellPrice: _displayPrice(first?.sellPrice),
      );
    } catch (_) {
      return const ProviderSummary(
        title: 'Bảo Tín Minh Châu',
        subtitle: 'Giá vàng SJC, nhẫn tròn trơn và nhiều loại khác',
        previewLines: ['Không tải được dữ liệu xem nhanh'],
        lastUpdated: null,
        topBuyPrice: null,
        topSellPrice: null,
        hasError: true,
      );
    }
  }

  Future<ProviderSummary> _buildBaoTinManhHaiSummary() async {
    try {
      final prices = await _baotinManhHaiService.fetchPrices();
      final preview = prices.take(2).map((item) {
        return '${item.name}: ${_displayPrice(item.buyPrice)} / ${_displayPrice(item.sellPrice)}';
      }).toList();
      final first = prices.isNotEmpty ? prices.first : null;

      return ProviderSummary(
        title: 'Bảo Tín Mạnh Hải',
        subtitle: 'Cập nhật bảng giá vàng trực tiếp từ BTMH',
        previewLines: preview.isEmpty ? ['Chưa có dữ liệu hiển thị'] : preview,
        lastUpdated: first?.updatedAt,
        topBuyPrice: _displayPrice(first?.buyPrice),
        topSellPrice: _displayPrice(first?.sellPrice),
      );
    } catch (_) {
      return const ProviderSummary(
        title: 'Bảo Tín Mạnh Hải',
        subtitle: 'Cập nhật bảng giá vàng trực tiếp từ BTMH',
        previewLines: ['Không tải được dữ liệu xem nhanh'],
        lastUpdated: null,
        topBuyPrice: null,
        topSellPrice: null,
        hasError: true,
      );
    }
  }


  Future<ProviderSummary> _buildMiHongSummary() async {
    try {
      final prices = await _miHongService.fetchPrices();
      final preview = prices.take(2).map((item) {
        return '${item.name}: ${_displayPrice(item.buyPrice)} / ${_displayPrice(item.sellPrice)}';
      }).toList();
      final first = prices.isNotEmpty ? prices.first : null;

      return ProviderSummary(
        title: 'Mi Hồng',
        subtitle: 'Theo dõi giá mua bán và mức biến động trong ngày',
        previewLines: preview.isEmpty ? ['Chưa có dữ liệu hiển thị'] : preview,
        lastUpdated: first?.updatedAt,
        topBuyPrice: _displayPrice(first?.buyPrice),
        topSellPrice: _displayPrice(first?.sellPrice),
      );
    } catch (_) {
      return const ProviderSummary(
        title: 'Mi Hồng',
        subtitle: 'Theo dõi giá mua bán và mức biến động trong ngày',
        previewLines: ['Không tải được dữ liệu xem nhanh'],
        lastUpdated: null,
        topBuyPrice: null,
        topSellPrice: null,
        hasError: true,
      );
    }
  }

  Future<ProviderSummary> _buildDojiSummary() async {
    try {
      final prices = await _dojiService.fetchPrices();
      final preview = prices.take(2).map((item) {
        return '${item.name}: ${_displayPrice(item.buyPrice)} / ${_displayPrice(item.sellPrice)}';
      }).toList();
      final first = prices.isNotEmpty ? prices.first : null;

      return ProviderSummary(
        title: 'Doji',
        subtitle: 'Cập nhật bảng giá từ hệ thống vàng bạc đá quý Doji',
        previewLines: preview.isEmpty ? ['Chưa có dữ liệu hiển thị'] : preview,
        lastUpdated: first?.updatedAt,
        topBuyPrice: _displayPrice(first?.buyPrice),
        topSellPrice: _displayPrice(first?.sellPrice),
      );
    } catch (_) {
      return const ProviderSummary(
        title: 'Doji',
        subtitle: 'Cập nhật bảng giá từ hệ thống vàng bạc đá quý Doji',
        previewLines: ['Không tải được dữ liệu xem nhanh'],
        lastUpdated: null,
        topBuyPrice: null,
        topSellPrice: null,
        hasError: true,
      );
    }
  }

  String? _displayPrice(String? raw) {
    if (raw == null) {
      return null;
    }

    final normalized = raw.trim();
    if (normalized.isEmpty || normalized == '-' || normalized == '0' || normalized == '0.0' || normalized == '0.00') {
      return 'Liên hệ';
    }

    return normalized;
  }
}
