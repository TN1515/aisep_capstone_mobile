import 'package:dio/dio.dart';
import 'package:aisep_capstone_mobile/core/network/api_response.dart';
import 'package:aisep_capstone_mobile/core/network/dio_client.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_model.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  // 1. Đăng ký (Register)
  Future<ApiResponse<bool>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/api/auth/register', data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // 2. Xác thực Email (Verify Email)
  Future<ApiResponse<AuthResponse>> verifyEmail(VerifyEmailRequest request) async {
    try {
      final response = await _dio.post('/api/auth/verify-email', data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => AuthResponse.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // 3. Đăng nhập (Login)
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/api/auth/login', data: request.toJson());
      return ApiResponse.fromJson(response.data, (json) => AuthResponse.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // 4. Gửi lại mã (Resend)
  Future<ApiResponse<bool>> resend(String email) async {
    try {
      final response = await _dio.post('/api/auth/resend', data: {'email': email});
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // 5. Đăng xuất (Logout)
  Future<ApiResponse<bool>> logout() async {
    try {
      final response = await _dio.post('/api/auth/logout'); // Token lấy từ Interceptor
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // 6. Quên mật khẩu (Forgot Password)
  Future<ApiResponse<bool>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/api/auth/forgot-password', data: {'email': email});
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // 7. Thiết lập lại mật khẩu (Reset Password)
  Future<ApiResponse<bool>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await _dio.post('/api/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // 8. Đổi mật khẩu (Change Password)
  Future<ApiResponse<bool>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _dio.put('/api/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Helper xử lý lỗi bọc ApiResponse
  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.response != null && e.response?.data != null) {
      // Parse lỗi từ server theo cấu trúc ApiResponse
      return ApiResponse.fromJson(e.response!.data, null);
    }
    return ApiResponse<T>(
      success: false, 
      error: 'Lỗi kết nối server: ${e.message}',
    );
  }
}
