import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../widgets/bill_item_card.dart';

/// Section displaying bill items (either unassigned or assigned)
class ItemsSection extends StatelessWidget {
  final String title;
  final List<BillItem> items;
  final Map<String, AppUser> participants;
  final List<String> participantIds;
  final bool isHost;
  final Color sectionColor;
  final VoidCallback? onItemTap;
  final VoidCallback? onItemLongPress;
  final Function(BillItem)? onQuantitySplit;
  final Function(BillItem)? onItemActions;
  final Function(String itemId, String userId)? onAssignToUser;
  final Function(String itemId)? onUnassign;

  const ItemsSection({
    super.key,
    required this.title,
    required this.items,
    required this.participants,
    required this.participantIds,
    required this.isHost,
    required this.sectionColor,
    this.onItemTap,
    this.onItemLongPress,
    this.onQuantitySplit,
    this.onItemActions,
    this.onAssignToUser,
    this.onUnassign,
  });

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: sectionColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: sectionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${items.length}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 12,
              color: sectionColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 12),
        ...items.map(
          (item) => BillItemCard(
            item: item,
            participants: participants,
            isHost: isHost,
            onTap: onQuantitySplit != null
                ? () => onQuantitySplit!(item)
                : null,
            onLongPress: onItemActions != null
                ? () => onItemActions!(item)
                : null,
            onAssignToUser: onAssignToUser != null
                ? (userId) => onAssignToUser!(item.id, userId)
                : null,
            onUnassign: onUnassign != null ? () => onUnassign!(item.id) : null,
            participantIds: participantIds,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
