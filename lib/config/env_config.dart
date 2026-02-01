/// Environment configuration using --dart-define
///
/// Values are injected at compile time using:
/// mise run local  -> runs with local configuration
/// mise run dev    -> runs with dev configuration
/// mise run prod   -> runs with production configuration
class EnvConfig {
  /// Base URL for API client (e.g., http://localhost:4000)
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');

  /// API URL - automatically derived from apiBaseUrl by appending '/api'
  static String get apiUrl => '$apiBaseUrl/api';

  /// Check if running in local mode
  static bool get isLocal => apiBaseUrl.contains('localhost');

  /// Check if running in production mode
  static bool get isProduction => apiBaseUrl.contains('api.fmecg.com');

  /// Get current environment name
  static String get environmentName {
    if (isLocal) return 'local';
    if (isProduction) return 'production';
    return 'development';
  }
}
