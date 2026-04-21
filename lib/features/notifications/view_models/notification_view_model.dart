import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'dart:async';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationViewModel() {
    loadNotifications();
  }

  Future<void> loadNotifications({bool unreadOnly = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getNotifications(unreadOnly: unreadOnly);

    if (response.success && response.data != null) {
      _notifications = response.data!;
    } else {
      _errorMessage = response.error ?? 'Không thể tải thông báo';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final response = await _service.markAsRead(id, true);
    if (response.success) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final response = await _service.markAllRead();
    if (response.success) {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(int id) async {
    final response = await _service.deleteNotification(id);
    if (response.success) {
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}
