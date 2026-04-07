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
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    // Lấy trạng thái thành công từ isSuccess hoặc success hoặc statusCode
    final bool isSuccess = json['isSuccess'] ?? json['success'] ?? false;
    final int? status = json['statusCode'];
    
    // Coi là thành công nếu phím success=true HOẶC statusCode thuộc dải 2xx
    final bool finalSuccess = isSuccess || (status != null && status >= 200 && status < 300);

    return ApiResponse<T>(
      success: finalSuccess,
      statusCode: status,
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
      message: json['message']?.toString(),
      // Lấy lỗi từ trường error hoặc message nếu success=false
      error: json['error']?.toString() ?? (!finalSuccess ? json['message']?.toString() : null),
    );
  }

  /// Trả về true nếu success = false hoặc có lỗi
  bool get hasError => !success;
}
