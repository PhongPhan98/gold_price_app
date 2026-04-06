import 'package:flutter/material.dart';

import '../../../core/models/gold_price_entry.dart';
import '../../../core/widgets/provider_price_screen.dart';
import '../data/services/mihong_service.dart';

class MiHongGoldPriceHomePage extends StatefulWidget {
  const MiHongGoldPriceHomePage({super.key});

  @override
  State<MiHongGoldPriceHomePage> createState() => _MiHongGoldPriceHomePageState();
}

class _MiHongGoldPriceHomePageState extends State<MiHongGoldPriceHomePage> {
  final MiHongService _service = MiHongService();

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
      debugPrint('Error fetching Mi Hong gold price: $error');
      if (mounted) {
        setState(() {
          _goldPrices = [];
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
      title: 'Giá vàng Mi Hồng',
      entries: _goldPrices,
      isLoading: _isLoading,
      emptyMessage: 'Không có dữ liệu giá vàng Mi Hồng',
      onRefresh: _fetchPrices,
      nameFlex: 2,
      buyFlex: 3,
      sellFlex: 3,
      timeFlex: 3,
    );
  }
}
