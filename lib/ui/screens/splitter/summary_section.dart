import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../widgets/user_summary_card.dart';
import '../../theme/app_theme.dart';

/// Summary section showing per-user breakdowns
class SplitterSummarySection extends StatelessWidget {
  final Bill bill;
  final Map<String, AppUser> participants;
  final String currentUserId;

  const SplitterSummarySection({
    super.key,
    required this.bill,
    required this.participants,
    required this.currentUserId,
  });

  Widget _buildSectionHeader(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text('Summary', style: theme.textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${bill.participants.length}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 12,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? AppColors.lightAccent
        : AppColors.darkAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, accentColor),
        const SizedBox(height: 12),

        // Bill total
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bill Total', style: theme.textTheme.titleMedium),
                Text(
                  '₹${bill.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Individual summaries
        ...bill.participants.map((userId) {
          final user = participants[userId];
          final userTotal = bill.getTotalForUser(userId);
          final isCurrentUser = userId == currentUserId;

          return UserSummaryCard(
            user: user,
            userId: userId,
            amount: userTotal,
            items: bill.getItemsForUser(userId),
            isCurrentUser: isCurrentUser,
            isHost: userId == bill.hostId,
          );
        }),
      ],
    );
  }
}
