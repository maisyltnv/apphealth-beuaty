import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_config.dart';
import '../../../domain/entities/auth_user_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/product_entity.dart';

/// Remote client for the Lao Beauty & Health Go API (`shopapi`).
class ApiService {
  ApiService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = ApiConfig.baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  /// [jsonContentType] adds `Content-Type: application/json` (needed for POST/PUT bodies).
  /// Avoid on simple GETs — it triggers an extra CORS preflight in the browser.
  Map<String, String> _headers({String? bearer, bool jsonContentType = false}) {
    final h = <String, String>{'Accept': 'application/json'};
    if (jsonContentType) {
      h['Content-Type'] = 'application/json';
    }
    if (bearer != null && bearer.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearer';
    }
    return h;
  }

  static String? parseErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is String) return err;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> pingHealth() async {
    try {
      final res = await _client.get(_uri('/health'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<ProductEntity>> fetchProducts({int limit = 100, int offset = 0}) async {
    final res = await _client.get(
      _uri('/products', {'limit': '$limit', 'offset': '$offset'}),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] as List<dynamic>? ?? const [];
    return raw.map((e) => ProductEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductEntity> fetchProductById(int id) async {
    final res = await _client.get(_uri('/products/$id'), headers: _headers());
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductEntity.fromJson(map);
  }

  Future<void> register({
    required String username,
    required String password,
    String role = '',
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
    };
    if (role.isNotEmpty) {
      body['role'] = role;
    }
    final res = await _client.post(
      _uri('/auth/register'),
      headers: _headers(jsonContentType: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) {
      throw ApiException(res.statusCode, res.body);
    }
  }

  Future<({String token, String username, AuthUserEntity user})> login({
    required String username,
    required String password,
  }) async {
    final res = await _client.post(
      _uri('/auth/login'),
      headers: _headers(jsonContentType: true),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['access_token'] as String? ?? '';
    final userMap = map['user'] as Map<String, dynamic>? ?? const {};
    final user = AuthUserEntity.fromJson(userMap);
    final name = user.username.isNotEmpty ? user.username : username;
    return (token: token, username: name, user: user);
  }

  Future<AuthUserEntity> fetchMe(String accessToken) async {
    final res = await _client.get(
      _uri('/auth/me'),
      headers: _headers(bearer: accessToken),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthUserEntity.fromJson(map);
  }

  Future<ProductEntity> createProduct(
    String accessToken, {
    required String name,
    required double originalPriceCny,
    required double exchangeRate,
    required double profitMargin,
    String description = '',
    String imageUrl = '',
    String category = '',
    double? finalPriceLak,
    String sourceUrl = '',
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'original_price_cny': originalPriceCny,
      'exchange_rate': exchangeRate,
      'profit_margin': profitMargin,
      'source_url': sourceUrl,
    };
    if (finalPriceLak != null) {
      body['final_price_lak'] = finalPriceLak;
    }
    final res = await _client.post(
      _uri('/products'),
      headers: _headers(bearer: accessToken, jsonContentType: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductEntity.fromJson(map);
  }

  Future<ProductEntity> updateProduct(
    String accessToken,
    int id, {
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    double? originalPriceCny,
    double? exchangeRate,
    double? profitMargin,
    double? finalPriceLak,
    String? sourceUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (imageUrl != null) body['image_url'] = imageUrl;
    if (category != null) body['category'] = category;
    if (originalPriceCny != null) body['original_price_cny'] = originalPriceCny;
    if (exchangeRate != null) body['exchange_rate'] = exchangeRate;
    if (profitMargin != null) body['profit_margin'] = profitMargin;
    if (finalPriceLak != null) body['final_price_lak'] = finalPriceLak;
    if (sourceUrl != null) body['source_url'] = sourceUrl;

    final res = await _client.put(
      _uri('/products/$id'),
      headers: _headers(bearer: accessToken, jsonContentType: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductEntity.fromJson(map);
  }

  Future<void> deleteProduct(String accessToken, int id) async {
    final res = await _client.delete(
      _uri('/products/$id'),
      headers: _headers(bearer: accessToken),
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
  }

  Future<List<OrderEntity>> fetchMyOrders(String accessToken, {int limit = 100, int offset = 0}) async {
    final res = await _client.get(
      _uri('/orders', {'limit': '$limit', 'offset': '$offset'}),
      headers: _headers(bearer: accessToken),
    );
    if (res.statusCode == 401) {
      throw ApiException(res.statusCode, res.body);
    }
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.map((e) => OrderEntity.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (decoded is Map<String, dynamic>) {
        final list = decoded['items'] as List<dynamic>? ?? decoded['orders'] as List<dynamic>? ?? const [];
        return list.map((e) => OrderEntity.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<OrderEntity> placeOrder(
    String accessToken, {
    required double totalAmountLak,
    String paymentReceiptUrl = '',
  }) async {
    final res = await _client.post(
      _uri('/orders'),
      headers: _headers(bearer: accessToken, jsonContentType: true),
      body: jsonEncode({
        'total_amount_lak': totalAmountLak,
        'payment_receipt_url': paymentReceiptUrl,
      }),
    );
    if (res.statusCode != 201) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return OrderEntity.fromJson(map);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  String get messageOrBody => ApiService.parseErrorMessage(body) ?? body;

  @override
  String toString() => 'ApiException($statusCode): $messageOrBody';
}
