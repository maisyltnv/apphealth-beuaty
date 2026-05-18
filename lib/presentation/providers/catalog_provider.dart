import 'package:flutter/foundation.dart';

import '../../data/datasources/remote/api_service.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository);

  final CatalogRepository _repository;

  List<CategoryEntity> _categories = const [];
  List<ProductEntity> _products = const [];
  bool _loading = false;
  String? _error;
  int? _selectedCategoryId;

  List<CategoryEntity> get categories => _categories;
  List<ProductEntity> get products => _products;
  bool get isLoading => _loading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;

  List<({int? id, String label})> get categoryChips {
    return [
      (id: null, label: 'ທັງໝົດ'),
      ..._categories.map((c) => (id: c.id, label: c.name)),
    ];
  }

  List<ProductEntity> get visibleProducts => _products;

  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
    load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (_categories.isEmpty) {
        _categories = await _repository.fetchCategories();
      }
      _products = await _repository.fetchProducts(
        limit: 200,
        offset: 0,
        categoryId: _selectedCategoryId,
      );
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.messageOrBody : e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<ProductEntity?> fetchProductById(int id) async {
    try {
      return await _repository.fetchProductById(id);
    } catch (_) {
      return null;
    }
  }
}
