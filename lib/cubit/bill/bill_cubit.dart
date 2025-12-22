import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import 'bill_state.dart';

/// Cubit for managing bill operations
class BillCubit extends Cubit<BillState> {
  final FirestoreService _firestoreService;
  final String _userId;

  StreamSubscription? _billsSubscription;
  StreamSubscription? _billDetailSubscription;

  BillCubit({
    required FirestoreService firestoreService,
    required String userId,
  }) : _firestoreService = firestoreService,
       _userId = userId,
       super(const BillInitial());

  /// Load all bills for the current user
  void loadBills() {
    emit(const BillLoading());

    _billsSubscription?.cancel();
    _billsSubscription = _firestoreService
        .streamUserBills(_userId)
        .listen(
          (bills) {
            emit(BillsLoaded(bills));
          },
          onError: (error) {
            emit(BillError('Failed to load bills: $error'));
          },
        );
  }

  /// Load a specific bill by ID with real-time updates
  void loadBillDetail(String billId) {
    // Only emit loading if we don't have current detail data
    if (state is! BillDetailLoaded) {
      emit(const BillLoading());
    }

    _billDetailSubscription?.cancel();
    _billDetailSubscription = _firestoreService
        .streamBill(billId)
        .listen(
          (bill) async {
            if (bill == null) {
              emit(const BillError('Bill not found'));
              return;
            }

            // Load participant profiles
            final participants = await _firestoreService.getUserProfiles(
              bill.participants,
            );

            emit(BillDetailLoaded(bill: bill, participants: participants));
          },
          onError: (error) {
            emit(BillError('Failed to load bill: $error'));
          },
        );
  }

  /// Create a new bill from scanned items
  Future<String?> createBill({
    required List<BillItem> items,
    String? title,
    List<String>? additionalParticipants,
  }) async {
    emit(const BillOperating('Creating bill...'));

    try {
      final participants = <String>[_userId, ...(additionalParticipants ?? [])];

      final billId = await _firestoreService.createBill(
        hostId: _userId,
        items: items,
        participants: participants,
        title: title,
      );

      emit(BillCreated(billId));
      return billId;
    } catch (e) {
      emit(BillError('Failed to create bill: $e'));
      return null;
    }
  }

  /// Update item shares (weighted split)
  Future<void> updateItemShares({
    required String billId,
    required String itemId,
    required Map<String, int> newShares,
  }) async {
    try {
      await _firestoreService.updateItemShares(
        billId: billId,
        itemId: itemId,
        newShares: newShares,
      );
      // The stream will automatically update the UI
    } catch (e) {
      emit(BillError('Failed to update shares: $e'));
    }
  }

  /// Assign item to a single user (100% ownership)
  Future<void> assignItemToUser({
    required String billId,
    required String itemId,
    required String userId,
  }) async {
    await updateItemShares(
      billId: billId,
      itemId: itemId,
      newShares: {userId: 1},
    );
  }

  /// Unassign item (remove all shares)
  Future<void> unassignItem({
    required String billId,
    required String itemId,
  }) async {
    await updateItemShares(billId: billId, itemId: itemId, newShares: {});
  }

  /// Add a participant to a bill
  Future<void> addParticipant({
    required String billId,
    required String userEmail,
  }) async {
    try {
      // Search for user by email
      final users = await _firestoreService.searchUsersByEmail(userEmail);

      if (users.isEmpty) {
        emit(const BillError('User not found with that email'));
        return;
      }

      await _firestoreService.addParticipant(
        billId: billId,
        userId: users.first.uid,
      );
    } catch (e) {
      emit(BillError('Failed to add participant: $e'));
    }
  }

  /// Remove a participant from a bill
  Future<void> removeParticipant({
    required String billId,
    required String userId,
  }) async {
    try {
      await _firestoreService.removeParticipant(billId: billId, userId: userId);
    } catch (e) {
      emit(BillError('Failed to remove participant: $e'));
    }
  }

  /// Add a new item to a bill
  Future<void> addItem({
    required String billId,
    required String name,
    required double price,
  }) async {
    try {
      final item = BillItem.create(name: name, price: price);
      await _firestoreService.addItem(billId: billId, item: item);
    } catch (e) {
      emit(BillError('Failed to add item: $e'));
    }
  }

  /// Remove an item from a bill
  Future<void> removeItem({
    required String billId,
    required String itemId,
  }) async {
    try {
      await _firestoreService.removeItem(billId: billId, itemId: itemId);
    } catch (e) {
      emit(BillError('Failed to remove item: $e'));
    }
  }

  /// Update bill title
  Future<void> updateBillTitle({
    required String billId,
    required String newTitle,
  }) async {
    try {
      await _firestoreService.updateBillTitle(billId: billId, title: newTitle);
    } catch (e) {
      emit(BillError('Failed to update bill title: $e'));
    }
  }

  /// Update item name
  Future<void> updateItemName({
    required String billId,
    required String itemId,
    required String newName,
  }) async {
    try {
      await _firestoreService.updateItemName(
        billId: billId,
        itemId: itemId,
        name: newName,
      );
    } catch (e) {
      emit(BillError('Failed to update item name: $e'));
    }
  }

  /// Update item (name and/or price)
  Future<void> updateItem({
    required String billId,
    required BillItem updatedItem,
  }) async {
    try {
      await _firestoreService.updateItem(
        billId: billId,
        updatedItem: updatedItem,
      );
    } catch (e) {
      emit(BillError('Failed to update item: $e'));
    }
  }

  /// Close a bill
  Future<void> closeBill(String billId) async {
    try {
      await _firestoreService.closeBill(billId);
    } catch (e) {
      emit(BillError('Failed to close bill: $e'));
    }
  }

  /// Reopen a bill
  Future<void> reopenBill(String billId) async {
    try {
      await _firestoreService.reopenBill(billId);
    } catch (e) {
      emit(BillError('Failed to reopen bill: $e'));
    }
  }

  /// Delete a bill
  Future<void> deleteBill(String billId) async {
    try {
      // Cancel the detail subscription before deleting
      _billDetailSubscription?.cancel();
      _billDetailSubscription = null;

      await _firestoreService.deleteBill(billId);

      // Reload bills list after deletion
      loadBills();
    } catch (e) {
      emit(BillError('Failed to delete bill: $e'));
    }
  }

  @override
  Future<void> close() {
    _billsSubscription?.cancel();
    _billDetailSubscription?.cancel();
    return super.close();
  }
}
