import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Dialog for splitting an item by quantity among participants
class QuantitySplitDialog extends StatefulWidget {
  final BillItem item;
  final Map<String, AppUser> participants;
  final List<String> participantIds;
  final Function(Map<String, int> shares) onSave;

  const QuantitySplitDialog({
    super.key,
    required this.item,
    required this.participants,
    required this.participantIds,
    required this.onSave,
  });

  @override
  State<QuantitySplitDialog> createState() => _QuantitySplitDialogState();
}

class _QuantitySplitDialogState extends State<QuantitySplitDialog> {
  late Map<String, int> _shares;

  @override
  void initState() {
    super.initState();
    // Initialize shares from existing item shares
    _shares = Map.from(widget.item.shares);

    // Ensure all participants have an entry (default 0)
    for (final userId in widget.participantIds) {
      _shares.putIfAbsent(userId, () => 0);
    }
  }

  int get _totalShares => _shares.values.fold(0, (sum, qty) => sum + qty);

  double get _pricePerShare {
    if (_totalShares == 0) return 0;
    return widget.item.price / _totalShares;
  }

  void _incrementShare(String userId) {
    setState(() {
      _shares[userId] = (_shares[userId] ?? 0) + 1;
    });
  }

  void _decrementShare(String userId) {
    setState(() {
      final current = _shares[userId] ?? 0;
      if (current > 0) {
        _shares[userId] = current - 1;
      }
    });
  }

  void _saveShares() {
    // Filter out zero shares before saving
    final filteredShares = Map<String, int>.from(_shares)
      ..removeWhere((key, value) => value == 0);

    widget.onSave(filteredShares);
    Navigator.pop(context);
  }

  void _splitEvenly() {
    setState(() {
      for (final userId in widget.participantIds) {
        _shares[userId] = 1; // Equal share of 1 each
      }
    });
  }

  void _clearAll() {
    setState(() {
      for (final userId in widget.participantIds) {
        _shares[userId] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? const Color(0xFFFF6B35)
        : const Color(0xFFFF8A5B);
    final borderColor = theme.brightness == Brightness.light
        ? const Color(0xFF1C1C1E).withOpacity(0.2)
        : const Color(0xFF333333);
    final bgColor = theme.brightness == Brightness.light
        ? const Color(0xFFF4F2EE)
        : const Color(0xFF2A2A2A);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Split by Quantity',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(widget.item.name, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${widget.item.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _splitEvenly,
                    icon: const Icon(Icons.balance, size: 18),
                    label: const Text('Split Evenly'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price per share indicator
            if (_totalShares > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: accentColor),
                    const SizedBox(width: 8),
                    Text(
                      'Each share costs ₹${_pricePerShare.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Participants list with steppers
            Text(
              'Assign shares to each person:',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.participantIds.length,
                itemBuilder: (context, index) {
                  final userId = widget.participantIds[index];
                  final user = widget.participants[userId];
                  final userShares = _shares[userId] ?? 0;
                  final userAmount = _totalShares > 0
                      ? (widget.item.price / _totalShares) * userShares
                      : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: userShares > 0
                          ? accentColor.withOpacity(0.05)
                          : bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: userShares > 0
                            ? accentColor.withOpacity(0.2)
                            : borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _getAvatarColor(index),
                          child: Text(
                            _getInitials(user?.displayName ?? 'U'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name and amount
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'User',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              if (userShares > 0)
                                Text(
                                  '₹${userAmount.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 12,
                                    color: accentColor,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Quantity stepper
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Decrement button
                              InkWell(
                                onTap: () => _decrementShare(userId),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(7),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: userShares > 0
                                        ? accentColor
                                        : theme.textTheme.bodyMedium?.color
                                              ?.withOpacity(0.4),
                                  ),
                                ),
                              ),

                              // Quantity display
                              Container(
                                constraints: const BoxConstraints(minWidth: 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(color: borderColor),
                                  ),
                                ),
                                child: Text(
                                  '$userShares',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontSize: 16,
                                    color: userShares > 0
                                        ? accentColor
                                        : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),

                              // Increment button
                              InkWell(
                                onTap: () => _incrementShare(userId),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(7),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveShares,
                child: Text(
                  _totalShares > 0
                      ? 'Save Split ($_totalShares shares)'
                      : 'Mark as Unassigned',
                ),
              ),
            ),
            const SizedBox(height: 8),
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

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[index % colors.length];
  }
}
