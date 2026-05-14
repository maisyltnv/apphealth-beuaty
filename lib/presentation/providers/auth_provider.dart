import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/remote/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiService _api;

  static const _kToken = 'auth_token';
  static const _kUsername = 'auth_username';

  String? _token;
  String? _username;
  bool _ready = false;

  String? get token => _token;
  String? get username => _username;
  bool get isReady => _ready;
  bool get isSignedIn => _token != null && _token!.isNotEmpty;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    _username = prefs.getString(_kUsername);
    _ready = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username: username, password: password);
    _token = result.token;
    _username = result.username;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _token ?? '');
    await prefs.setString(_kUsername, _username ?? '');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUsername);
    notifyListeners();
  }
}
