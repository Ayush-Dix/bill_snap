import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Service for handling Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== BILLS COLLECTION ====================

  /// Reference to bills collection
  CollectionReference<Map<String, dynamic>> get _billsCollection =>
      _firestore.collection('bills');

  /// Create a new bill
  Future<String> createBill({
    required String hostId,
    required List<BillItem> items,
    List<String>? participants,
    String? title,
  }) async {
    try {
      final docRef = await _billsCollection.add({
        'hostId': hostId,
        'status': 'active',
        'participants': participants ?? [hostId],
        'items': items.map((item) => item.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'title':
            title ?? 'Bill ${DateTime.now().toIso8601String().split('T')[0]}',
      });
      return docRef.id;
    } catch (e) {
      throw FirestoreException('Failed to create bill: $e');
    }
  }

  /// Get a single bill by ID
  Future<Bill?> getBill(String billId) async {
    try {
      final doc = await _billsCollection.doc(billId).get();
      if (!doc.exists) return null;
      return Bill.fromFirestore(doc);
    } catch (e) {
      throw FirestoreException('Failed to get bill: $e');
    }
  }

  /// Stream a single bill (real-time updates)
  Stream<Bill?> streamBill(String billId) {
    return _billsCollection.doc(billId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Bill.fromFirestore(doc);
    });
  }

  /// Stream bills for a user (as host or participant)
  Stream<List<Bill>> streamUserBills(String userId) {
    return _billsCollection
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList();
        });
  }

  /// Update item shares (the core split functionality)
  Future<void> updateItemShares({
    required String billId,
    required String itemId,
    required Map<String, int> newShares,
  }) async {
    try {
      // First, get the current bill
      final doc = await _billsCollection.doc(billId).get();
      if (!doc.exists) {
        throw FirestoreException('Bill not found');
      }

      final bill = Bill.fromFirestore(doc);

      // Find and update the item
      final updatedItems = bill.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(shares: newShares);
        }
        return item;
      }).toList();

      // Update Firestore
      await _billsCollection.doc(billId).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update item shares: $e');
    }
  }

  /// Add a participant to a bill
  Future<void> addParticipant({
    required String billId,
    required String userId,
  }) async {
    try {
      await _billsCollection.doc(billId).update({
        'participants': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw FirestoreException('Failed to add participant: $e');
    }
  }

  /// Remove a participant from a bill
  Future<void> removeParticipant({
    required String billId,
    required String userId,
  }) async {
    try {
      // First, remove shares for this user from all items
      final doc = await _billsCollection.doc(billId).get();
      if (!doc.exists) {
        throw FirestoreException('Bill not found');
      }

      final bill = Bill.fromFirestore(doc);

      // Remove user's shares from all items
      final updatedItems = bill.items.map((item) {
        final newShares = Map<String, int>.from(item.shares);
        newShares.remove(userId);
        return item.copyWith(shares: newShares);
      }).toList();

      await _billsCollection.doc(billId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'items': updatedItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      throw FirestoreException('Failed to remove participant: $e');
    }
  }

  /// Close a bill
  Future<void> closeBill(String billId) async {
    try {
      await _billsCollection.doc(billId).update({'status': 'closed'});
    } catch (e) {
      throw FirestoreException('Failed to close bill: $e');
    }
  }

  /// Reopen a bill
  Future<void> reopenBill(String billId) async {
    try {
      await _billsCollection.doc(billId).update({'status': 'active'});
    } catch (e) {
      throw FirestoreException('Failed to reopen bill: $e');
    }
  }

  /// Delete a bill
  Future<void> deleteBill(String billId) async {
    try {
      await _billsCollection.doc(billId).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete bill: $e');
    }
  }

  /// Add a new item to a bill
  Future<void> addItem({required String billId, required BillItem item}) async {
    try {
      await _billsCollection.doc(billId).update({
        'items': FieldValue.arrayUnion([item.toMap()]),
      });
    } catch (e) {
      throw FirestoreException('Failed to add item: $e');
    }
  }

  /// Remove an item from a bill
  Future<void> removeItem({
    required String billId,
    required String itemId,
  }) async {
    try {
      final doc = await _billsCollection.doc(billId).get();
      if (!doc.exists) {
        throw FirestoreException('Bill not found');
      }

      final bill = Bill.fromFirestore(doc);
      final updatedItems = bill.items
          .where((item) => item.id != itemId)
          .toList();

      await _billsCollection.doc(billId).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      throw FirestoreException('Failed to remove item: $e');
    }
  }

  /// Update an item in a bill
  Future<void> updateItem({
    required String billId,
    required BillItem updatedItem,
  }) async {
    try {
      final doc = await _billsCollection.doc(billId).get();
      if (!doc.exists) {
        throw FirestoreException('Bill not found');
      }

      final bill = Bill.fromFirestore(doc);
      final updatedItems = bill.items.map((item) {
        if (item.id == updatedItem.id) {
          return updatedItem;
        }
        return item;
      }).toList();

      await _billsCollection.doc(billId).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update item: $e');
    }
  }

  /// Update bill title
  Future<void> updateBillTitle({
    required String billId,
    required String title,
  }) async {
    try {
      await _billsCollection.doc(billId).update({'title': title});
    } catch (e) {
      throw FirestoreException('Failed to update bill title: $e');
    }
  }

  /// Update item name
  Future<void> updateItemName({
    required String billId,
    required String itemId,
    required String name,
  }) async {
    try {
      final doc = await _billsCollection.doc(billId).get();
      if (!doc.exists) {
        throw FirestoreException('Bill not found');
      }

      final bill = Bill.fromFirestore(doc);
      final updatedItems = bill.items.map((item) {
        if (item.id == itemId) {
          return BillItem(
            id: item.id,
            name: name,
            price: item.price,
            shares: item.shares,
          );
        }
        return item;
      }).toList();

      await _billsCollection.doc(billId).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update item name: $e');
    }
  }

  // ==================== USERS COLLECTION ====================

  /// Reference to users collection
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create or update user profile
  Future<void> saveUserProfile(AppUser user) async {
    try {
      await _usersCollection
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to save user profile: $e');
    }
  }

  /// Get user profile by ID
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!, userId);
    } catch (e) {
      throw FirestoreException('Failed to get user profile: $e');
    }
  }

  /// Get multiple user profiles by IDs
  Future<Map<String, AppUser>> getUserProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    try {
      final Map<String, AppUser> profiles = {};

      // Firestore has a limit of 10 items per 'whereIn' query
      for (var i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final snapshot = await _usersCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          profiles[doc.id] = AppUser.fromMap(doc.data(), doc.id);
        }
      }

      return profiles;
    } catch (e) {
      throw FirestoreException('Failed to get user profiles: $e');
    }
  }

  /// Search users by email
  Future<List<AppUser>> searchUsersByEmail(String email) async {
    try {
      final snapshot = await _usersCollection
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to search users: $e');
    }
  }
}

/// Custom exception for Firestore errors
class FirestoreException implements Exception {
  final String message;

  FirestoreException(this.message);

  @override
  String toString() => message;
}
