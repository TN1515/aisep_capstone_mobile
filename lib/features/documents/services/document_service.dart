import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../models/document_model.dart';

class DocumentService {
  final Dio _dio = DioClient.instance;

  // 1. Tải lên tài liệu (Upload)
  Future<ApiResponse<DocumentModel>> uploadDocument({
    required File file,
    required DocumentType type,
    String? title,
    String? version,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(file.path, filename: fileName),
        'DocumentType': type.value,
        if (title != null) 'Title': title,
        if (version != null) 'Version': version,
      });

      final response = await _dio.post('/api/documents', data: formData);
      return ApiResponse.fromJson(
        response.data, 
        (json) => DocumentModel.fromJson(json as Map<String, dynamic>)
      );
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 2. Lấy danh sách tài liệu
  Future<ApiResponse<List<DocumentModel>>> getDocuments({bool isArchived = false}) async {
    try {
      final response = await _dio.get('/api/documents', queryParameters: {
        'isArchived': isArchived,
      });
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((item) => DocumentModel.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 3. Cập nhật Metadata
  Future<ApiResponse<bool>> updateMetadata(int id, {
    String? title,
    int? type,
    bool? isArchived,
  }) async {
    try {
      final response = await _dio.put('/api/documents/$id/metadata', data: {
        if (title != null) 'Title': title,
        if (type != null) 'DocumentType': type,
        if (isArchived != null) 'IsArchived': isArchived,
      });
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 4. Lưu trữ tài liệu (Soft Delete)
  Future<ApiResponse<bool>> deleteDocument(int id) async {
    try {
      final response = await _dio.delete('/api/documents/$id');
      return ApiResponse.fromJson(response.data, (json) => true);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // --- BLOCKCHAIN APIs ---

  // 1. Tính toán mã Hash
  Future<ApiResponse<String>> computeHash(int id) async {
    try {
      final response = await _dio.post('/api/documents/$id/hash');
      return ApiResponse.fromJson(response.data, (json) => json.toString());
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 2. Gửi lên Blockchain
  Future<ApiResponse<String>> submitToChain(int id) async {
    try {
      final response = await _dio.post('/api/documents/$id/submit-chain');
      // Trả về TransactionHash
      return ApiResponse.fromJson(response.data, (json) => json.toString());
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 3. Kiểm tra trạng thái giao dịch
  Future<ApiResponse<String>> checkTxStatus(int id) async {
    try {
      final response = await _dio.get('/api/documents/$id/chain/tx-status');
      return ApiResponse.fromJson(response.data, (json) => json.toString());
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 4. Xác minh tính toàn vẹn
  Future<ApiResponse<String>> verifyOnChain(int id) async {
    try {
      final response = await _dio.get('/api/documents/$id/verify-chain');
      return ApiResponse.fromJson(response.data, (json) => json.toString());
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}
