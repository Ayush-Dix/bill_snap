import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../models/bill_item.dart';

/// States for receipt scanning
abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

/// Initial state - ready to scan
class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

/// Scanning in progress
class ScannerScanning extends ScannerState {
  const ScannerScanning();
}

/// Scan completed successfully
class ScannerSuccess extends ScannerState {
  final List<BillItem> items;
  final String rawText;
  final File? imageFile;

  const ScannerSuccess({
    required this.items,
    required this.rawText,
    this.imageFile,
  });

  @override
  List<Object?> get props => [items, rawText, imageFile];
}

/// Items edited after scan
class ScannerEditing extends ScannerState {
  final List<BillItem> items;
  final File? imageFile;

  const ScannerEditing({required this.items, this.imageFile});

  @override
  List<Object?> get props => [items, imageFile];
}

/// Scan failed
class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
