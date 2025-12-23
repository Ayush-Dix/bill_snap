import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../theme/app_theme.dart';

/// Card widget for displaying a bill item
class BillItemCard extends StatelessWidget {
  final BillItem item;
  final Map<String, AppUser> participants;
  final List<String> participantIds;
  final VoidCallback? onTap;
  final Function(String userId)? onAssignToUser;
  final VoidCallback? onUnassign;
  final VoidCallback? onLongPress;
  final bool isHost;

  const BillItemCard({
    super.key,
    required this.item,
    required this.participants,
    required this.participantIds,
    this.onTap,
    this.onAssignToUser,
    this.onUnassign,
    this.onLongPress,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? AppColors.lightAccent
        : AppColors.darkAccent;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        if (item.isSplitByQuantity)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Split by Quantity (${item.totalShares} shares)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: accentColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),

              // Show assignment status
              if (!item.isUnassigned) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _buildAssignmentInfo(context),
              ],

              // Quick assign buttons for unassigned items
              if (item.isUnassigned && onAssignToUser != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _buildQuickAssignButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentInfo(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? AppColors.lightAccent
        : AppColors.darkAccent;
    final bgColor = theme.brightness == Brightness.light
        ? AppColors.lightCanvas
        : AppColors.darkGray200;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: item.shares.entries.map((entry) {
        final userId = entry.key;
        final shares = entry.value;
        final user = participants[userId];
        final amount = item.getPriceForUser(userId);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: _getAvatarColor(userId.hashCode),
                child: Text(
                  _getInitials(user?.displayName ?? 'U'),
                  style: TextStyle(
                    color: AppColors.lightSurface,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                user?.displayName.split(' ').first ?? 'User',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              if (item.isSplitByQuantity) ...[
                const SizedBox(width: 4),
                Text(
                  '×$shares',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
              const SizedBox(width: 6),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 11,
                  color: accentColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAssignButtons(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.light
        ? AppColors.lightInk.withOpacity(0.2)
        : AppColors.darkBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick assign:',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: participantIds.map((userId) {
            final user = participants[userId];
            return InkWell(
              onTap: () => onAssignToUser?.call(userId),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: _getAvatarColor(userId.hashCode),
                      child: Text(
                        _getInitials(user?.displayName ?? 'U'),
                        style: TextStyle(
                          color: AppColors.lightSurface,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user?.displayName.split(' ').first ?? 'User',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Color _getAvatarColor(int hash) {
    return AppColors.avatarColors[hash.abs() % AppColors.avatarColors.length];
  }
}
