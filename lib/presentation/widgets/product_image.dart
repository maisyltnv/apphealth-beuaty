import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/product_image_url_resolver.dart';

class ProductImage extends StatefulWidget {
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
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  String? _resolvedUrl;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(ProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    final raw = widget.imageUrl.trim();
    if (raw.isEmpty) {
      setState(() {
        _resolvedUrl = '';
        _resolving = false;
      });
      return;
    }

    if (ProductImageUrlResolver.isDirectImageUrl(raw)) {
      setState(() {
        _resolvedUrl = raw;
        _resolving = false;
      });
      return;
    }

    setState(() => _resolving = true);
    final resolved = await ProductImageUrlResolver.shared.resolve(raw);
    if (!mounted) return;
    setState(() {
      _resolvedUrl = resolved;
      _resolving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_resolving) {
      return Container(
        color: AppColors.surfaceMuted,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    final url = _resolvedUrl ?? '';
    if (url.isEmpty || !ProductImageUrlResolver.isDirectImageUrl(url)) {
      return _placeholder();
    }

    return Image.network(
      url,
      fit: widget.fit,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.surfaceMuted,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
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
