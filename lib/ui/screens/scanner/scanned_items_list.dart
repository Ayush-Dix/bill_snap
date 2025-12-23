import 'package:flutter/material.dart';
import '../../../models/bill_item.dart';
import '../../../cubit/cubit.dart';

/// List view showing scanned/manual items with edit/delete actions
class ScannedItemsList extends StatelessWidget {
  final List<BillItem> items;
  final String rawText;
  final ScannerCubit scannerCubit;
  final Function(BillItem) onEditItem;
  final VoidCallback? onViewRawText;
  final VoidCallback? onAddItem;

  const ScannedItemsList({
    super.key,
    required this.items,
    required this.rawText,
    required this.scannerCubit,
    required this.onEditItem,
    this.onViewRawText,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final total = items.fold(0.0, (sum, item) => sum + item.price);
    final isManualEntry = rawText.isEmpty;

    return Column(
      children: [
        _buildSummaryHeader(context, theme, isDark, total),
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState(context, theme, isDark, isManualEntry)
              : _buildItemsListView(context, theme),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                items.isEmpty
                    ? 'No items yet'
                    : '${items.length} item${items.length == 1 ? '' : 's'}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to edit, swipe to delete',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Total', style: theme.textTheme.labelSmall),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFFF8A5B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isManualEntry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isManualEntry ? Icons.add_shopping_cart : Icons.receipt_long,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isManualEntry ? 'Start adding items' : 'No items found in scan',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isManualEntry
                  ? 'Tap the + button to add your first item'
                  : 'The OCR may not have detected prices clearly',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
            if (!isManualEntry &&
                rawText.isNotEmpty &&
                onViewRawText != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onViewRawText,
                child: const Text('View OCR text'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsListView(BuildContext context, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => scannerCubit.removeItem(item.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete, color: Colors.red.shade700),
          ),
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                item.name,
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
              ),
              trailing: Text(
                '₹${item.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFFF8A5B),
                ),
              ),
              onTap: () => onEditItem(item),
            ),
          ),
        );
      },
    );
  }
}
