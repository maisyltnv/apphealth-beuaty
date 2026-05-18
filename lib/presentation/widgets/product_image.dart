import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 1,
    this.borderRadius = AppSpacing.radiusMd,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double aspectRatio;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: fit,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.surfaceMuted,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.primary.withValues(alpha: 0.12),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.spa_rounded, size: 36, color: AppColors.primary.withValues(alpha: 0.5)),
    );
  }
}
