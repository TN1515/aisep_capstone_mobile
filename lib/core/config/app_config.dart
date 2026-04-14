import 'dart:io';

class AppConfig {
  AppConfig._();

  /// Đọc Base URL của API từ môi trường
  static String get apiBaseUrl {
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL', 
      defaultValue: 'http://localhost:5294',
    );
    
    // Tự động dọn dẹp /api ở cuối nếu có để tránh lặp đường dẫn (ví dụ trong prod.json)
    if (baseUrl.endsWith('/api/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 5);
    } else if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }

    // Tự động chuyển localhost sang 10.0.2.2 cho Android Emulator
    if (Platform.isAndroid && baseUrl.contains('localhost')) {
      return baseUrl.replaceFirst('localhost', '10.0.2.2');
    }
    return baseUrl;
  }

  /// Đọc API Key từ môi trường
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  /// Tên định danh môi trường (dev, prod, staging)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: '',
  );

  /// Kiểm tra xem có phải đang ở môi trường Production hay không
  static bool get isProduction => environment == 'production';

  /// Tên định danh Token trong storage
  static const String authTokenName = String.fromEnvironment(
    'AUTH_TOKEN_NAME',
    defaultValue: 'auth_token',
  );
}
