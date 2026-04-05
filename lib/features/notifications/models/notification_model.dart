import 'package:flutter/material.dart';

enum NotificationType {
  ai,
  document,
  connection,
  kyc,
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final bool isRead;
  final DateTime timestamp;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.isRead = false,
    required this.timestamp,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    NotificationType? type,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
