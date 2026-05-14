import '../entities/product_entity.dart';

abstract class CatalogRepository {
  Future<List<ProductEntity>> fetchProducts({int limit = 100, int offset = 0});

  Future<ProductEntity> fetchProductById(int id);
}
