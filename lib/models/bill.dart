import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'bill_item.dart';

/// Status of a bill
enum BillStatus { active, closed }

/// Represents a bill/receipt that can be split among participants
class Bill extends Equatable {
  final String id;
  final String hostId;
  final BillStatus status;
  final List<String> participants;
  final List<BillItem> items;
  final DateTime createdAt;
  final String? title;

  const Bill({
    required this.id,
    required this.hostId,
    this.status = BillStatus.active,
    this.participants = const [],
    this.items = const [],
    required this.createdAt,
    this.title,
  });

  /// Check if a user is the host
  bool isHost(String uid) => hostId == uid;

  /// Check if a user is a participant
  bool isParticipant(String uid) => participants.contains(uid);

  /// Get total bill amount
  double get totalAmount =>
      items.fold(0.0, (total, item) => total + item.price);

  /// Get total amount for a specific user based on their shares
  double getTotalForUser(String uid) {
    return items.fold(0.0, (total, item) => total + item.getPriceForUser(uid));
  }

  /// Get unassigned items (items with no shares)
  List<BillItem> get unassignedItems =>
      items.where((item) => item.isUnassigned).toList();

  /// Get assigned items
  List<BillItem> get assignedItems =>
      items.where((item) => !item.isUnassigned).toList();

  /// Get items assigned to a specific user
  List<BillItem> getItemsForUser(String uid) =>
      items.where((item) => item.shares.containsKey(uid)).toList();

  /// Get total assigned amount
  double get assignedAmount =>
      assignedItems.fold(0.0, (total, item) => total + item.price);

  /// Get total unassigned amount
  double get unassignedAmount =>
      unassignedItems.fold(0.0, (total, item) => total + item.price);

  /// Check if bill is fully assigned
  bool get isFullyAssigned => unassignedItems.isEmpty;

  /// Create from Firestore document
  factory Bill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items
    List<BillItem> itemsList = [];
    if (data['items'] != null) {
      final rawItems = data['items'] as List<dynamic>;
      itemsList = rawItems
          .map((item) => BillItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    // Parse participants
    List<String> participantsList = [];
    if (data['participants'] != null) {
      participantsList = List<String>.from(data['participants']);
    }

    // Parse status
    BillStatus billStatus = BillStatus.active;
    if (data['status'] == 'closed') {
      billStatus = BillStatus.closed;
    }

    return Bill(
      id: doc.id,
      hostId: data['hostId'] ?? '',
      status: billStatus,
      participants: participantsList,
      items: itemsList,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      title: data['title'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'hostId': hostId,
      'status': status == BillStatus.active ? 'active' : 'closed',
      'participants': participants,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'title': title,
    };
  }

  /// Copy with updated values
  Bill copyWith({
    String? id,
    String? hostId,
    BillStatus? status,
    List<String>? participants,
    List<BillItem>? items,
    DateTime? createdAt,
    String? title,
  }) {
    return Bill(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hostId,
    status,
    participants,
    items,
    createdAt,
    title,
  ];
}
