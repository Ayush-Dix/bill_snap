import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/cubit.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import 'scanner_screen.dart';
import 'splitter_screen.dart';

/// Home screen showing list of bills
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BillCubit _billCubit;
  bool _showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();
    final userId = authCubit.currentUserId;

    if (userId != null) {
      _billCubit = BillCubit(
        firestoreService: context.read<FirestoreService>(),
        userId: userId,
      );
      _billCubit.loadBills();
    }
  }

  @override
  void dispose() {
    _billCubit.close();
    super.dispose();
  }

  void _navigateToScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            BlocProvider.value(value: _billCubit, child: const ScannerScreen()),
      ),
    );
  }

  void _navigateToSplitter(String billId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _billCubit,
          child: SplitterScreen(billId: billId),
        ),
      ),
    );
    // Reload bills when returning from splitter screen
    if (mounted) {
      _billCubit.loadBills();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.brightness == Brightness.light
        ? const Color(0xFFFF6B35)
        : const Color(0xFFFF8A5B);

    return BlocProvider.value(
      value: _billCubit,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          final displayName = user?.displayName ?? 'User';
          final initials = _getInitials(displayName);

          return Scaffold(
            appBar: AppBar(
              title: const Text('BillSnap'),
              actions: [
                // User avatar with menu
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  onSelected: (value) {
                    switch (value) {
                      case 'toggle_theme':
                        context.read<ThemeCubit>().toggleTheme();
                        break;
                      case 'sign_out':
                        context.read<AuthCubit>().signOut();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    final isDark = theme.brightness == Brightness.dark;
                    return [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              user?.email ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'toggle_theme',
                        child: ListTile(
                          leading: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                          ),
                          title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'sign_out',
                        child: ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ];
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: accentColor,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: BlocBuilder<BillCubit, BillState>(
              builder: (context, state) {
                if (state is BillLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BillError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _billCubit.loadBills(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is BillsLoaded) {
                  if (state.bills.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildBillsList(state.bills);
                }

                return _buildEmptyState();
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _navigateToScanner,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Receipt'),
            ),
          );
        },
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

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Bills Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a receipt to create your first bill and start splitting with friends',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsList(List<Bill> bills) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFFFF8A5B)
        : const Color(0xFFFF6B35);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    // Filter bills based on toggle
    final filteredBills = _showActiveOnly
        ? bills.where((b) => b.status == BillStatus.active).toList()
        : bills;

    return Column(
      children: [
        // Filter toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Text('Your Bills', style: theme.textTheme.titleMedium),
              const Spacer(),
              // Active only toggle
              InkWell(
                onTap: () => setState(() => _showActiveOnly = !_showActiveOnly),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _showActiveOnly
                        ? accentColor.withOpacity(0.1)
                        : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                    border: _showActiveOnly
                        ? Border.all(color: accentColor, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showActiveOnly
                            ? Icons.check_circle
                            : Icons.filter_list,
                        size: 16,
                        color: _showActiveOnly
                            ? accentColor
                            : (isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active Only',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: _showActiveOnly
                              ? accentColor
                              : (isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                          fontWeight: _showActiveOnly
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Bills list
        Expanded(
          child: filteredBills.isEmpty
              ? Center(
                  child: Text(
                    'No active bills',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBills.length,
                  itemBuilder: (context, index) {
                    final bill = filteredBills[index];
                    final isActive = bill.status == BillStatus.active;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _navigateToSplitter(bill.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      bill.title ?? 'Bill',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(fontSize: 18),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? (isDark
                                                ? Colors.green.shade900
                                                      .withOpacity(0.3)
                                                : Colors.green.shade50)
                                          : (isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isActive ? 'Active' : 'Closed',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontSize: 12,
                                            color: isActive
                                                ? (isDark
                                                      ? Colors.green.shade400
                                                      : Colors.green.shade700)
                                                : (isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateFormat.format(bill.createdAt),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.receipt,
                                    size: 16,
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${bill.items.length} items',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.people,
                                    size: 16,
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${bill.participants.length} people',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${bill.totalAmount.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontSize: 18,
                                          color: accentColor,
                                        ),
                                  ),
                                ],
                              ),
                              if (!bill.isFullyAssigned) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: bill.assignedAmount / bill.totalAmount,
                                  backgroundColor: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF6366F1),
                                      ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${bill.unassignedItems.length} items unassigned',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.orange.shade400
                                        : Colors.orange.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
