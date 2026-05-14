import 'package:flutter/foundation.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._repository);

  final OrdersRepository _repository;

  List<OrderEntity> _orders = const [];
  bool _loading = false;
  String? _error;

  List<OrderEntity> get orders => _orders;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load(String? accessToken) async {
    if (accessToken == null || accessToken.isEmpty) {
      _orders = const [];
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.fetchMyOrders(accessToken);
    } catch (e) {
      _error = e.toString();
      _orders = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
