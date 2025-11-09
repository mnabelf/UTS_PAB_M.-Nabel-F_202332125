import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String category;
  final String date;
  final double amount;
  final bool isIncome;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Card(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wallet, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  (isIncome ? "+ Rp " : "- Rp ") + amount.toInt().toString(),
                  style: TextStyle(
                    color: isIncome ? const Color(0xFF4CAF50) : Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
