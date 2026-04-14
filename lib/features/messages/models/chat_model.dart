import 'package:flutter/foundation.dart';

enum ConversationStatus {
  Active,
  Archived,
  Closed
}

class ConversationModel {
  final int id;
  final String partnerName;
  final String? partnerAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final ConversationStatus status;
  final int connectionId;

  const ConversationModel({
    required this.id,
    required this.partnerName,
    this.partnerAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.status,
    required this.connectionId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: int.tryParse((json['id'] ?? json['Id'])?.toString() ?? '0') ?? 0,
      partnerName: (json['partnerName'] ?? json['PartnerName'] ?? 'Unknown').toString(),
      partnerAvatar: (json['partnerAvatar'] ?? json['PartnerAvatar'])?.toString(),
      lastMessage: (json['lastMessage'] ?? json['LastMessage'])?.toString(),
      lastMessageTime: (json['lastMessageTime'] ?? json['LastMessageTime']) != null 
          ? DateTime.parse(json['lastMessageTime'] ?? json['LastMessageTime']) 
          : null,
      unreadCount: int.tryParse((json['unreadCount'] ?? json['UnreadCount'])?.toString() ?? '0') ?? 0,
      status: _parseStatus((json['status'] ?? json['Status'])?.toString()),
      connectionId: int.tryParse((json['connectionId'] ?? json['ConnectionId'])?.toString() ?? '0') ?? 0,
    );
  }

  static ConversationStatus _parseStatus(String? status) {
    switch (status) {
      case 'Active': return ConversationStatus.Active;
      case 'Archived': return ConversationStatus.Archived;
      case 'Closed': return ConversationStatus.Closed;
      default: return ConversationStatus.Active;
    }
  }
}

class MessageModel {
  final int id;
  final String content;
  final int senderId;
  final DateTime sentAt;
  final bool isRead;
  final bool isMe;

  const MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.sentAt,
    this.isRead = false,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    final senderId = int.tryParse((json['senderId'] ?? json['SenderId'])?.toString() ?? '0') ?? 0;
    return MessageModel(
      id: int.tryParse((json['id'] ?? json['Id'])?.toString() ?? '0') ?? 0,
      content: (json['content'] ?? json['Content'])?.toString() ?? '',
      senderId: senderId,
      sentAt: (json['sentAt'] ?? json['SentAt']) != null 
          ? DateTime.parse(json['sentAt'] ?? json['SentAt']) 
          : DateTime.now(),
      isRead: (json['isRead'] ?? json['IsRead']) == true,
      isMe: senderId == currentUserId,
    );
  }

  // Legacy compatibility
  String get text => content;
  DateTime get timestamp => sentAt;
}


// Legacy ChatModel for UI compatibility if needed
class ChatModel {
  final String id;
  final String investorId;
  final String investorName;
  final String? organizationName;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;

  const ChatModel({
    required this.id,
    required this.investorId,
    required this.investorName,
    this.organizationName,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
  });

  ChatModel copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatModel(
      id: id,
      investorId: investorId,
      investorName: investorName,
      organizationName: organizationName,
      avatarUrl: avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

