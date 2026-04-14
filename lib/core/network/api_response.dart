import 'package:dio/dio.dart';

/// Lớp bao bọc kết quả trả về từ API một cách linh hoạt
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    dynamic json,
    T Function(Object? json)? fromJsonT,
  ) {
    // Nếu json là List, mặc định là thành công và chứa data là List đó
    if (json is List) {
      return ApiResponse<T>(
        success: true,
        statusCode: 200,
        data: fromJsonT != null ? fromJsonT(json) : null,
      );
    }

    if (json is! Map<String, dynamic>) {
      return ApiResponse<T>(success: false, error: 'Phản hồi từ server không hợp lệ');
    }

    // Lấy trạng thái thành công từ isSuccess hoặc success hoặc Success hoặc statusCode
    final bool isSuccess = json['isSuccess'] ?? json['success'] ?? json['Success'] ?? false;
    final int? status = json['statusCode'] ?? json['StatusCode'];
    
    // Coi là thành công nếu phím success=true HOẶC statusCode thuộc dải 2xx
    final bool finalSuccess = isSuccess || (status != null && status >= 200 && status < 300);

    return ApiResponse<T>(
      success: finalSuccess,
      statusCode: status,
      data: (fromJsonT != null)
          ? fromJsonT(json['data'] ?? json['Data'] ?? json['items'] ?? json['Items'] ?? json)
          : null,
      message: (json['message'] ?? json['Message'])?.toString(),
      // Lấy lỗi từ trường error hoặc message nếu success=false
      error: (json['error'] ?? json['Error'])?.toString() ?? (!finalSuccess ? (json['message'] ?? json['Message'])?.toString() : null),
    );
  }

  /// Trả về true nếu success = false hoặc có lỗi
  bool get hasError => !success;
  
  bool get isSuccess => success;

  static ApiResponse<T> fromDioError<T>(Object e) {
    String errorMsg = 'Lỗi hệ thống không xác định';
    if (e is DioException && e.response != null) {
      if (e.response?.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>, null);
      }
      errorMsg = 'Lỗi ${e.response?.statusCode}: ${e.response?.statusMessage}';
    } else {
      errorMsg = e.toString();
    }
    return ApiResponse<T>(success: false, error: errorMsg);
  }
}
