import 'package:dio/dio.dart';
import '../models/evaluation_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';

class EvaluationService {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<List<EvaluationStatusResult>>> getHistory(String startupId) async {
    try {
      final response = await _dio.get(
        '/api/ai/evaluation/history/$startupId',
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => (json as List).map((e) => EvaluationStatusResult.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<EvaluationSubmitResult>> submitEvaluation(SubmitEvaluationRequest request) async {
    try {
      final response = await _dio.post(
        '/api/ai/evaluation/submit',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => EvaluationSubmitResult.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<EvaluationStatusResult>> getEvaluationStatus(int runId) async {
    try {
      final response = await _dio.get(
        '/api/ai/evaluation/$runId/status',
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => EvaluationStatusResult.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<EvaluationReportResult>> getEvaluationReport(int runId) async {
    try {
      final response = await _dio.get(
        '/api/ai/evaluation/$runId/report',
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => EvaluationReportResult.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<EvaluationReportResult>> getEvaluationSourceReport(int runId, String documentType) async {
    try {
      final response = await _dio.get(
        '/api/ai/evaluation/$runId/report/source/$documentType',
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => EvaluationReportResult.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}

