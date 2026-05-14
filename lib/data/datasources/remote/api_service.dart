import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_config.dart';
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

  Map<String, String> _jsonHeaders({String? bearer}) {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (bearer != null && bearer.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearer';
    }
    return h;
  }

  Future<List<ProductEntity>> fetchProducts({int limit = 100, int offset = 0}) async {
    final res = await _client.get(
      _uri('/products', {'limit': '$limit', 'offset': '$offset'}),
      headers: _jsonHeaders(),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] as List<dynamic>? ?? const [];
    return raw.map((e) => ProductEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<({String token, String username})> login({
    required String username,
    required String password,
  }) async {
    final res = await _client.post(
      _uri('/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['access_token'] as String? ?? '';
    final user = map['user'] as Map<String, dynamic>? ?? const {};
    final name = user['username'] as String? ?? username;
    return (token: token, username: name);
  }

  /// Optional endpoint — returns [] if not implemented (404) or unauthorized.
  Future<List<OrderEntity>> fetchMyOrders(String accessToken) async {
    final res = await _client.get(
      _uri('/orders'),
      headers: _jsonHeaders(bearer: accessToken),
    );
    if (res.statusCode == 404 || res.statusCode == 401) {
      return const [];
    }
    if (res.statusCode != 200) {
      return const [];
    }
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded
            .map((e) => OrderEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        final list = decoded['items'] as List<dynamic>? ?? decoded['orders'] as List<dynamic>? ?? const [];
        return list.map((e) => OrderEntity.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return const [];
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
