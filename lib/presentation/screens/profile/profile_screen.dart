import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_config.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/orders_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;
  bool _registerMode = false;

  // Admin create product (minimal fields; API computes LAK if final_price omitted)
  final _pName = TextEditingController();
  final _pDesc = TextEditingController();
  final _pImage = TextEditingController();
  final _pCat = TextEditingController();
  final _pCny = TextEditingController(text: '10');
  final _pRate = TextEditingController(text: '3500');
  final _pMargin = TextEditingController(text: '0.25');
  final _pSource = TextEditingController();
  final _adminFormKey = GlobalKey<FormState>();
  bool _adminBusy = false;
  String? _adminMsg;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    _pName.dispose();
    _pDesc.dispose();
    _pImage.dispose();
    _pCat.dispose();
    _pCny.dispose();
    _pRate.dispose();
    _pMargin.dispose();
    _pSource.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().login(_user.text.trim(), _pass.text);
      if (mounted) {
        _pass.clear();
        await context.read<OrdersProvider>().load(context.read<AuthProvider>().token);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().register(_user.text.trim(), _pass.text);
      if (mounted) {
        setState(() {
          _registerMode = false;
          _error = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ລົງທະບຽນສຳເລັດ — ກະລຸນາເຂົ້າສູ່ລະບົບ')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitAdminProduct() async {
    if (!_adminFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _adminBusy = true;
      _adminMsg = null;
    });
    try {
      final api = context.read<ApiService>();
      await api.createProduct(
        token,
        name: _pName.text.trim(),
        description: _pDesc.text.trim(),
        imageUrl: _pImage.text.trim(),
        category: _pCat.text.trim(),
        originalPriceCny: double.parse(_pCny.text.trim()),
        exchangeRate: double.parse(_pRate.text.trim()),
        profitMargin: double.parse(_pMargin.text.trim()),
        sourceUrl: _pSource.text.trim(),
      );
      if (mounted) {
        _adminMsg = 'ບັນທຶກສິນຄ້າສຳເລັດ';
        await context.read<CatalogProvider>().load();
      }
    } catch (e) {
      setState(() => _adminMsg = e.toString());
    } finally {
      if (mounted) setState(() => _adminBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (!auth.isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ການເຊື່ອມຕໍ່', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SelectableText('Base URL: ${ApiConfig.baseUrl}', style: text.bodySmall),
                const SizedBox(height: 6),
                Text(
                  'ເວັບ ແລະ iOS/desktop: localhost. Android emulator: 10.0.2.2. ໂທລະສັບຈິງ: --dart-define=API_BASE=...',
                  style: text.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (auth.isSignedIn) ...[
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.person, color: scheme.onPrimaryContainer),
              ),
              title: Text(auth.username ?? ''),
              subtitle: Text('ບົດບາດ: ${auth.role ?? '—'}'),
              trailing: TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    await context.read<OrdersProvider>().load(null);
                  }
                },
                child: const Text('ອອກ'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                try {
                  await context.read<AuthProvider>().refreshProfile();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ອັບເດດໂປຣໄຟລ໌ຈາກ API ສຳເລັດ')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              icon: const Icon(Icons.sync, size: 18),
              label: const Text('ໂຫຼດ /auth/me ຄືນໃໝ່'),
            ),
          ),
        ] else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(value: false, label: Text('ເຂົ້າສູ່ລະບົບ')),
                        ButtonSegment<bool>(value: true, label: Text('ລົງທະບຽນ')),
                      ],
                      selected: {_registerMode},
                      onSelectionChanged: (Set<bool> next) {
                        setState(() {
                          _registerMode = next.first;
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _registerMode ? 'ລົງທະບຽນ' : 'ເຂົ້າສູ່ລະບົບ',
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _user,
                      decoration: const InputDecoration(labelText: 'ຊື່ຜູ້ໃຊ້'),
                      validator: (v) => (v == null || v.trim().length < 3) ? 'ກະລຸນາໃສ່ຊື່ຜູ້ໃຊ້ (≥3)' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pass,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'ລະຫັດ'),
                      validator: (v) => (v == null || v.length < 8) ? 'ລະຫັດຕ້ອງຍາວຢ່າງໜ້ອຍ 8 ຕົວ' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: text.bodySmall?.copyWith(color: scheme.error)),
                    ],
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : (_registerMode ? _register : _login),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_registerMode ? 'ລົງທະບຽນ' : 'ເຂົ້າສູ່ລະບົບ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (auth.isSignedIn && auth.isAdmin) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _adminFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ເພີ່ມສິນຄ້າ (Admin)',
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pName,
                      decoration: const InputDecoration(labelText: 'ຊື່ *', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'ຈຳເປັນ' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pDesc,
                      decoration: const InputDecoration(labelText: 'ລາຍລະອຽດ', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pImage,
                      decoration: const InputDecoration(labelText: 'image_url', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pCat,
                      decoration: const InputDecoration(labelText: 'ຫມວດ', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pCny,
                      decoration: const InputDecoration(labelText: 'ລາຄາຕົ້ນທຶນ CNY *', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => double.tryParse(v?.trim() ?? '') == null ? 'ຕົວເລກ' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pRate,
                      decoration: const InputDecoration(labelText: 'ອັດຕາແລກປ່ຽນ *', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => double.tryParse(v?.trim() ?? '') == null ? 'ຕົວເລກ' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pMargin,
                      decoration: const InputDecoration(labelText: 'ກຳໄລ (0.25 = 25%) *', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => double.tryParse(v?.trim() ?? '') == null ? 'ຕົວເລກ' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pSource,
                      decoration: const InputDecoration(labelText: 'source_url', border: OutlineInputBorder()),
                    ),
                    if (_adminMsg != null) ...[
                      const SizedBox(height: 10),
                      Text(_adminMsg!, style: text.bodySmall?.copyWith(color: scheme.primary)),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _adminBusy ? null : _submitAdminProduct,
                      child: _adminBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('POST /products'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
