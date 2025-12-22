import 'package:flutter/material.dart';
import '../../models/app_user.dart';

/// Avatar widget for displaying a participant
class ParticipantAvatar extends StatelessWidget {
  final AppUser? user;
  final String userId;
  final bool isHost;
  final double amount;

  const ParticipantAvatar({
    super.key,
    this.user,
    required this.userId,
    this.isHost = false,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'User';
    final initials = _getInitials(displayName);
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? const Color(0xFFFF6B35)
        : const Color(0xFFFF8A5B);

    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _getAvatarColor(userId.hashCode),
                child: Text(
                  initials,
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
                      size: 10,
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFF1C1C1E)
                          : const Color(0xFF121212),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getFirstName(displayName),
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 10,
              color: amount > 0
                  ? accentColor
                  : theme.textTheme.bodyMedium?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  String _getFirstName(String name) {
    return name.split(' ').first;
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
