import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class CatalogRepository {
  Future<List<CategoryEntity>> fetchCategories();

  Future<List<ProductEntity>> fetchProducts({int limit = 100, int offset = 0, int? categoryId});

  Future<ProductEntity> fetchProductById(int id);
}
