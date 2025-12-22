import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Card widget for displaying a user's bill summary
class UserSummaryCard extends StatelessWidget {
  final AppUser? user;
  final String userId;
  final double amount;
  final List<BillItem> items;
  final bool isCurrentUser;
  final bool isHost;

  const UserSummaryCard({
    super.key,
    this.user,
    required this.userId,
    required this.amount,
    required this.items,
    this.isCurrentUser = false,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'User';
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? const Color(0xFFFF6B35)
        : const Color(0xFFFF8A5B);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? BorderSide(color: accentColor, width: 2)
            : BorderSide.none,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getAvatarColor(userId.hashCode),
                child: Text(
                  _getInitials(displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isHost)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFFD4E157)
                          : const Color(0xFFD4E157),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 8,
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFF1C1C1E)
                          : const Color(0xFF121212),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Text(
                displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isCurrentUser ? accentColor : null,
                ),
              ),
              if (isCurrentUser)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'You',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '${items.length} items',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          trailing: Text(
            '₹${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? accentColor : null,
            ),
          ),
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No items assigned yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: items.map((item) {
                    final userAmount = item.getPriceForUser(userId);
                    final userShares = item.getSharesForUser(userId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                                if (item.isSplitByQuantity)
                                  Text(
                                    '$userShares of ${item.totalShares} shares',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${userAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
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
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    return colors[hash.abs() % colors.length];
  }
}
