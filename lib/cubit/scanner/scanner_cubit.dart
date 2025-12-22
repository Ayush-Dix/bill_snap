import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../models/bill_item.dart';
import '../../services/receipt_scanner_service.dart';
import 'scanner_state.dart';

/// Cubit for managing receipt scanning
class ScannerCubit extends Cubit<ScannerState> {
  final ReceiptScannerService _scannerService;
  final ImagePicker _imagePicker;

  ScannerCubit({
    ReceiptScannerService? scannerService,
    ImagePicker? imagePicker,
  }) : _scannerService = scannerService ?? ReceiptScannerService(),
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const ScannerInitial());

  /// Pick image from camera and scan
  Future<void> scanFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // Max quality for OCR
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile == null) {
        return; // User cancelled
      }

      final imageFile = File(pickedFile.path);

      // Try to crop, but proceed with original if cropping fails
      try {
        final croppedFile = await _cropImage(imageFile);
        if (croppedFile == null) {
          // User cancelled cropping
          return;
        }
        await _processImage(croppedFile);
      } catch (cropError) {
        // If cropping fails, just use the original image
        print('Cropping failed, using original image: $cropError');
        await _processImage(imageFile);
      }
    } catch (e) {
      emit(ScannerError('Failed to capture image: $e'));
    }
  }

  /// Pick image from gallery and scan
  Future<void> scanFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Max quality for OCR
      );

      if (pickedFile == null) {
        return; // User cancelled
      }

      final imageFile = File(pickedFile.path);

      // Try to crop, but proceed with original if cropping fails
      try {
        final croppedFile = await _cropImage(imageFile);
        if (croppedFile == null) {
          // User cancelled cropping
          return;
        }
        await _processImage(croppedFile);
      } catch (cropError) {
        // If cropping fails, just use the original image
        print('Cropping failed, using original image: $cropError');
        await _processImage(imageFile);
      }
    } catch (e) {
      emit(ScannerError('Failed to pick image: $e'));
    }
  }

  /// Crop the image to focus on receipt area
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Receipt',
            toolbarColor: const Color(0xFFFF6B35), // Burnt Orange
            toolbarWidgetColor: Colors.white,
            backgroundColor: const Color(0xFF121212),
            dimmedLayerColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            statusBarColor: const Color(0xFFFF6B35),
            activeControlsWidgetColor: const Color(0xFFD4E157), // Lime accent
            cropFrameColor: const Color(0xFFFF6B35),
            cropGridColor: Colors.white54,
          ),
          IOSUiSettings(
            title: 'Crop Receipt',
            minimumAspectRatio: 0.5,
            hidesNavigationBar: false,
            rectX: 1,
            rectY: 1,
            rectWidth: 1,
            rectHeight: 1,
          ),
        ],
        compressQuality: 100,
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null; // User cancelled cropping
    } catch (e) {
      return imageFile; // If cropping fails, use original image
    }
  }

  /// Process the image with ML Kit OCR
  Future<void> _processImage(File imageFile) async {
    emit(const ScannerScanning());

    final result = await _scannerService.scanReceipt(imageFile);

    if (result.success) {
      emit(
        ScannerSuccess(
          items: result.items,
          rawText: result.rawText,
          imageFile: imageFile,
        ),
      );
    } else {
      emit(ScannerError(result.error ?? 'Failed to scan receipt'));
    }
  }

  /// Add a new item manually
  void addItem(String name, double price) {
    final currentState = state;
    List<BillItem> items = [];
    File? imageFile;

    if (currentState is ScannerSuccess) {
      items = List.from(currentState.items);
      imageFile = currentState.imageFile;
    } else if (currentState is ScannerEditing) {
      items = List.from(currentState.items);
      imageFile = currentState.imageFile;
    }

    items.add(BillItem.create(name: name, price: price));
    emit(ScannerEditing(items: items, imageFile: imageFile));
  }

  /// Update an existing item
  void updateItem(String itemId, {String? name, double? price}) {
    final currentState = state;
    List<BillItem> items = [];
    File? imageFile;

    if (currentState is ScannerSuccess) {
      items = List.from(currentState.items);
      imageFile = currentState.imageFile;
    } else if (currentState is ScannerEditing) {
      items = List.from(currentState.items);
      imageFile = currentState.imageFile;
    } else {
      return;
    }

    final updatedItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          name: name ?? item.name,
          price: price ?? item.price,
        );
      }
      return item;
    }).toList();

    emit(ScannerEditing(items: updatedItems, imageFile: imageFile));
  }

  /// Remove an item
  void removeItem(String itemId) {
    final currentState = state;
    List<BillItem> items = [];
    File? imageFile;

    if (currentState is ScannerSuccess) {
      items = List.from(currentState.items);
      imageFile = currentState.imageFile;
    } else if (currentState is ScannerEditing) {
      items = List.from(currentState.items);
      imageFile = currentState.imageFile;
    } else {
      return;
    }

    items.removeWhere((item) => item.id == itemId);
    emit(ScannerEditing(items: items, imageFile: imageFile));
  }

  /// Get current items list
  List<BillItem> get currentItems {
    final currentState = state;
    if (currentState is ScannerSuccess) {
      return currentState.items;
    } else if (currentState is ScannerEditing) {
      return currentState.items;
    }
    return [];
  }

  /// Start manual bill creation (no receipt scanning)
  void startManualEntry() {
    emit(const ScannerEditing(items: [], imageFile: null));
  }

  /// Reset scanner to initial state
  void reset() {
    emit(const ScannerInitial());
  }

  @override
  Future<void> close() {
    _scannerService.dispose();
    return super.close();
  }
}
