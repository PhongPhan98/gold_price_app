import 'package:flutter/material.dart';

import '../models/premium_status.dart';
import '../models/purchase_result.dart';
import '../services/premium_state_controller.dart';
import '../services/purchase_service_factory.dart';
import '../services/purchase_service.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  final PurchaseService _purchaseService = PurchaseServiceFactory.create(useMock: false);
  final PremiumStateController _premiumStateController = PremiumStateController();

  PremiumStatus _currentStatus = const PremiumStatus(
    plan: PremiumPlan.free,
    isActive: false,
  );
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _refreshEntitlementStatus();
  }

  Future<void> _refreshEntitlementStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang kiểm tra entitlement premium...';
    });

    await _premiumStateController.refresh();
    final status = _premiumStateController.status;
    if (!mounted) {
      return;
    }

    setState(() {
      _currentStatus = status;
      _isLoading = false;
      _statusMessage = status.isPremium
          ? 'Entitlement premium đang hoạt động.'
          : 'Entitlement premium hiện chưa được kích hoạt.';
    });
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang kiểm tra trạng thái mua hàng...';
    });

    await _purchaseService.restorePurchases();
    await _refreshEntitlementStatus();
  }

  Future<void> _activatePlan(PremiumPlan plan) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang xử lý gói ${plan.name}...';
    });

    final result = await _purchaseService.purchase(plan);
    if (!mounted) {
      return;
    }

    await _premiumStateController.refresh();
    final refreshedStatus = _premiumStateController.status;
    if (!mounted) {
      return;
    }

    setState(() {
      _currentStatus = refreshedStatus;
      _isLoading = false;
      _statusMessage = result.message ?? _messageForResult(result.status);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_statusMessage!)),
    );
  }

  String _messageForResult(PurchaseResultStatus status) {
    switch (status) {
      case PurchaseResultStatus.success:
        return 'Mua gói thành công.';
      case PurchaseResultStatus.cancelled:
        return 'Người dùng đã hủy giao dịch.';
      case PurchaseResultStatus.pending:
        return 'Giao dịch đang chờ xử lý.';
      case PurchaseResultStatus.error:
        return 'Có lỗi xảy ra khi xử lý thanh toán.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nâng cấp Premium'),
        backgroundColor: Colors.yellow[800],
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _restorePurchases,
            icon: const Icon(Icons.restore),
            tooltip: 'Khôi phục mua hàng',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_statusMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _currentStatus.isPremium
                        ? Colors.greenAccent.withValues(alpha: 0.4)
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _currentStatus.isPremium
                        ? Colors.greenAccent
                        : Colors.white70,
                  ),
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color.fromARGB(255, 202, 182, 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mở khóa công cụ kiếm tiền từ dữ liệu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Premium sẽ là nơi mở khóa nhiều cảnh báo hơn, so sánh nâng cao, lịch sử giá, insight tốt hơn và trải nghiệm không quảng cáo.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _currentStatus.isPremium
                        ? 'Trạng thái hiện tại: ${_currentStatus.plan.name}'
                        : 'Trạng thái hiện tại: free',
                    style: TextStyle(
                      color: _currentStatus.isPremium
                          ? Colors.greenAccent
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: 'Pro Monthly',
              subtitle: 'Phù hợp để test conversion và thói quen trả phí hàng tháng',
              price: '49.000đ / tháng',
              productId: _purchaseService.productIdForPlan(PremiumPlan.proMonthly),
              isLoading: _isLoading,
              isActive: _currentStatus.plan == PremiumPlan.proMonthly &&
                  _currentStatus.isPremium,
              onTap: () => _activatePlan(PremiumPlan.proMonthly),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Pro Yearly',
              subtitle: 'Tỷ lệ giữ chân và doanh thu dài hạn tốt hơn',
              price: '399.000đ / năm',
              productId: _purchaseService.productIdForPlan(PremiumPlan.proYearly),
              isLoading: _isLoading,
              isActive: _currentStatus.plan == PremiumPlan.proYearly &&
                  _currentStatus.isPremium,
              onTap: () => _activatePlan(PremiumPlan.proYearly),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment integration preparation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('• Đã tách abstraction cho purchase flow', style: TextStyle(color: Colors.white70)),
                  Text('• Có thể thay MockPurchaseService bằng billing thật sau này', style: TextStyle(color: Colors.white70)),
                  Text('• Restore purchase path đã có skeleton', style: TextStyle(color: Colors.white70)),
                  Text('• Có loading/state message để chuẩn bị cho flow billing thật', style: TextStyle(color: Colors.white70)),
                  Text('• Product ids đã được cấu hình để chuẩn bị nối billing thật', style: TextStyle(color: Colors.white70)),
                  Text('• Purchase result states đã sẵn sàng cho success/cancel/pending/error', style: TextStyle(color: Colors.white70)),
                  Text('• Entitlement service đã có để làm nguồn sự thật tập trung', style: TextStyle(color: Colors.white70)),
                  Text('• PurchaseServiceFactory đã sẵn sàng để chuyển mock → store billing', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.productId,
    required this.onTap,
    required this.isLoading,
    required this.isActive,
  });

  final String title;
  final String subtitle;
  final String price;
  final String productId;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.greenAccent.withValues(alpha: 0.4)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isActive)
                const Text(
                  'Đang hoạt động',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Product id: $productId',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            price,
            style: const TextStyle(
              color: Color.fromARGB(255, 202, 182, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : onTap,
            child: Text(isLoading ? 'Đang xử lý...' : 'Chọn gói này'),
          ),
        ],
      ),
    );
  }
}
