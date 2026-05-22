import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/lak_currency_formatter.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/shipping_quote_entity.dart';
import '../../widgets/product_image.dart';

/// Web-style LAK: `1.560.000 ₭`
String formatLakWeb(num amount) {
  final core = LakCurrencyFormatter.format(amount, showSymbol: false).replaceAll(',', '.');
  return '$core ₭';
}

class CheckoutStepIndicator extends StatelessWidget {
  const CheckoutStepIndicator({super.key, required this.currentStep});

  final int currentStep;

  static const _steps = [
    (id: 1, label: 'ທີ່ຢູ່ຈັດສົ່ງ', icon: Icons.local_shipping_outlined),
    (id: 2, label: 'ການຊຳລະເງິນ', icon: Icons.credit_card_outlined),
    (id: 3, label: 'ຢືນຢັນຄຳສັ່ງ', icon: Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _steps.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: currentStep > i ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            _StepDot(
              step: _steps[i],
              active: currentStep >= _steps[i].id,
              completed: currentStep > _steps[i].id,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.step, required this.active, required this.completed});

  final ({int id, String label, IconData icon}) step;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check_rounded : step.icon,
            size: 20,
            color: active ? Colors.white : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            step.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.notoSansLao(fontSize: 10, fontWeight: FontWeight.w600, color: color, height: 1.2),
          ),
        ),
      ],
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.subtotalLak,
    required this.shippingFeeLak,
    required this.totalLak,
    this.quote,
    this.quoteLoading = false,
  });

  final List<CartItemEntity> items;
  final double subtotalLak;
  final double shippingFeeLak;
  final double totalLak;
  final ShippingQuoteEntity? quote;
  final bool quoteLoading;

  @override
  Widget build(BuildContext context) {
    final freeShipping = quote?.freeShippingApplied ?? shippingFeeLak == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ສະຫຼຸບຄຳສັ່ງຊື້',
            style: GoogleFonts.notoSansLao(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...items.map(_SummaryLineItem.new),
          const Divider(height: AppSpacing.xl),
          _priceRow('ລວມສິນຄ້າ', formatLakWeb(subtotalLak)),
          const SizedBox(height: AppSpacing.sm),
          _priceRow(
            'ຄ່າຈັດສົ່ງ',
            quoteLoading
                ? '...'
                : freeShipping
                    ? 'ຟຣີ'
                    : formatLakWeb(shippingFeeLak),
            valueColor: freeShipping ? AppColors.primary : null,
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ລວມທັງໝົດ', style: GoogleFonts.notoSansLao(fontSize: 16, fontWeight: FontWeight.w800)),
              Text(
                formatLakWeb(totalLak),
                style: GoogleFonts.notoSansLao(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (freeShipping) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'ຮັບການຈັດສົ່ງຟຣີແລ້ວ',
                style: GoogleFonts.notoSansLao(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ] else if (quote?.amountUntilFreeShippingLak != null && quote!.amountUntilFreeShippingLak! > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                quoteLoading
                    ? 'ກຳລັງຄິດຄ່າສົ່ງ...'
                    : 'ຊື້ເພີ່ມອີກ ${formatLakWeb(quote!.amountUntilFreeShippingLak!)} ເພື່ອຮັບການຈັດສົ່ງຟຣີ',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansLao(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.notoSansLao(fontSize: 14, color: AppColors.textSecondary)),
        Text(
          value,
          style: GoogleFonts.notoSansLao(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryLineItem extends StatelessWidget {
  const _SummaryLineItem(this.item);

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: ProductImage(
                  imageUrl: item.product.imageUrl,
                  aspectRatio: 1,
                  borderRadius: AppSpacing.radiusSm,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.notoSansLao(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatLakWeb(item.lineTotalLak),
            style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class CheckoutLabeledField extends StatelessWidget {
  const CheckoutLabeledField({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class CheckoutReviewCard extends StatelessWidget {
  const CheckoutReviewCard({
    super.key,
    required this.title,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: GoogleFonts.notoSansLao(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('ແກ້ໄຂ', style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.selected,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.notoSansLao(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutNavButtons extends StatelessWidget {
  const CheckoutNavButtons({
    super.key,
    this.showBack = true,
    required this.onBack,
    required this.onContinue,
    this.continueLabel = 'ດຳເນີນການຕໍ່',
    this.continueLoading = false,
    this.continueEnabled = true,
  });

  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool continueLoading;
  final bool continueEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: continueLoading ? null : onBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              ),
              child: Text('ກັບຄືນ', style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          flex: showBack ? 1 : 1,
          child: FilledButton(
            onPressed: continueLoading || !continueEnabled ? null : onContinue,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            ),
            child: continueLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(continueLabel, style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
