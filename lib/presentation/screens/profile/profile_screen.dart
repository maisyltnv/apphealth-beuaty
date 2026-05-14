import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_config.dart';
import '../../providers/auth_provider.dart';

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

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
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
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
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
                  'Android emulator ຫຼິ້ນ API ຈາກເຄື່ອງ dev: ໃຊ້ 10.0.2.2 ໂດຍອັດຕະໂນມັດ.',
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
              subtitle: const Text('ສະຖານະ: ເຂົ້າສູ່ລະບົບແລ້ວ'),
              trailing: TextButton(
                onPressed: () => context.read<AuthProvider>().logout(),
                child: const Text('ອອກ'),
              ),
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
                    Text('ເຂົ້າສູ່ລະບົບ', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _user,
                      decoration: const InputDecoration(labelText: 'ຊື່ຜູ້ໃຊ້'),
                      validator: (v) => (v == null || v.trim().length < 3) ? 'ກະລຸນາໃສ່ຊື່ຜູ້ໃຊ້' : null,
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
                      onPressed: _busy ? null : _login,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('ເຂົ້າສູ່ລະບົບ'),
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
