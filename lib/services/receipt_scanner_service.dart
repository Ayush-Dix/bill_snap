import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/bill_item.dart';

/// Service for scanning receipts using Asprise Receipt OCR API
class ReceiptScannerService {
  // Asprise API configuration
  static const String _apiEndpoint = 'https://ocr.asprise.com/api/v1/receipt';
  static const String _apiKey = 'TEST';
  static const String _recognizer = 'auto';

  // Timeout configuration
  static const Duration _requestTimeout = Duration(seconds: 30);

  /// Scan an image file and extract bill items using Asprise OCR API
  Future<ScanResult> scanReceipt(File imageFile) async {
    try {
      print('\n===== ASPRISE OCR REQUEST =====');
      print('File: ${imageFile.path}');
      print('File size: ${await imageFile.length()} bytes');

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiEndpoint));

      // Add required fields
      request.fields['api_key'] = _apiKey;
      request.fields['recognizer'] = _recognizer;
      request.fields['ref_no'] =
          'billsnap_${DateTime.now().millisecondsSinceEpoch}';

      // Add image file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      print('Sending request to Asprise API...');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }

      // Parse JSON response
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

      print('===== ASPRISE API RESPONSE =====');
      print(json.encode(jsonResponse));
      print('================================\n');

      // Check if OCR was successful
      if (jsonResponse['success'] != true) {
        throw Exception('OCR processing failed');
      }

      // Extract receipts array
      final receipts = jsonResponse['receipts'] as List<dynamic>?;
      if (receipts == null || receipts.isEmpty) {
        return ScanResult(
          success: true,
          items: [],
          rawText: 'No receipts detected in image',
        );
      }

      // Parse items from all detected receipts
      final items = _parseReceipts(receipts);

      // Generate raw text summary
      final rawText = _generateRawTextSummary(receipts);

      return ScanResult(success: true, items: items, rawText: rawText);
    } on http.ClientException catch (e) {
      return ScanResult(
        success: false,
        items: [],
        rawText: '',
        error:
            'Network error: Unable to connect to OCR service. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      return ScanResult(
        success: false,
        items: [],
        rawText: '',
        error: 'Failed to parse OCR response: $e',
      );
    } on TimeoutException catch (e) {
      return ScanResult(
        success: false,
        items: [],
        rawText: '',
        error: 'OCR request timed out. Please try again.',
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

  /// Parse receipts from API response and extract bill items
  List<BillItem> _parseReceipts(List<dynamic> receipts) {
    final List<BillItem> allItems = [];

    print('\n===== PARSING RECEIPTS =====');
    print('Total receipts: ${receipts.length}');

    for (var i = 0; i < receipts.length; i++) {
      final receipt = receipts[i] as Map<String, dynamic>;
      print('\nReceipt #${i + 1}:');
      print('Merchant: ${receipt['merchant_name']}');
      print('Date: ${receipt['date']}');
      print('Total: ${receipt['total']}');

      // Extract items from this receipt
      final items = receipt['items'] as List<dynamic>?;
      if (items != null && items.isNotEmpty) {
        print('Items found: ${items.length}');

        for (var itemJson in items) {
          final item = itemJson as Map<String, dynamic>;

          // Extract item details
          final description = item['description'] as String?;
          final amount = _parseAmount(item['amount']);
          final qty = _parseInt(item['qty']) ?? 1;

          if (description != null &&
              description.isNotEmpty &&
              amount != null &&
              amount > 0) {
            // Create bill item
            final billItem = BillItem.create(
              name: _cleanItemName(description),
              price: amount,
            );
            allItems.add(billItem);

            print(
              '  ✓ ${billItem.name} - ₹${billItem.price.toStringAsFixed(2)}',
            );
          } else {
            print('  ✗ Skipped invalid item: $item');
          }
        }
      } else {
        print('No items found in this receipt');
      }
    }

    print('\nTotal items extracted: ${allItems.length}');
    print('============================\n');

    return allItems;
  }

  /// Generate a human-readable summary from receipts
  String _generateRawTextSummary(List<dynamic> receipts) {
    final buffer = StringBuffer();

    for (var i = 0; i < receipts.length; i++) {
      final receipt = receipts[i] as Map<String, dynamic>;

      if (i > 0) buffer.writeln('\n---\n');

      buffer.writeln('RECEIPT ${i + 1}');

      if (receipt['merchant_name'] != null) {
        buffer.writeln('Merchant: ${receipt['merchant_name']}');
      }
      if (receipt['merchant_address'] != null) {
        buffer.writeln('Address: ${receipt['merchant_address']}');
      }
      if (receipt['date'] != null) {
        buffer.writeln('Date: ${receipt['date']}');
      }
      if (receipt['time'] != null) {
        buffer.writeln('Time: ${receipt['time']}');
      }

      buffer.writeln();

      final items = receipt['items'] as List<dynamic>?;
      if (items != null && items.isNotEmpty) {
        buffer.writeln('ITEMS:');
        for (var item in items) {
          final itemMap = item as Map<String, dynamic>;
          final desc = itemMap['description'] ?? 'Unknown';
          final amount = itemMap['amount'] ?? 0;
          final qty = itemMap['qty'] ?? 1;
          buffer.writeln('  ${qty}x $desc - ₹${amount}');
        }
      }

      buffer.writeln();

      if (receipt['subtotal'] != null) {
        buffer.writeln('Subtotal: ₹${receipt['subtotal']}');
      }
      if (receipt['tax'] != null) {
        buffer.writeln('Tax: ₹${receipt['tax']}');
      }
      if (receipt['total'] != null) {
        buffer.writeln('Total: ₹${receipt['total']}');
      }
    }

    return buffer.toString();
  }

  /// Clean up item name
  String _cleanItemName(String name) {
    // Remove leading/trailing whitespace
    name = name.trim();

    // Capitalize first letter of each word
    name = name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');

    return name;
  }

  /// Safely parse amount from dynamic value
  double? _parseAmount(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      // Remove currency symbols and whitespace
      final cleaned = value.replaceAll(RegExp(r'[₹\$€£¥,\s]'), '');
      return double.tryParse(cleaned);
    }

    return null;
  }

  /// Safely parse integer from dynamic value
  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
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
