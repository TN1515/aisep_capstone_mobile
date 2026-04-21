import 'package:dio/dio.dart';
import 'package:aisep_capstone_mobile/core/network/api_response.dart';
import 'package:aisep_capstone_mobile/core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = DioClient.instance;

  /// Fetch all notifications with optional filtering and pagination
  Future<ApiResponse<List<NotificationModel>>> getNotifications({
    bool? unreadOnly,
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/notifications',
        queryParameters: {
          if (unreadOnly != null) 'unreadOnly': unreadOnly,
          if (type != null) 'type': type,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      return ApiResponse.fromJson(
        response.data,
        (json) {
          // Handle various possible JSON structures (List, Map with data, Map with items)
          if (json is List) {
            return json.map((item) => NotificationModel.fromJson(item)).toList();
          } else if (json is Map<String, dynamic>) {
            final items = json['items'] ?? json['Items'] ?? json['data'] ?? json['Data'] ?? [];
            if (items is List) {
              return items.map((item) => NotificationModel.fromJson(item)).toList();
            }
          }
          return [];
        },
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Get detailed information for a single notification
  Future<ApiResponse<NotificationModel>> getNotificationDetail(int id) async {
    try {
      final response = await _dio.get('/api/notifications/$id');
      return ApiResponse.fromJson(
        response.data,
        (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Mark a notification as read/unread
  Future<ApiResponse<NotificationModel>> markAsRead(int id, bool isRead) async {
    try {
      final response = await _dio.put(
        '/api/notifications/$id/read',
        data: {'isRead': isRead},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Mark all notifications as read for the current user
  Future<ApiResponse<int>> markAllRead() async {
    try {
      final response = await _dio.put('/api/notifications/read-all');
      return ApiResponse.fromJson(
        response.data,
        (json) => (json as Map<String, dynamic>)['updatedCount'] as int,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Delete a notification
  Future<ApiResponse<bool>> deleteNotification(int id) async {
    try {
      await _dio.delete('/api/notifications/$id');
      return ApiResponse(success: true, data: true);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.response != null && e.response?.data != null && e.response?.data is Map) {
      return ApiResponse.fromJson(e.response!.data, null);
    }
    return ApiResponse<T>(
      success: false,
      error: 'Lỗi kết nối server: ${e.message}',
    );
  }
}
