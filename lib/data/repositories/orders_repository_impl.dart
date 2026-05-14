import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/remote/api_service.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<OrderEntity>> fetchMyOrders(String accessToken, {int limit = 100, int offset = 0}) {
    return _api.fetchMyOrders(accessToken, limit: limit, offset: offset);
  }

  @override
  Future<OrderEntity> placeOrder(
    String accessToken, {
    required double totalAmountLak,
    String paymentReceiptUrl = '',
  }) {
    return _api.placeOrder(
      accessToken,
      totalAmountLak: totalAmountLak,
      paymentReceiptUrl: paymentReceiptUrl,
    );
  }
}
