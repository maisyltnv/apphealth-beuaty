import 'package:flutter/material.dart';

import '../chat/ai_health_chat_screen.dart';
import '../home/home_screen.dart';
import '../orders/order_history_screen.dart';
import '../profile/profile_screen.dart';
import '../scan/qr_scan_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = [
    'Lao Beauty & Health',
    'AI Health Assistant',
    'ປະຫວັດຄຳສັ່ງຊື້',
    'ໂປຣໄຟລ໌',
  ];

  @override
  Widget build(BuildContext context) {
    final body = switch (_index) {
      0 => const HomeScreen(),
      1 => const AiHealthChatScreen(),
      2 => const OrderHistoryScreen(),
      _ => const ProfileScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (_index == 0)
            IconButton(
              tooltip: 'Scan QR — product tracking',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const QrScanScreen()),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: body,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.spa_outlined), selectedIcon: Icon(Icons.spa), label: 'ຮ້ານ'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'ຄຳສັ່ງຊື້'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'ໂປຣໄຟລ໌'),
        ],
      ),
    );
  }
}
