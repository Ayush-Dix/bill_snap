import 'package:flutter/material.dart';
import '../../../cubit/cubit.dart';

/// Initial state view with scan/manual options and tips
class ScannerInitialView extends StatelessWidget {
  final ScannerCubit scannerCubit;
  final VoidCallback onScanTap;

  const ScannerInitialView({
    super.key,
    required this.scannerCubit,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
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
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Create a New Bill',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a receipt or add items manually',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildTipsContainer(theme, isDark),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onScanTap,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Receipt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => scannerCubit.startManualEntry(),
              icon: const Icon(Icons.edit_note),
              label: const Text('Create Manually'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsContainer(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.shade900.withOpacity(0.3)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.blue.shade700.withOpacity(0.5)
              : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                size: 16,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips for better scanning:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTip('Ensure good lighting', theme, isDark),
          _buildTip('Keep receipt flat and straight', theme, isDark),
          _buildTip('Focus on item names and prices', theme, isDark),
          _buildTip('You can always edit items manually', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildTip(String text, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: isDark
                    ? const Color.fromARGB(255, 49, 122, 232)
                    : const Color.fromARGB(255, 6, 76, 134),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
