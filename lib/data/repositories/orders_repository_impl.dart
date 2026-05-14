import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/remote/api_service.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<OrderEntity>> fetchMyOrders(String accessToken) {
    return _api.fetchMyOrders(accessToken);
  }
}
