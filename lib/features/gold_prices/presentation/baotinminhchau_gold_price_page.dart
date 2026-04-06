import 'package:flutter/material.dart';

import '../../../core/models/gold_price_entry.dart';
import '../../../core/widgets/provider_price_screen.dart';
import '../data/services/baotinminhchau_service.dart';

class BaoTinMinhChauGoldPriceHomePage extends StatefulWidget {
  const BaoTinMinhChauGoldPriceHomePage({super.key});

  @override
  State<BaoTinMinhChauGoldPriceHomePage> createState() =>
      _BaoTinMinhChauGoldPriceHomePageState();
}

class _BaoTinMinhChauGoldPriceHomePageState
    extends State<BaoTinMinhChauGoldPriceHomePage> {
  final BaoTinMinhChauService _service = BaoTinMinhChauService();

  List<GoldPriceEntry> _goldPrices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prices = await _service.fetchPrices();
      if (mounted) {
        setState(() {
          _goldPrices = prices;
        });
      }
    } catch (error) {
      debugPrint('Error fetching BTMC gold price: $error');
      if (mounted) {
        setState(() {
          _goldPrices = [];
        });
      }
    } finally {
      await Future<void>.delayed(const Duration(seconds: 1));
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
      title: 'Giá vàng BTMC',
      entries: _goldPrices,
      isLoading: _isLoading,
      emptyMessage: 'Không có dữ liệu giá vàng BTMC',
      onRefresh: _fetchPrices,
    );
  }
}
