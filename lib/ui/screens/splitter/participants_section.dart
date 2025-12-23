import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../widgets/participant_avatar.dart';
import '../../theme/app_theme.dart';

/// Participants section with avatars and add button
class ParticipantsSection extends StatelessWidget {
  final Bill bill;
  final Map<String, AppUser> participants;
  final String currentUserId;
  final VoidCallback onAddParticipant;
  final Function(String userId, AppUser user) onRemoveParticipant;

  const ParticipantsSection({
    super.key,
    required this.bill,
    required this.participants,
    required this.currentUserId,
    required this.onAddParticipant,
    required this.onRemoveParticipant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? AppColors.lightAccent
        : AppColors.darkAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.light
                ? AppColors.lightInk.withOpacity(0.1)
                : AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Participants', style: theme.textTheme.labelSmall),
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
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bill.participants.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == bill.participants.length) {
                  return _buildAddParticipantButton(context, accentColor);
                }

                final userId = bill.participants[index];
                final user = participants[userId];
                final userTotal = bill.getTotalForUser(userId);
                final isHost = bill.hostId == currentUserId;
                final canRemove = isHost && userId != bill.hostId;

                return GestureDetector(
                  onTap: canRemove
                      ? () => onRemoveParticipant(userId, user!)
                      : null,
                  child: ParticipantAvatar(
                    user: user,
                    userId: userId,
                    isHost: userId == bill.hostId,
                    amount: userTotal,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddParticipantButton(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 60,
      child: InkWell(
        onTap: onAddParticipant,
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
              ),
              child: Icon(Icons.add, color: accentColor, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: accentColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
