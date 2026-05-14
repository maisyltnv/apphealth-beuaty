import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/lak_currency_formatter.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/orders_provider.dart';

/// Product detail + authenticated checkout via `POST /orders`.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initial,
  });

  final int productId;
  final ProductEntity? initial;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductEntity? _product;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _product = widget.initial;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final catalog = context.read<CatalogProvider>();
    final p = await catalog.fetchProductById(widget.productId);
    if (!mounted) return;
    if (p != null) {
      setState(() {
        _product = p;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _loadError = 'ໂຫຼດສິນຄ້າບໍ່ສຳເລັດ';
      });
    }
  }

  Future<void> _openCheckout() async {
    final product = _product;
    if (product == null) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn || auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາເຂົ້າສູ່ລະບົບກ່ອນສັ່ງຊື້')),
      );
      return;
    }

    final amountCtrl = TextEditingController(text: product.finalPriceLak.toStringAsFixed(0));
    final receiptCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('ສັ່ງຊື້'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(product.name, style: Theme.of(ctx).textTheme.titleSmall),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ຍອດລວມ (LAK)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: receiptCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL ຫຼັກຖານຊຳລະ (ບໍ່ບັງຄັບ)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ຍົກເລີກ')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ຢືນຢັນ')),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    final lak = double.tryParse(amountCtrl.text.replaceAll(',', '').trim());
    if (lak == null || lak < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ຍອດເງິນບໍ່ຖືກຕ້ອງ')),
      );
      return;
    }

    final orders = context.read<OrdersProvider>();
    final created = await orders.placeOrder(
      auth.token!,
      totalAmountLak: lak,
      paymentReceiptUrl: receiptCtrl.text.trim(),
    );

    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ສັ່ງຊື້ສຳເລັດ #${created.id}')),
      );
      Navigator.of(context).pop();
    } else {
      final msg = orders.error ?? 'ສັ່ງຊື້ບໍ່ສຳເລັດ';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (_loading && _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ສິນຄ້າ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ສິນຄ້າ')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError ?? 'ບໍ່ພົບສິນຄ້າ'),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('ລອງໃໝ່')),
            ],
          ),
        ),
      );
    }

    final p = _product!;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: scheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_not_supported_outlined, color: scheme.outline),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.spa_outlined, size: 48, color: scheme.primary),
            ),
          const SizedBox(height: 16),
          Text(
            LakCurrencyFormatter.format(p.finalPriceLak),
            style: text.headlineSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(p.category, style: text.labelLarge?.copyWith(color: scheme.outline)),
          const SizedBox(height: 12),
          Text(p.description.isNotEmpty ? p.description : '—', style: text.bodyLarge),
          if (p.sourceUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText('ແຫຼ່ງ: ${p.sourceUrl}', style: text.bodySmall),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _openCheckout,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('ສັ່ງຊື້'),
          ),
        ],
      ),
    );
  }
}
