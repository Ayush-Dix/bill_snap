// BillSnap Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:bill_snap/models/bill_item.dart';

void main() {
  group('BillItem', () {
    test('getPriceForUser calculates correct weighted split', () {
      // Create an item worth $12 with weighted shares
      final item = BillItem(
        id: 'test-id',
        name: 'Test Item',
        price: 12.0,
        shares: {
          'userA': 3, // 3 shares
          'userB': 2, // 2 shares
          'userC': 1, // 1 share
        },
      );

      // Total shares = 6, price per share = $2
      expect(item.totalShares, 6);
      expect(item.pricePerShare, 2.0);

      // User A: 3 shares * $2 = $6
      expect(item.getPriceForUser('userA'), 6.0);

      // User B: 2 shares * $2 = $4
      expect(item.getPriceForUser('userB'), 4.0);

      // User C: 1 share * $2 = $2
      expect(item.getPriceForUser('userC'), 2.0);

      // Unknown user: 0 shares = $0
      expect(item.getPriceForUser('unknownUser'), 0.0);
    });

    test('unassigned item returns zero for all users', () {
      final item = BillItem(
        id: 'test-id',
        name: 'Unassigned Item',
        price: 10.0,
        shares: {},
      );

      expect(item.isUnassigned, true);
      expect(item.totalShares, 0);
      expect(item.getPriceForUser('anyUser'), 0.0);
    });

    test('single assignment gives 100% to one user', () {
      final item = BillItem(
        id: 'test-id',
        name: 'Single Assignment',
        price: 15.0,
        shares: {'userA': 1},
      );

      expect(item.isSingleAssignment, true);
      expect(item.getPriceForUser('userA'), 15.0);
      expect(item.getPriceForUser('userB'), 0.0);
    });

    test('isSplitByQuantity returns true for multiple users', () {
      final item = BillItem(
        id: 'test-id',
        name: 'Shared Item',
        price: 20.0,
        shares: {'userA': 1, 'userB': 1},
      );

      expect(item.isSplitByQuantity, true);
      expect(item.getPriceForUser('userA'), 10.0);
      expect(item.getPriceForUser('userB'), 10.0);
    });
  });
}
