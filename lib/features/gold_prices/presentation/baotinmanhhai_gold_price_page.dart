import 'package:flutter/material.dart';

import '../../../core/models/gold_price_entry.dart';
import '../../../core/network/gold_price_exception.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/provider_price_screen.dart';
import '../data/services/baotinmanhhai_service.dart';

class BaoTinManhHaiGoldPriceHomePage extends StatefulWidget {
  const BaoTinManhHaiGoldPriceHomePage({super.key});

  @override
  State<BaoTinManhHaiGoldPriceHomePage> createState() =>
      _BaoTinManhHaiGoldPriceHomePageState();
}

class _BaoTinManhHaiGoldPriceHomePageState
    extends State<BaoTinManhHaiGoldPriceHomePage> {
  final BaoTinManhHaiService _service = BaoTinManhHaiService();

  List<GoldPriceEntry> _goldPrices = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastUpdatedLabel;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prices = await _service.fetchPrices();
      if (mounted) {
        setState(() {
          _goldPrices = prices;
          _lastUpdatedLabel =
              'Cập nhật lúc ${DateTimeFormatter.ddMMyyyyHHmm(DateTime.now())}';
        });
      }
    } on GoldPriceException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
          _goldPrices = [];
        });
      }
    } catch (error) {
      debugPrint('Error fetching Bao Tin Manh Hai gold price: $error');
      if (mounted) {
        setState(() {
          _goldPrices = [];
          _errorMessage = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderPriceScreen(
      title: 'Giá vàng Bảo Tín Mạnh Hải',
      entries: _goldPrices,
      isLoading: _isLoading,
      emptyMessage: 'Không có dữ liệu giá vàng Bảo Tín Mạnh Hải',
      errorMessage: _errorMessage,
      lastUpdatedLabel: _lastUpdatedLabel,
      onRefresh: _fetchPrices,
      nameFlex: 4,
      buyFlex: 2,
      sellFlex: 2,
      timeFlex: 3,
    );
  }
}
