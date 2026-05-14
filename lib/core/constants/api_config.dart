import 'dart:io';

/// Base URL for the Go Gin API (`shopapi` on port 8080).
///
/// - **Android emulator**: `10.0.2.2` maps to the host machine’s loopback.
/// - **iOS simulator / desktop**: `localhost` works.
/// Override at build time: `--dart-define=API_BASE=http://192.168.1.10:8080`
class ApiConfig {
  ApiConfig._();

  static const int port = 8080;

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE');
    if (override.isNotEmpty) return override;
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:$port';
  }
}
