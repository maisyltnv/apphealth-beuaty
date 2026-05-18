import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/promo_banner.dart';
import '../scan/qr_scan_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductEntity> _filter(List<ProductEntity> products) {
    if (_query.isEmpty) return products;
    final q = _query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        if (catalog.isLoading && catalog.products.isEmpty) {
          return const _HomeLoading();
        }

        if (catalog.error != null && catalog.products.isEmpty) {
          return EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'ບໍ່ສາມາດເຊື່ອມ API',
            subtitle: catalog.error,
            actionLabel: 'ລອງໃໝ່',
            onAction: catalog.load,
          );
        }

        final products = _filter(catalog.visibleProducts);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: catalog.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader(searchCtrl: _searchCtrl, onSearchChanged: (v) => setState(() => _query = v))),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              const SliverToBoxAdapter(child: PromoBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Text(
                        'ຫມວດສິນຄ້າ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const QrScanScreen()),
                        ),
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                        label: const Text('ສະແກນ'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    scrollDirection: Axis.horizontal,
                    itemCount: catalog.categoryChips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final chip = catalog.categoryChips[i];
                      final selected = catalog.selectedCategoryId == chip.id;
                      return FilterChip(
                        label: Text(chip.label),
                        selected: selected,
                        showCheckmark: true,
                        onSelected: (_) => catalog.selectCategory(chip.id),
                        selectedColor: AppColors.primary,
                        labelStyle: GoogleFonts.notoSansLao(
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                        backgroundColor: AppColors.surface,
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
                  child: Text(
                    'ສິນຄ້າແນະນຳ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'ບໍ່ພົບສິນຄ້າ',
                    subtitle: 'ລອງເລືອກຫມວດອື່ນ ຫຼື ຄົ້ນຫາໃໝ່',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = products[index];
                        return ProductCard(
                          product: p,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductDetailScreen(productId: p.id, initial: p),
                            ),
                          ),
                          onAddToCart: () {
                            context.read<CartProvider>().add(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ເພີ່ມ "${p.name}" ໃສ່ກະເປົາແລ້ວ'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                      childCount: products.length,
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

class _HomeHeader extends StatefulWidget {
  const _HomeHeader({required this.searchCtrl, required this.onSearchChanged});

  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearchChanged;

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> {
  @override
  void initState() {
    super.initState();
    widget.searchCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.searchCtrl.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = widget.searchCtrl;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: const Icon(Icons.spa_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ສະບາຍດີ 👋',
                        style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        'Lao Beauty & Health',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: searchCtrl,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ຄົ້ນຫາສິນຄ້າ, ຫມວດ...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          searchCtrl.clear();
                          widget.onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 60),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.62,
          ),
          itemCount: 4,
          itemBuilder: (context, i) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ],
    );
  }
}
