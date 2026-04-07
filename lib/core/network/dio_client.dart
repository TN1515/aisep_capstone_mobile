import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/token_service.dart';
import '../navigation/navigator_service.dart';
import '../../features/auth/views/startup_login_view.dart';
import '../../features/onboarding/views/startup_onboarding_screen.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm Interceptor xử lý Bearer Token và Refresh Token
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token thực tế từ SecureStorage
          final String? token = await TokenService.getAccessToken();
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Xử lý lỗi 401 (Hết hạn Token)
          if (e.response?.statusCode == 401) {
            final refreshToken = await TokenService.getRefreshToken();
            
            if (refreshToken != null) {
              try {
                // Thử Refresh Token
                // Sử dụng một Dio instance mới để tránh lặp vô hạn
                final refreshResponse = await Dio().post(
                  '${AppConfig.apiBaseUrl}/api/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                );

                if (refreshResponse.statusCode == 200) {
                  final String newAccessToken = refreshResponse.data['data']['accessToken'];
                  
                  // Lưu token mới
                  await TokenService.saveTokens(accessToken: newAccessToken);

                  // Gửi lại request bị lỗi với token mới
                  e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final response = await _dio!.fetch(e.requestOptions);
                  return handler.resolve(response);
                }
              } catch (refreshError) {
                // Nếu refresh thất bại, xóa dữ liệu và logout
                await TokenService.clearAuthData();
                NavigatorService.navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const StartupLoginView()),
                  (route) => false,
                );
              }
            } else {
              // Không có Refresh Token, logout luôn
              await TokenService.clearAuthData();
              NavigatorService.navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const StartupLoginView()),
                (route) => false,
              );
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Log interceptor - Chỉ kích hoạt trong môi trường Development
    if (!AppConfig.isProduction) {
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));

      // Bỏ qua kiểm tra SSL nếu là môi trường Development (HTTPS Local)
      (_dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    return _dio!;
  }
}
