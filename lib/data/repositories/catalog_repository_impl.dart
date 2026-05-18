import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/remote/api_service.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<List<CategoryEntity>> fetchCategories() => _api.fetchCategories();

  @override
  Future<List<ProductEntity>> fetchProducts({int limit = 100, int offset = 0, int? categoryId}) {
    return _api.fetchProducts(limit: limit, offset: offset, categoryId: categoryId);
  }

  @override
  Future<ProductEntity> fetchProductById(int id) => _api.fetchProductById(id);
}
