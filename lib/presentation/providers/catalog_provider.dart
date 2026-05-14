import 'package:flutter/foundation.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository);

  final CatalogRepository _repository;

  List<ProductEntity> _products = const [];
  bool _loading = false;
  String? _error;
  String? _selectedCategory;

  List<ProductEntity> get products => _products;
  bool get isLoading => _loading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final rest = _products.map((e) => e.category).toSet().toList()..sort();
    return ['ທັງໝົດ', ...rest];
  }

  List<ProductEntity> get visibleProducts {
    if (_selectedCategory == null || _selectedCategory == 'ທັງໝົດ') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  void selectCategory(String label) {
    if (label == 'ທັງໝົດ') {
      _selectedCategory = null;
    } else {
      _selectedCategory = label;
    }
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _repository.fetchProducts(limit: 200, offset: 0);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
