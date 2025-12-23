import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/cubit.dart';
import '../../models/models.dart';
import '../widgets/quantity_split_dialog.dart';
import '../widgets/edit_dialogs.dart';
import '../theme/app_theme.dart';
import 'splitter/participants_section.dart';
import 'splitter/items_section.dart';
import 'splitter/summary_section.dart';

/// Main splitter screen for managing bill splits
class SplitterScreen extends StatefulWidget {
  final String billId;

  const SplitterScreen({super.key, required this.billId});

  @override
  State<SplitterScreen> createState() => _SplitterScreenState();
}

class _SplitterScreenState extends State<SplitterScreen> {
  // Cache the last loaded bill to prevent flashing during updates
  Bill? _lastBill;
  Map<String, AppUser>? _lastParticipants;

  @override
  void initState() {
    super.initState();
    context.read<BillCubit>().loadBillDetail(widget.billId);
  }

  void _showAddParticipantDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Add Participant',
          style: Theme.of(
            dialogContext,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter participant email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                this.context.read<BillCubit>().addParticipant(
                  billId: widget.billId,
                  userEmail: email,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showQuantitySplitDialog(
    BuildContext context,
    BillItem item,
    Bill bill,
    Map<String, AppUser> participants,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => QuantitySplitDialog(
        item: item,
        participants: participants,
        participantIds: bill.participants,
        onSave: (shares) {
          context.read<BillCubit>().updateItemShares(
            billId: widget.billId,
            itemId: item.id,
            newShares: shares,
          );
        },
      ),
    );
  }

  void _assignToUser(String itemId, String userId) {
    context.read<BillCubit>().assignItemToUser(
      billId: widget.billId,
      itemId: itemId,
      userId: userId,
    );
  }

  void _unassignItem(String itemId) {
    context.read<BillCubit>().unassignItem(
      billId: widget.billId,
      itemId: itemId,
    );
  }

  void _showEditBillTitleDialog(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (_) => EditBillTitleDialog(
        currentTitle: bill.title ?? 'Bill',
        onSave: (newTitle) {
          context.read<BillCubit>().updateBillTitle(
            billId: widget.billId,
            newTitle: newTitle,
          );
        },
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, BillItem item) {
    showDialog(
      context: context,
      builder: (_) => EditItemDialog(
        item: item,
        onSave: (newName, newPrice) {
          // Create updated item with new name and price, preserving shares
          final updatedItem = item.copyWith(name: newName, price: newPrice);
          context.read<BillCubit>().updateItem(
            billId: widget.billId,
            updatedItem: updatedItem,
          );
        },
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, BillItem item) {
    showDialog(
      context: context,
      builder: (_) => RemoveItemDialog(
        item: item,
        onConfirm: () {
          context.read<BillCubit>().removeItem(
            billId: widget.billId,
            itemId: item.id,
          );
        },
      ),
    );
  }

  void _showRemoveParticipantDialog(
    BuildContext context,
    AppUser? user,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (_) => RemoveParticipantDialog(
        user: user,
        userId: userId,
        onConfirm: () {
          context.read<BillCubit>().removeParticipant(
            billId: widget.billId,
            userId: userId,
          );
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddItemDialog(
        onSave: (name, price) {
          context.read<BillCubit>().addItem(
            billId: widget.billId,
            name: name,
            price: price,
          );
        },
      ),
    );
  }

  void _showItemActionsSheet(
    BuildContext context,
    BillItem item,
    Bill bill,
    Map<String, AppUser> participants,
    bool isHost,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ItemActionsBottomSheet(
        item: item,
        isHost: isHost,
        onEdit: () => _showEditItemDialog(context, item),
        onRemove: () => _showRemoveItemDialog(context, item),
        onSplit: () =>
            _showQuantitySplitDialog(context, item, bill, participants),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillCubit, BillState>(
      builder: (context, state) {
        // Update cache when new data arrives
        if (state is BillDetailLoaded) {
          _lastBill = state.bill;
          _lastParticipants = state.participants;
          return _buildSplitterUI(context, state.bill, state.participants);
        }

        // Show cached data during loading/error if available (prevents flashing)
        if ((state is BillLoading || state is BillError) &&
            _lastBill != null &&
            _lastParticipants != null) {
          return Stack(
            children: [
              _buildSplitterUI(context, _lastBill!, _lastParticipants!),
              if (state is BillLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightAccent
                          : AppColors.darkAccent,
                    ),
                  ),
                ),
            ],
          );
        }

        // Initial loading state
        if (state is BillLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error state (without cached data)
        if (state is BillError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<BillCubit>().loadBillDetail(widget.billId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        // Fallback empty state
        return Scaffold(
          appBar: AppBar(title: const Text('Bill Splitter')),
          body: const Center(child: Text('No bill data available.')),
        );
      },
    );
  }

  Widget _buildSplitterUI(
    BuildContext context,
    Bill bill,
    Map<String, AppUser> participants,
  ) {
    final authCubit = context.read<AuthCubit>();
    final currentUserId = authCubit.currentUserId ?? '';
    final isHost = bill.isHost(currentUserId);

    return Scaffold(
      appBar: _buildAppBar(context, bill, isHost),
      body: Column(
        children: [
          // Participants section
          ParticipantsSection(
            bill: bill,
            participants: participants,
            currentUserId: currentUserId,
            onAddParticipant: () => _showAddParticipantDialog(context),
            onRemoveParticipant: (userId, user) =>
                _showRemoveParticipantDialog(context, user, userId),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unassigned Items Section
                  ItemsSection(
                    title: 'Unassigned Items',
                    items: bill.unassignedItems,
                    participants: participants,
                    participantIds: bill.participants,
                    isHost: isHost,
                    sectionColor: AppColors.warning,
                    onQuantitySplit: (item) => _showQuantitySplitDialog(
                      context,
                      item,
                      bill,
                      participants,
                    ),
                    onItemActions: (item) => _showItemActionsSheet(
                      context,
                      item,
                      bill,
                      participants,
                      isHost,
                    ),
                    onAssignToUser: _assignToUser,
                  ),

                  // Assigned Items Section
                  ItemsSection(
                    title: 'Assigned Items',
                    items: bill.assignedItems,
                    participants: participants,
                    participantIds: bill.participants,
                    isHost: isHost,
                    sectionColor: AppColors.success,
                    onQuantitySplit: (item) => _showQuantitySplitDialog(
                      context,
                      item,
                      bill,
                      participants,
                    ),
                    onItemActions: (item) => _showItemActionsSheet(
                      context,
                      item,
                      bill,
                      participants,
                      isHost,
                    ),
                    onUnassign: _unassignItem,
                  ),

                  // Summary Section
                  SplitterSummarySection(
                    bill: bill,
                    participants: participants,
                    currentUserId: currentUserId,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Bill bill,
    bool isHost,
  ) {
    return AppBar(
      title: Text(bill.title ?? 'Bill Split', overflow: TextOverflow.ellipsis),
      actions: [
        if (isHost)
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, bill),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_title',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit Bill Name'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'add_item',
                child: ListTile(
                  leading: Icon(Icons.add_circle_outline),
                  title: Text('Add Item'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              if (bill.status == BillStatus.active)
                const PopupMenuItem(
                  value: 'close',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('Close Bill'),
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'reopen',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Reopen Bill'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action, Bill bill) {
    switch (action) {
      case 'edit_title':
        _showEditBillTitleDialog(context, bill);
        break;
      case 'add_item':
        _showAddItemDialog(context);
        break;
      case 'close':
        context.read<BillCubit>().closeBill(widget.billId);
        break;
      case 'reopen':
        context.read<BillCubit>().reopenBill(widget.billId);
        break;
      case 'delete':
        _showDeleteBillDialog(context);
        break;
    }
  }

  void _showDeleteBillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bill?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BillCubit>().deleteBill(widget.billId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
