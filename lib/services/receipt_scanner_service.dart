import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/bill_item.dart';

/// Service for scanning receipts and extracting items using ML Kit OCR
class ReceiptScannerService {
  final TextRecognizer _textRecognizer;

  ReceiptScannerService()
    : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Scan an image file and extract bill items
  Future<ScanResult> scanReceipt(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      print('\n===== RAW OCR OUTPUT =====');
      print(recognizedText.text);
      print('===== END RAW OUTPUT =====\n');

      // Parse the recognized text into bill items
      final items = _parseReceiptText(recognizedText.text);

      return ScanResult(
        success: true,
        items: items,
        rawText: recognizedText.text,
      );
    } catch (e) {
      return ScanResult(
        success: false,
        items: [],
        rawText: '',
        error: 'Failed to scan receipt: $e',
      );
    }
  }

  /// Parse receipt text into bill items
  /// This uses heuristics to identify item names and prices
  List<BillItem> _parseReceiptText(String text) {
    final List<BillItem> items = [];
    final lines = text.split('\n');

    // Regular expression patterns for price detection
    // Very flexible: matches integers and decimals in various formats
    final pricePattern = RegExp(
      r'[\$€£¥₹]?\s*(\d{1,4}(?:[.,]\d{1,2})?)(?:\s*[\$€£¥₹])?',
      caseSensitive: false,
    );

    // Pattern to identify lines that are likely totals/subtotals (to exclude)
    final excludePattern = RegExp(
      r'(^total|^subtotal|^sub-total|^tax|^vat|^tip|^service|^change|^cash|^card|visa|mastercard|payment|balance|^due|tendered|receipt\s*#|thank\s*you|www|http|tel:|phone:|\d{2}[/:]\d{2}[/:]\d{2,4}|barcode|upc)',
      caseSensitive: false,
    );

    print('===== OCR PARSING DEBUG =====');
    print('Total lines: ${lines.length}');

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Skip empty lines
      if (trimmedLine.isEmpty) continue;

      print('Processing: "$trimmedLine"');

      // Skip lines that look like totals, headers, or metadata
      if (excludePattern.hasMatch(trimmedLine)) {
        print('  → Excluded (metadata/total)');
        continue;
      }

      // Try to extract price from the line
      final priceMatches = pricePattern.allMatches(trimmedLine).toList();

      if (priceMatches.isNotEmpty) {
        // Use the last price match on the line (usually the item price)
        final priceMatch = priceMatches.last;

        // Extract the price value
        String priceStr = priceMatch.group(1) ?? '0';
        // Normalize comma to decimal point
        priceStr = priceStr.replaceAll(',', '.');
        final price = double.tryParse(priceStr);

        print('  → Found price: $price');

        if (price != null && price > 0.10 && price < 10000) {
          // Extract item name (everything before the last price)
          String itemName = trimmedLine.substring(0, priceMatch.start).trim();

          // Clean up the item name
          itemName = _cleanItemName(itemName);

          print('  → Cleaned name: "$itemName"');

          // Only add if we have a valid name (at least 2 characters)
          // Or if no name, use a generic placeholder
          if (itemName.length >= 2) {
            items.add(BillItem.create(name: itemName, price: price));
            print('  → ADDED ✓');
          } else if (itemName.isEmpty) {
            // Add with generic name so user can edit
            items.add(
              BillItem.create(name: 'Item ${items.length + 1}', price: price),
            );
            print('  → ADDED with generic name ✓');
          } else {
            print('  → Name too short');
          }
        } else {
          print('  → Price out of range');
        }
      } else {
        print('  → No price found');
      }
    }

    print('Total items extracted: ${items.length}');
    print('=============================');

    return items;
  }

  /// Clean up extracted item names
  String _cleanItemName(String name) {
    // Remove quantity prefixes (e.g., "2x", "3 x", "2 @")
    name = name.replaceAll(RegExp(r'^\d+\s*[x@]\s*', caseSensitive: false), '');

    // Remove leading/trailing special characters
    name = name.replaceAll(RegExp(r'^[\s\*\-\#\.\,]+'), '');
    name = name.replaceAll(RegExp(r'[\s\*\-\#\.\,]+$'), '');

    // Remove multiple spaces
    name = name.replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize first letter of each word
    name = name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');

    return name.trim();
  }

  /// Dispose the text recognizer when done
  void dispose() {
    _textRecognizer.close();
  }
}

/// Result of a receipt scan operation
class ScanResult {
  final bool success;
  final List<BillItem> items;
  final String rawText;
  final String? error;

  const ScanResult({
    required this.success,
    required this.items,
    required this.rawText,
    this.error,
  });

  /// Total amount from all items
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.price);

  /// Number of items found
  int get itemCount => items.length;
}
