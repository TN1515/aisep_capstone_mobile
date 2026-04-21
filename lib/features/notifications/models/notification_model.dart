import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/utils/datetime_utils.dart';

enum NotificationType {
  AI_EVALUATION,
  CONNECTION_REQUEST,
  CONNECTION_ACCEPTED,
  MESSAGE,
  KYC_STATUS,
  MENTORSHIP,
  SYSTEM, // Fallback
}

class NotificationModel {
  final int id;
  final NotificationType type;
  final String title;
  final String content;
  final bool isRead;
  final DateTime timestamp;
  final String? actionUrl;
  final int? relatedEntityId;
  final String? relatedEntityType;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.timestamp,
    this.actionUrl,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse enum safely
    NotificationType parseType(String? typeStr) {
      if (typeStr == null) return NotificationType.SYSTEM;
      return NotificationType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => NotificationType.SYSTEM,
      );
    }

    return NotificationModel(
      id: json['notificationId'] ?? 0,
      type: parseType(json['notificationType']),
      title: json['title'] ?? 'Thông báo',
      content: json['messagePreview'] ?? json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      timestamp: DateTimeUtils.parseApiDate(json['createdAt']),
      actionUrl: json['actionUrl'],
      relatedEntityId: json['relatedEntityId'],
      relatedEntityType: json['relatedEntityType'],
    );
  }

  NotificationModel copyWith({
    int? id,
    NotificationType? type,
    String? title,
    String? content,
    bool? isRead,
    DateTime? timestamp,
    String? actionUrl,
    int? relatedEntityId,
    String? relatedEntityType,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      actionUrl: actionUrl ?? this.actionUrl,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
    );
  }
}
