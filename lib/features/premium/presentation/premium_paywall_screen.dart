import 'package:flutter/material.dart';

import '../data/premium_status_storage.dart';
import '../models/premium_status.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  final PremiumStatusStorage _storage = PremiumStatusStorage();

  Future<void> _activatePlan(PremiumPlan plan) async {
    await _storage.saveStatus(PremiumStatus(plan: plan, isActive: true));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã kích hoạt premium mẫu cho bước phát triển tiếp theo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nâng cấp Premium'),
        backgroundColor: Colors.yellow[800],
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
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color.fromARGB(255, 202, 182, 1)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mở khóa công cụ kiếm tiền từ dữ liệu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Premium sẽ là nơi mở khóa nhiều cảnh báo hơn, so sánh nâng cao, lịch sử giá, insight tốt hơn và trải nghiệm không quảng cáo.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: 'Pro Monthly',
              subtitle: 'Phù hợp để test conversion và thói quen trả phí hàng tháng',
              price: '49.000đ / tháng',
              onTap: () => _activatePlan(PremiumPlan.proMonthly),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Pro Yearly',
              subtitle: 'Tỷ lệ giữ chân và doanh thu dài hạn tốt hơn',
              price: '399.000đ / năm',
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
                    'Premium unlock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('• Nhiều cảnh báo hơn', style: TextStyle(color: Colors.white70)),
                  Text('• So sánh nâng cao hơn', style: TextStyle(color: Colors.white70)),
                  Text('• Insight và lịch sử giá trong tương lai', style: TextStyle(color: Colors.white70)),
                  Text('• Trải nghiệm ưu tiên để tăng khả năng chuyển đổi trả phí', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Đây là skeleton paywall nội bộ để chuẩn bị cho bước payment integration sau này.',
              style: TextStyle(color: Colors.white60),
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
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70),
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
            onPressed: onTap,
            child: const Text('Chọn gói này'),
          ),
        ],
      ),
    );
  }
}
