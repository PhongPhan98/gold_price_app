import 'package:flutter/material.dart';

class SummaryBadge extends StatelessWidget {
  const SummaryBadge({
    super.key,
    required this.label,
    required this.value,
    this.color = const Color.fromARGB(255, 202, 182, 1),
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isContact = value.trim().toLowerCase() == 'liên hệ';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isContact ? Colors.orangeAccent : color).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isContact ? Colors.orangeAccent : color,
              fontWeight: FontWeight.bold,
              fontStyle: isContact ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
