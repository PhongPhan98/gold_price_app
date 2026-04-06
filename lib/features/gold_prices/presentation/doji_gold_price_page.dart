import 'package:flutter/material.dart';

import '../../../core/models/gold_price_entry.dart';
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
      debugPrint('Error fetching Doji gold price: $error');
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
      title: 'Giá vàng Doji',
      entries: _goldPrices,
      isLoading: _isLoading,
      emptyMessage: 'Không có dữ liệu giá vàng Doji',
      onRefresh: _fetchPrices,
    );
  }
}
