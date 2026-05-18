import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/product_image_url_resolver.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository);

  final CatalogRepository _repository;

  List<CategoryEntity> _categories = const [];
  List<ProductEntity> _allProducts = const [];
  bool _loading = false;
  String? _error;
  int? _selectedCategoryId;
  String _searchQuery = '';

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _loading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<({int? id, String label})> get categoryChips {
    return [
      (id: null, label: 'ທັງໝົດ'),
      ..._categories.map((c) => (id: c.id, label: c.name)),
    ];
  }

  /// Products after category + search filters (client-side, like the web store).
  List<ProductEntity> get visibleProducts {
    var list = _allProducts;

    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      list = list.where((p) => _matchesSearch(p, _searchQuery.trim())).toList();
    }

    return list;
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  void selectCategory(int? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (_categories.isEmpty) {
        _categories = await _repository.fetchCategories();
      }
      _allProducts = await _repository.fetchProducts(limit: 500, offset: 0);
      _error = null;
      unawaited(_preloadImageUrls(_allProducts));
    } catch (e) {
      _error = e is ApiException ? e.messageOrBody : e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool _matchesSearch(ProductEntity p, String query) {
    final q = query.toLowerCase();
    bool hit(String value) {
      if (value.isEmpty) return false;
      final v = value.toLowerCase();
      return v.contains(q) || value.contains(query);
    }

    return hit(p.name) || hit(p.category) || hit(p.description);
  }

  Future<void> _preloadImageUrls(List<ProductEntity> products) async {
    final urls = products.map((p) => p.imageUrl).where((u) => u.trim().isNotEmpty).toSet();
    await Future.wait(urls.map(ProductImageUrlResolver.shared.resolve));
    notifyListeners();
  }

  Future<ProductEntity?> fetchProductById(int id) async {
    try {
      return await _repository.fetchProductById(id);
    } catch (_) {
      final local = _allProducts.where((p) => p.id == id).firstOrNull;
      return local;
    }
  }
}
