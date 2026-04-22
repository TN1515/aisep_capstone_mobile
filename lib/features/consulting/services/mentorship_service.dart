import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../models/mentorship_models.dart';
import '../models/advisor_model.dart';

class MentorshipService {
  final Dio _dio = DioClient.instance;

  Future<List<AdvisorModel>> searchAdvisors({
    String? q,
    int? industryId,
    String? expertise,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/advisors/search',
        queryParameters: {
          if (q != null) 'q': q,
          if (industryId != null) 'industryId': industryId,
          if (expertise != null) 'expertise': expertise,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic rawData = response.data['data'];
        List items = [];
        
        if (rawData is Map) {
          items = rawData['items'] ?? [];
        } else if (rawData is List) {
          items = rawData;
        }

        debugPrint('[API DATA] Advisor Search: ${items.length} items found');
        
        return items.map((json) {
          try {
            return AdvisorModel.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            debugPrint('[PARSE ERROR] Advisor: $e');
            return null;
          }
        }).whereType<AdvisorModel>().toList();
      }
      return [];
    } catch (e) {
      debugPrint('[API ERROR] searchAdvisors: $e');
      rethrow;
    }
  }

  Future<AdvisorModel?> getAdvisorDetail(int id) async {
    try {
      final response = await _dio.get('/api/advisors/$id');
      if (response.statusCode == 200) {
        return AdvisorModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('[API ERROR] getAdvisorDetail: $e');
      rethrow;
    }
  }

  Future<MentorshipDto> createMentorship(CreateMentorshipRequest request) async {
    try {
      final response = await _dio.post(
        '/api/mentorships',
        data: request.toJson(),
      );
      return MentorshipDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.data?['errorCode'] == 'SUBSCRIPTION_LIMIT_REACHED') {
        throw Exception('SUBSCRIPTION_LIMIT_REACHED');
      }
      rethrow;
    }
  }

  Future<List<MentorshipDto>> getMentorships({
    MentorshipStatus? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/mentorships',
        queryParameters: {
          if (status != null) 'status': status.value,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      final dynamic dataObject = response.data['data'];
      final List data = dataObject is Map 
          ? (dataObject['items'] ?? []) 
          : (dataObject is List ? dataObject : []);
          
      debugPrint('[API DATA] Mentorships: ${data.length} items found');
      return data.map((json) => MentorshipDto.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[API ERROR] getMentorships: $e');
      rethrow;
    }
  }

  Future<void> cancelMentorship(int id, String reason) async {
    try {
      await _dio.put(
        '/api/mentorships/$id/cancel',
        data: {'reason': reason},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ReportDto?> getReport(int id) async {
    try {
      final response = await _dio.get('/api/mentorships/reports/$id');
      if (response.statusCode == 200) {
        return ReportDto.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> submitFeedback(int mentorshipId, CreateFeedbackRequest request) async {
    try {
      await _dio.post(
        '/api/mentorships/$mentorshipId/feedbacks',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FeedbackDto>> getFeedbacks(int mentorshipId) async {
    try {
      final response = await _dio.get('/api/mentorships/$mentorshipId/feedbacks');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => FeedbackDto.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[API ERROR] getFeedbacks: $e');
      return [];
    }
  }

  Future<List<FeedbackDto>> getAdvisorFeedbacks(int advisorId) async {
    try {
      final response = await _dio.get('/api/advisors/$advisorId/feedbacks');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => FeedbackDto.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[API ERROR] getAdvisorFeedbacks: $e');
      return [];
    }
  }

  /// Phản hồi yêu cầu tư vấn (Chấp nhận/Từ chối)
  Future<void> respondToMentorship(int id, int status) async {
    try {
      await _dio.put(
        '/api/mentorships/$id/status',
        data: {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }
}
