import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'dart:async';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;

  NotificationViewModel() {
    _loadInitialNotifications();
  }

  void _loadInitialNotifications() {
    _isLoading = true;
    notifyListeners();

    // Mock Notifications
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Hồ sơ đã được xác thực',
        content: 'Chúc mừng! Hồ sơ startup của bạn đã được đội ngũ AISEP xác thực thành công.',
        type: NotificationType.kyc,
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        id: '2',
        title: 'Đánh giá AI hoàn tất',
        content: 'Báo cáo phân tích tiềm năng cho Pitch Deck V2 đã sẵn sàng. Xem ngay kết quả.',
        type: NotificationType.ai,
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '3',
        title: 'Yêu cầu kết nối mới',
        content: 'Nhà đầu tư Shark Bình vừa gửi yêu cầu kết nối với dự án của bạn.',
        type: NotificationType.connection,
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: '4',
        title: 'Tài liệu đã được lưu chuỗi',
        content: 'Báo cáo tài chính Q1 đã được băm và lưu trữ an toàn trên Blockchain.',
        type: NotificationType.document,
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '5',
        title: 'Cập nhật hệ thống',
        content: 'AISEP vừa cập nhật tính năng Quản lý lịch sử tài liệu. Hãy khám phá ngay!',
        type: NotificationType.system,
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _loadInitialNotifications();
  }
}
