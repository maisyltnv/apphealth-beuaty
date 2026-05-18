import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/lao_provinces.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/lak_currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _receiptUrl = TextEditingController();
  String? _selectedProvince;
  String _paymentMethod = 'cod';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final orders = context.read<OrdersProvider>();
      final cart = context.read<CartProvider>();
      await orders.loadSavedPhone();
      if (!mounted) return;
      if (orders.phone != null) {
        _phone.text = orders.phone!;
      }
      await orders.refreshShippingQuote(cart.subtotalLak);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _receiptUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    setState(() => _busy = true);
    final orders = context.read<OrdersProvider>();
    final created = await orders.checkout(
      cartItems: cart.items,
      recipientName: _name.text.trim(),
      phone: _phone.text.trim(),
      province: _selectedProvince!,
      addressDetail: _address.text.trim(),
      paymentMethod: _paymentMethod,
      paymentReceiptUrl: _receiptUrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (created != null) {
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ສັ່ງຊື້ສຳເລັດ ${created.orderNumber}')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error ?? 'ສັ່ງຊື້ບໍ່ສຳເລັດ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrdersProvider>();
    final quote = orders.shippingQuote;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ຊຳລະເງິນ'),
        backgroundColor: AppColors.background,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (quote != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _summaryRow('ຍອດສິນຄ້າ', LakCurrencyFormatter.format(quote.subtotalLak), light: true),
                    _summaryRow('ຄ່າຈັດສົ່ງ', LakCurrencyFormatter.format(quote.shippingFeeLak), light: true),
                    const Divider(color: Colors.white24, height: 24),
                    _summaryRow('ລວມທັງໝົດ', LakCurrencyFormatter.format(quote.totalAmountLak), light: true, bold: true),
                    if (!quote.freeShippingApplied && quote.amountUntilFreeShippingLak != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'ສັ່ງເພີ່ມອີກ ${LakCurrencyFormatter.format(quote.amountUntilFreeShippingLak!)} ເພື່ອບໍ່ເສຍຄ່າຈັດສົ່ງ',
                        style: GoogleFonts.notoSansLao(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            _sectionTitle('ຂໍ້ມູນຈັດສົ່ງ'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'ຊື່ຜູ້ຮັບ *'), validator: _required),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'ເບີໂທ *'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 8) ? 'ເບີໂທບໍ່ຖືກຕ້ອງ' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedProvince),
              initialValue: _selectedProvince,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'ແຂວງ *',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              hint: Text('ເລືອກແຂວງ', style: GoogleFonts.notoSansLao(color: AppColors.textMuted)),
              items: LaoProvinces.all
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p, style: GoogleFonts.notoSansLao(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedProvince = v),
              validator: (v) => (v == null || v.isEmpty) ? 'ກະລຸນາເລືອກແຂວງ' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'ທີ່ຢູ່ລະອຽດ *',
                hintText: 'ບ້ານ, ເມືອງ, ຈຸດສັງເກດ',
              ),
              maxLines: 2,
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle('ວິທີຊຳລະ'),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _PaymentOption(
                  selected: _paymentMethod == 'cod',
                  icon: Icons.payments_outlined,
                  label: 'ເກັບປາຍທາງ',
                  onTap: () => setState(() => _paymentMethod = 'cod'),
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _PaymentOption(
                  selected: _paymentMethod == 'bcel_qr',
                  icon: Icons.qr_code_2_rounded,
                  label: 'BCEL QR',
                  onTap: () => setState(() => _paymentMethod = 'bcel_qr'),
                )),
              ],
            ),
            if (_paymentMethod == 'bcel_qr') ...[
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _receiptUrl,
                decoration: const InputDecoration(labelText: 'URL ຫຼັກຖານຊຳລະ (ບໍ່ບັງຄັບ)'),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _busy
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      'ຢືນຢັນຊຳລະ (${cart.itemCount} ລາຍການ)',
                      style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'ກະລຸນາໃສ່ຂໍ້ມູນ' : null;

  Widget _sectionTitle(String text) {
    return Text(text, style: GoogleFonts.notoSansLao(fontSize: 16, fontWeight: FontWeight.w700));
  }

  Widget _summaryRow(String label, String value, {bool light = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.notoSansLao(color: light ? Colors.white70 : AppColors.textSecondary)),
          Text(
            value,
            style: GoogleFonts.notoSansLao(
              color: light ? Colors.white : AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansLao(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
