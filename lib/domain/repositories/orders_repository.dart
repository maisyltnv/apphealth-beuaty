import '../entities/order_entity.dart';

abstract class OrdersRepository {
  /// Uses `GET /orders` when available on the API; otherwise returns an empty list.
  Future<List<OrderEntity>> fetchMyOrders(String accessToken);
}
