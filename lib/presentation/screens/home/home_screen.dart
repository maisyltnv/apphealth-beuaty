import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/lak_currency_formatter.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/catalog_provider.dart';
import '../scan/qr_scan_screen.dart';

/// Store home: horizontal categories and a vertical product grid fed by the Go API.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        if (catalog.isLoading && catalog.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (catalog.error != null && catalog.products.isEmpty) {
          return _ErrorState(
            message: catalog.error!,
            onRetry: () => catalog.load(),
          );
        }

        return RefreshIndicator(
          onRefresh: catalog.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'ສິນຄ້າແນະນຳ',
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const QrScanScreen()),
                        ),
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                        label: const Text('ສະແກນ QR'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: catalog.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final label = catalog.categories[i];
                      final selected = (catalog.selectedCategory == null && label == 'ທັງໝົດ') ||
                          catalog.selectedCategory == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) => catalog.selectCategory(label),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (catalog.visibleProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'ບໍ່ມີສິນຄ້າໃນຫມວດນີ້',
                      style: text.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = catalog.visibleProducts[index];
                        return _ProductCard(product: p);
                      },
                      childCount: catalog.visibleProducts.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: scheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(Icons.image_not_supported_outlined, color: scheme.outline),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          color: scheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: Icon(Icons.spa_outlined, color: scheme.primary),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                LakCurrencyFormatter.format(product.finalPriceLak),
                style: text.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Icon(Icons.cloud_off_outlined, size: 56, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text(
          'ບໍ່ສາມາດເຊື່ອມ API ໄດ້',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('ລອງໃໝ່'),
          ),
        ),
      ],
    );
  }
}
