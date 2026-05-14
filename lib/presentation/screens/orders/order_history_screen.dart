import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/lak_currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String? _lastToken;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrdersProvider>();

    final token = auth.token;
    if (token != _lastToken) {
      _lastToken = token;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<OrdersProvider>().load(token);
      });
    }

    if (!auth.isSignedIn) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 32),
          Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'ເຂົ້າສູ່ລະບົບເພື່ອເບິ່ງປະຫວັດຄຳສັ່ງຊື້',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );
    }

    if (orders.isLoading && orders.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<OrdersProvider>().load(auth.token),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            Icon(Icons.receipt_long, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'ຍັງບໍ່ມີຄຳສັ່ງຊື້ — ຫຼື API ຍັງບໍ່ມີ GET /orders',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<OrdersProvider>().load(auth.token),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: orders.orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final o = orders.orders[i];
          return Card(
            child: ListTile(
              title: Text('ຄຳສັ່ງຊື້ #${o.id}'),
              subtitle: Text(o.status),
              trailing: Text(
                LakCurrencyFormatter.format(o.totalAmountLak),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }
}
