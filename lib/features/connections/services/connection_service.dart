import 'dart:developer';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/connection_model.dart';
import '../models/investor_model.dart';
import '../models/information_request_model.dart';

class ConnectionService {
  final _dio = DioClient.instance;

  // 1. Luồng Khám phá (Search & View)
  Future<ApiResponse<List<InvestorModel>>> getInvestors({
    String? keyword,
    String? stage,
    String? industry,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/startups/investors',
        queryParameters: {
          if (keyword != null) 'keyword': keyword,
          if (stage != null) 'stage': stage,
          if (industry != null) 'industry': industry,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      // Spec says PagedResponse<InvestorSearchItemDto>
      // If the response is wrapped in items, handle it. Assuming it might be in 'data' or 'items'
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          final items = (json is Map && (json.containsKey('items') || json.containsKey('Items') || json.containsKey('data') || json.containsKey('Data')))
              ? (json['items'] ?? json['Items'] ?? json['data'] ?? json['Data'])
              : json;
          return (items as List).map((i) => InvestorModel.fromJson(i)).toList();
        }
      );
    } catch (e) {
      log('Error getting investors: $e');
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<InvestorModel>> getInvestorById(int id) async {
    try {
      final response = await _dio.get('/api/startups/investors/$id');
      return ApiResponse.fromJson(response.data, (json) => InvestorModel.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 2. Luồng Kết nối (Connection Lifecycle)
  Future<ApiResponse<void>> inviteConnection(int investorId, String message) async {
    try {
      final response = await _dio.post(
        '/api/connections/invite',
        data: {
          'investorId': investorId,
          'InvestorId': investorId,
          'message': message,
          'Message': message,
        },
      );
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<ConnectionModel>> updateConnectionMessage(int id, String message) async {
    try {
      final response = await _dio.put(
        '/api/connections/$id',
        data: {'message': message},
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) => ConnectionModel.fromJson(json as Map<String, dynamic>)
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<List<ConnectionModel>>> getSentConnections({String? status}) async {
    try {
      final response = await _dio.get(
        '/api/connections/sent',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          final items = (json is Map && (json.containsKey('items') || json.containsKey('Items') || json.containsKey('data') || json.containsKey('Data')))
              ? (json['items'] ?? json['Items'] ?? json['data'] ?? json['Data'])
              : json;
          return (items as List).map((i) => ConnectionModel.fromJson(i)).toList();
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<List<ConnectionModel>>> getReceivedConnections({String? status}) async {
    try {
      final response = await _dio.get(
        '/api/connections/received',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          final items = (json is Map && (json.containsKey('items') || json.containsKey('Items') || json.containsKey('data') || json.containsKey('Data')))
              ? (json['items'] ?? json['Items'] ?? json['data'] ?? json['Data'])
              : json;
          return (items as List).map((i) => ConnectionModel.fromJson(i)).toList();
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<void>> acceptConnection(int id) async {
    try {
      final response = await _dio.post('/api/connections/$id/accept');
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<void>> rejectConnection(int id, String reason) async {
    try {
      final response = await _dio.post(
        '/api/connections/$id/reject',
        data: {'reason': reason},
      );
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<void>> withdrawConnection(int id) async {
    try {
      final response = await _dio.post('/api/connections/$id/withdraw');
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<void>> closeConnection(int id) async {
    try {
      final response = await _dio.post('/api/connections/$id/close');
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 4. Yêu cầu thông tin (Post-Connection Info Requests)
  Future<ApiResponse<List<InfoRequestModel>>> getInfoRequests(int connectionId) async {
    try {
      final response = await _dio.get('/api/connections/$connectionId/info-requests');
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          final items = (json is Map && (json.containsKey('items') || json.containsKey('Items')))
              ? (json['items'] ?? json['Items'])
              : json;
          return (items as List).map((i) => InfoRequestModel.fromJson(i)).toList();
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<void>> fulfillInfoRequest(int requestId, String content, List<String> attachments) async {
    try {
      final response = await _dio.post(
        '/api/info-requests/$requestId/fulfill',
        data: {
          'content': content,
          'attachments': attachments,
        },
      );
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<void>> rejectInfoRequest(int requestId, String reason) async {
    try {
      final response = await _dio.post(
        '/api/info-requests/$requestId/reject',
        queryParameters: {'reason': reason},
      );
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 5. Tính năng bổ sung (AI Recommendation & Watchlist)
  Future<ApiResponse<List<InvestorModel>>> getAiRecommendations() async {
    try {
      final response = await _dio.get('/api/ai-recommendation/investors');
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          final items = (json is Map && (json.containsKey('items') || json.containsKey('Items')))
              ? (json['items'] ?? json['Items'])
              : json;
          return (items as List).map((i) => InvestorModel.fromJson(i)).toList();
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  Future<ApiResponse<void>> addToWatchlist(int investorId) async {
    try {
      final response = await _dio.post(
        '/api/startups/me/watchlist/investors',
        data: {'investorId': investorId},
      );
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}

