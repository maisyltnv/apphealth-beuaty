import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/remote/api_service.dart';
import 'data/repositories/catalog_repository_impl.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/catalog_provider.dart';
import 'presentation/providers/orders_provider.dart';
import 'presentation/screens/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiService();
  final catalogRepo = CatalogRepositoryImpl(api);
  final ordersRepo = OrdersRepositoryImpl(api);

  final auth = AuthProvider(api);
  await auth.bootstrap();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(catalogRepo)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(ordersRepo),
        ),
      ],
      child: const LaoBeautyApp(),
    ),
  );
}

class LaoBeautyApp extends StatelessWidget {
  const LaoBeautyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lao Beauty & Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}
