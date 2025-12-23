import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/cubit.dart';
import '../../models/bill_item.dart';
import 'scanner/image_source_sheet.dart';
import 'scanner/scanner_initial_view.dart';
import 'scanner/scanned_items_list.dart';
import 'scanner/scanner_item_dialog.dart';

/// Screen for scanning and editing receipt items
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late ScannerCubit _scannerCubit;

  @override
  void initState() {
    super.initState();
    _scannerCubit = ScannerCubit();
  }

  @override
  void dispose() {
    _scannerCubit.close();
    super.dispose();
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImageSourceSheet(scannerCubit: _scannerCubit),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => ScannerItemDialog(scannerCubit: _scannerCubit),
    );
  }

  void _showEditItemDialog(BillItem item) {
    showDialog(
      context: context,
      builder: (context) =>
          ScannerItemDialog(scannerCubit: _scannerCubit, item: item),
    );
  }

  void _showRawTextDialog(String rawText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OCR Detected Text'),
        content: SingleChildScrollView(
          child: SelectableText(
            rawText.isEmpty ? 'No text detected' : rawText,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _createBill(List<BillItem> items) async {
    final billCubit = context.read<BillCubit>();

    final billId = await billCubit.createBill(
      items: items,
      title: 'Bill ${DateTime.now().day}/${DateTime.now().month}',
    );

    if (billId != null && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scannerCubit,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ScannerCubit, ScannerState>(
            builder: (context, state) {
              if (state is ScannerEditing || state is ScannerSuccess) {
                return const Text('Create Bill');
              }
              return const Text('Scan Receipt');
            },
          ),
          actions: [
            BlocBuilder<ScannerCubit, ScannerState>(
              builder: (context, state) {
                final hasItems =
                    state is ScannerSuccess && state.items.isNotEmpty ||
                    state is ScannerEditing && state.items.isNotEmpty;

                if (!hasItems) return const SizedBox();

                return TextButton(
                  onPressed: () => _createBill(_scannerCubit.currentItems),
                  child: const Text('Create Bill'),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ScannerCubit, ScannerState>(
          builder: (context, state) {
            if (state is ScannerInitial) {
              return ScannerInitialView(
                scannerCubit: _scannerCubit,
                onScanTap: _showImageSourceDialog,
              );
            }

            if (state is ScannerScanning) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text('Scanning receipt...'),
                    SizedBox(height: 8),
                    Text(
                      'This may take a moment',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (state is ScannerError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showImageSourceDialog,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ScannerSuccess || state is ScannerEditing) {
              final items = state is ScannerSuccess
                  ? state.items
                  : (state as ScannerEditing).items;
              final rawText = state is ScannerSuccess ? state.rawText : '';

              return ScannedItemsList(
                items: items,
                rawText: rawText,
                scannerCubit: _scannerCubit,
                onEditItem: _showEditItemDialog,
                onViewRawText: () => _showRawTextDialog(rawText),
                onAddItem: _showAddItemDialog,
              );
            }

            return ScannerInitialView(
              scannerCubit: _scannerCubit,
              onScanTap: _showImageSourceDialog,
            );
          },
        ),
        floatingActionButton: BlocBuilder<ScannerCubit, ScannerState>(
          builder: (context, state) {
            if (state is ScannerSuccess || state is ScannerEditing) {
              return FloatingActionButton(
                onPressed: _showAddItemDialog,
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
