import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../models/kyc_status_model.dart';
import 'package:path/path.dart';

class KYCService {
  final Dio _dio = DioClient.instance;

  /// Lấy trạng thái hiện tại và dữ liệu nháp của hồ sơ KYC
  Future<ApiResponse<StartupKYCStatusDto>> getKycStatus() async {
    try {
      final response = await _dio.get('/api/startups/me/kyc/status');
      return ApiResponse<StartupKYCStatusDto>.fromJson(
        response.data,
        (data) => StartupKYCStatusDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Gửi hồ sơ KYC chính thức
  Future<ApiResponse<String>> submitKyc({
    required List<KYCEvidenceFile> evidenceFiles,
    required Map<String, dynamic> formData,
  }) async {
    return _sendKycData(
      endpoint: '/api/startups/me/kyc/submit',
      method: 'POST',
      evidenceFiles: evidenceFiles,
      additionalData: formData,
    );
  }

  /// Lưu nháp hồ sơ KYC
  Future<ApiResponse<String>> saveKycDraft({
    required List<KYCEvidenceFile> evidenceFiles,
    required Map<String, dynamic> formData,
  }) async {
    return _sendKycData(
      endpoint: '/api/startups/me/kyc/draft',
      method: 'PATCH',
      evidenceFiles: evidenceFiles,
      additionalData: formData,
    );
  }

  /// Hàm dùng chung xử lý Multipart Upload bao gồm tệp và dữ liệu văn bản
  Future<ApiResponse<String>> _sendKycData({
    required String endpoint,
    required String method,
    required List<KYCEvidenceFile> evidenceFiles,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = additionalData ?? {};

      // Xử lý tệp tin minh chứng
      if (evidenceFiles.isNotEmpty) {
        List<MultipartFile> multipartFileList = [];
        for (var kycFile in evidenceFiles) {
          multipartFileList.add(
            await MultipartFile.fromFile(
              kycFile.file.path,
              filename: basename(kycFile.file.path),
            )
          );
        }
        formDataMap['EvidenceFiles'] = multipartFileList;
        formDataMap['EvidenceFileKinds'] = evidenceFiles.map((e) => e.kind.key).toList();
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.request(
        endpoint,
        data: formData,
        options: Options(method: method),
      );

      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data.toString(),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<T> _handleError<T>(Object e) {
    if (e is DioException) {
      final int? statusCode = e.response?.statusCode;

      if (e.response != null && e.response!.data is Map) {
        return ApiResponse<T>.fromJson(
          e.response!.data,
          null,
        );
      }
      
      String message = 'Lỗi kết nối server';
      if (statusCode == 401) {
        message = 'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.';
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        message = 'Kết nối máy chủ bị quá hạn. Vui lòng kiểm tra mạng.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra internet.';
      } else {
        message = e.response?.statusMessage ?? e.message ?? 'Đã có lỗi xảy ra';
      }

      return ApiResponse<T>(
        success: false,
        statusCode: statusCode,
        error: message,
      );
    }
    return ApiResponse<T>(
      success: false,
      error: e.toString(),
    );
  }
}
