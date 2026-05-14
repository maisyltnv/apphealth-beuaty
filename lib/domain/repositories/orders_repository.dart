import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> fetchMyOrders(String accessToken, {int limit = 100, int offset = 0});

  Future<OrderEntity> placeOrder(
    String accessToken, {
    required double totalAmountLak,
    String paymentReceiptUrl = '',
  });
}
