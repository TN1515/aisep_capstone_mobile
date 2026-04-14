import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/chat_model.dart';

class MessageService {
  final _dio = DioClient.instance;

  // 1. Khởi tạo hội thoại
  Future<ApiResponse<ConversationModel>> createConversation({
    required int connectionId,
    String? initialMessage,
  }) async {
    try {
      final response = await _dio.post(
        '/api/conversations',
        data: {
          'connectionId': connectionId,
          if (initialMessage != null) 'initialMessage': initialMessage,
        },
      );
      return ApiResponse.fromJson(
        response.data, 
        (json) => ConversationModel.fromJson(json as Map<String, dynamic>)
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
          final items = (json is Map && (json.containsKey('items') || json.containsKey('Items')))
              ? (json['items'] ?? json['Items'])
              : json;
          return (items as List).map((i) => ConversationModel.fromJson(i)).toList();
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
          final items = (json is Map && (json.containsKey('items') || json.containsKey('Items')))
              ? (json['items'] ?? json['Items'])
              : json;
          return (items as List).map((i) => MessageModel.fromJson(i, currentUserId)).toList();
        }
      );
    } catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  // 4. Đánh giá đã đọc
  Future<ApiResponse<void>> markAsRead(int conversationId) async {
    try {
      final response = await _dio.put('/api/conversations/$conversationId/read');
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
        '/api/conversations/$conversationId/messages',
        data: {'content': content},
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
