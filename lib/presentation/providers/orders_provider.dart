import 'package:flutter/foundation.dart';

import '../../data/datasources/remote/api_service.dart';
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
      _error = null;
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _repository.fetchMyOrders(accessToken, limit: 100, offset: 0);
    } catch (e) {
      _error = e is ApiException ? e.messageOrBody : e.toString();
      _orders = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<OrderEntity?> placeOrder(
    String accessToken, {
    required double totalAmountLak,
    String paymentReceiptUrl = '',
  }) async {
    _error = null;
    notifyListeners();
    try {
      final created = await _repository.placeOrder(
        accessToken,
        totalAmountLak: totalAmountLak,
        paymentReceiptUrl: paymentReceiptUrl,
      );
      _orders = [created, ..._orders];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e is ApiException ? e.messageOrBody : e.toString();
      notifyListeners();
      return null;
    }
  }
}
