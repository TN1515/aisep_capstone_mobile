import 'package:dio/dio.dart';
import '../models/evaluation_models.dart';
import '../../../core/network/dio_client.dart';

class EvaluationService {
  final Dio _dio = DioClient.instance;

  Future<List<EvaluationStatusResult>> getHistory(String startupId) async {
    try {
      final response = await _dio.get(
        '/api/ai/evaluation/history/$startupId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => EvaluationStatusResult.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<EvaluationSubmitResult> submitEvaluation(SubmitEvaluationRequest request) async {
    try {
      final response = await _dio.post(
        '/api/ai/evaluation/submit',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EvaluationSubmitResult.fromJson(response.data);
      }
      throw Exception('Failed to submit evaluation');
    } catch (e) {
      rethrow;
    }
  }

  Future<EvaluationStatusResult> getEvaluationStatus(int runId) async {
    try {
      final response = await _dio.get(
        '/api/ai/evaluation/$runId/status',
      );

      if (response.statusCode == 200) {
        return EvaluationStatusResult.fromJson(response.data);
      }
      throw Exception('Failed to get evaluation status');
    } catch (e) {
      rethrow;
    }
  }

  Future<EvaluationReportResult> getEvaluationReport(int runId) async {
    try {
      final response = await _dio.get(
        '/api/ai/evaluation/$runId/report',
      );

      if (response.statusCode == 200) {
        return EvaluationReportResult.fromJson(response.data);
      }
      throw Exception('Failed to get evaluation report');
    } catch (e) {
      rethrow;
    }
  }
}

