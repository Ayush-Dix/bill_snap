import 'package:flutter/material.dart';
import '../../../cubit/cubit.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet for selecting image source (Camera, Gallery, Manual)
class ImageSourceSheet extends StatelessWidget {
  final ScannerCubit scannerCubit;

  const ImageSourceSheet({super.key, required this.scannerCubit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGray600 : AppColors.lightGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Image Source',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.info),
              ),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo of your receipt'),
              onTap: () {
                Navigator.pop(context);
                scannerCubit.scanFromCamera();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.success,
                ),
              ),
              title: const Text('Gallery'),
              subtitle: const Text('Choose from your photos'),
              onTap: () {
                Navigator.pop(context);
                scannerCubit.scanFromGallery();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
