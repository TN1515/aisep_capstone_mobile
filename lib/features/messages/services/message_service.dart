import 'dart:developer' as dev;
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/chat_model.dart';

class MessageService {
  final _dio = DioClient.instance;

  // 1. Khởi tạo hội thoại
  Future<ApiResponse<ConversationModel>> createConversation({
    int? connectionId,
    int? mentorshipId,
    String? initialMessage,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (connectionId != null && connectionId > 0) {
        body['connectionId'] = connectionId;
      }
      if (mentorshipId != null && mentorshipId > 0) {
        body['mentorshipId'] = mentorshipId;
      }

      final response = await _dio.post(
        '/api/conversations',
        data: body,
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          final mapped = json as Map<String, dynamic>;
          // Ensure ID is mapped correctly if it's top-level or nested
          return ConversationModel.fromJson(mapped);
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 2. Danh sách hội thoại (Inbox)
  Future<ApiResponse<List<ConversationModel>>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/conversations',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          dev.log('MessageService: Parsing conversations response keys: ${json is Map ? json.keys.toList() : 'Direct List'}');
          
          dynamic items;
          if (json is List) {
            items = json;
          } else if (json is Map) {
            // Check all common backend response keys for lists
            items = json['items'] ?? json['Items'] ?? 
                    json['data'] ?? json['Data'] ?? 
                    json['results'] ?? json['Results'] ??
                    json['content'] ?? json['Content'] ??
                    json['list'] ?? json['List'] ?? json;
          }

          if (items is List) {
            return items.map((i) => ConversationModel.fromJson(i)).toList();
          }
          
          dev.log('MessageService: Warning - Could not identify list in response. Raw data: $json');
          return <ConversationModel>[];
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 3. Lấy chi tiết & Tin nhắn
  Future<ApiResponse<List<MessageModel>>> getMessages({
    required int conversationId,
    int page = 1,
    int pageSize = 50,
    required int currentUserId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/conversations/$conversationId/messages',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) {
          dev.log('MessageService: Parsing messages response keys: ${json is Map ? json.keys.toList() : 'Direct List'}');
          
          dynamic items;
          if (json is List) {
            items = json;
          } else if (json is Map) {
            // Check all common backend response keys for lists
            items = json['items'] ?? json['Items'] ?? 
                    json['data'] ?? json['Data'] ?? 
                    json['results'] ?? json['Results'] ??
                    json['content'] ?? json['Content'] ??
                    json['messages'] ?? json['Messages'] ?? json;
          }

          if (items is List) {
            return items.map((i) => MessageModel.fromJson(i, currentUserId)).toList();
          }
          
          dev.log('MessageService: Warning - Could not identify messages list. Raw data: $json');
          return <MessageModel>[];
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 4. Đánh giá đã đọc (Read ALL)
  Future<ApiResponse<void>> markAsRead(int conversationId) async {
    try {
      final response = await _dio.post(
        '/api/messages/read-all',
        data: {'conversationId': conversationId},
      );
      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 5. Gửi tin nhắn (Nếu implementation qua API thay vì Hub)
  Future<ApiResponse<MessageModel>> sendMessage({
    required int conversationId,
    required String content,
    required int currentUserId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/messages',
        data: {
          'conversationId': conversationId,
          'content': content,
        },
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) => MessageModel.fromJson(json as Map<String, dynamic>, currentUserId)
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}
