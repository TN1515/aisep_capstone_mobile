import 'dart:io';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
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
          final token = await TokenService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Log cực mạnh ra Console để bạn debug
          dev.log('🚀 [HTTP CALL] ${options.method} ${options.baseUrl}${options.path}', name: 'NETWORK');
          if (options.queryParameters.isNotEmpty) {
            dev.log('   Query: ${options.queryParameters}', name: 'NETWORK');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          dev.log('✅ [RESPONSE] ${response.statusCode} from ${response.requestOptions.path}', name: 'NETWORK');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          dev.log('❌ [ERROR] ${e.response?.statusCode} at ${e.requestOptions.path}', name: 'NETWORK');
          dev.log('   Message: ${e.message}', name: 'NETWORK');
          
          if (e.response?.statusCode == 401) {
            await TokenService.clearAuthData();
            NavigatorService.navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const StartupLoginView()),
              (route) => false,
            );
          }
          return handler.next(e);
        },
      ),
    );

    // Log interceptor tiêu chuẩn của Dio
    if (!AppConfig.isProduction) {
      _dio!.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

      // Bỏ qua kiểm tra SSL và cấu hình Inspector
      (_dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 10);
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    return _dio!;
  }
}
