import 'package:flutter/material.dart';

import '../../../core/models/gold_price_entry.dart';
import '../../../core/network/gold_price_exception.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/provider_price_screen.dart';
import '../data/services/doji_service.dart';

class DojiGoldPriceHomePage extends StatefulWidget {
  const DojiGoldPriceHomePage({super.key});

  @override
  State<DojiGoldPriceHomePage> createState() => _DojiGoldPriceHomePageState();
}

class _DojiGoldPriceHomePageState extends State<DojiGoldPriceHomePage> {
  final DojiService _service = DojiService();

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
      debugPrint('Error fetching Doji gold price: $error');
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
      title: 'Giá vàng Doji',
      entries: _goldPrices,
      isLoading: _isLoading,
      emptyMessage: 'Không có dữ liệu giá vàng Doji',
      errorMessage: _errorMessage,
      lastUpdatedLabel: _lastUpdatedLabel,
      onRefresh: _fetchPrices,
    );
  }
}
