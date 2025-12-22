import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents an individual item on a bill/receipt
class BillItem extends Equatable {
  final String id;
  final String name;
  final double price; // Total price for this line item
  final Map<String, int> shares; // Key: User UID, Value: Quantity consumed

  const BillItem({
    required this.id,
    required this.name,
    required this.price,
    this.shares = const {},
  });

  /// Factory constructor to create a new BillItem with auto-generated ID
  factory BillItem.create({
    required String name,
    required double price,
    Map<String, int>? shares,
  }) {
    return BillItem(
      id: const Uuid().v4(),
      name: name,
      price: price,
      shares: shares ?? {},
    );
  }

  /// Check if this item is unassigned (no shares)
  bool get isUnassigned => shares.isEmpty;

  /// Check if this item is assigned to a single user (100%)
  bool get isSingleAssignment => shares.length == 1;

  /// Check if this item is split between multiple users
  bool get isSplitByQuantity => shares.length > 1;

  /// Get total shares count (sum of all quantities)
  int get totalShares => shares.values.fold(0, (sum, qty) => sum + qty);

  /// Get the price per share
  double get pricePerShare {
    if (totalShares == 0) return 0;
    return price / totalShares;
  }

  /// Get the price portion for a specific user
  /// This implements the weighted split calculation
  double getPriceForUser(String uid) {
    final userShares = shares[uid] ?? 0;
    if (totalShares == 0 || userShares == 0) return 0;
    return pricePerShare * userShares;
  }

  /// Get the quantity/shares for a specific user
  int getSharesForUser(String uid) => shares[uid] ?? 0;

  /// Get list of user IDs who have shares in this item
  List<String> get assignedUserIds => shares.keys.toList();

  /// Create from Firestore map
  factory BillItem.fromMap(Map<String, dynamic> map) {
    // Handle shares conversion from dynamic map
    Map<String, int> sharesMap = {};
    if (map['shares'] != null) {
      final rawShares = map['shares'] as Map<String, dynamic>;
      sharesMap = rawShares.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );
    }

    return BillItem(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      shares: sharesMap,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price, 'shares': shares};
  }

  /// Copy with updated values
  BillItem copyWith({
    String? id,
    String? name,
    double? price,
    Map<String, int>? shares,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      shares: shares ?? this.shares,
    );
  }

  @override
  List<Object?> get props => [id, name, price, shares];
}
