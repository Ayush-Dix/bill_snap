import 'package:flutter/material.dart';
import '../../../models/models.dart';

/// Header section for the bill with title and total
class BillHeader extends StatelessWidget {
  final Bill bill;
  final VoidCallback onEditTitle;

  const BillHeader({super.key, required this.bill, required this.onEditTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? const Color(0xFFFF6B35)
        : const Color(0xFFFF8A5B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withOpacity(0.1), accentColor.withOpacity(0.05)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bill.title ?? 'Bill',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEditTitle,
                tooltip: 'Edit bill name',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Bill Total',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${bill.totalAmount.toStringAsFixed(2)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
