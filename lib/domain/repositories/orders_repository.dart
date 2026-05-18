import '../entities/order_entity.dart';
import '../entities/shipping_quote_entity.dart';

abstract class OrdersRepository {
  Future<({List<OrderEntity> items, int page, int totalPages, bool hasNext})> fetchOrdersByPhone({
    required String phone,
    int page = 1,
    int limit = 10,
  });

  Future<ShippingQuoteEntity> fetchShippingQuote(double subtotalLak);

  Future<({double shippingFeeLak, double freeShippingMinSubtotalLak})> fetchShippingConfig();

  Future<OrderEntity> placeOrder(
    String accessToken, {
    required String paymentMethod,
    required List<({int productId, int quantity})> items,
    required String recipientName,
    required String phone,
    required String province,
    required String addressDetail,
    String paymentReceiptUrl = '',
  });
}
