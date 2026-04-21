import 'package:flutter/foundation.dart';
import 'package:aisep_capstone_mobile/core/utils/datetime_utils.dart';

enum ConversationStatus {
  Active,
  Archived,
  Closed
}

class ConversationModel {
  final int id;
  final String partnerName;
  final String? partnerAvatar;
  final String partnerRole; // Added for UI badge
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final ConversationStatus status;
  final int connectionId;
  final int? mentorshipId;
  final int lastMessageSenderId;

  const ConversationModel({
    required this.id,
    required this.partnerName,
    this.partnerAvatar,
    this.partnerRole = '', // Neutral default
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.status,
    required this.connectionId,
    this.mentorshipId,
    this.lastMessageSenderId = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // 1. Participant Details mapping (Partner/Participant/Investor/Advisor)
    final partnerData = json['partner'] ?? json['Partner'] ?? 
                        json['investor'] ?? json['Investor'] ?? 
                        json['startup'] ?? json['Startup'] ?? 
                        json['participant'] ?? json['Participant'];

    // 2. Resolve Partner Name
    String partnerNameVal = 'Hội thoại';
    if (partnerData is Map) {
      partnerNameVal = (partnerData['fullName'] ?? partnerData['FullName'] ?? 
                        partnerData['name'] ?? partnerData['Name'] ?? 
                        partnerData['investorName'] ?? partnerData['InvestorName'] ??
                        partnerData['companyName'] ?? partnerData['CompanyName'] ??
                        partnerData['userName'] ?? partnerData['UserName'])?.toString() ?? 'Unknown';
    } else {
      partnerNameVal = (json['partnerName'] ?? json['PartnerName'] ?? 
                        json['participantName'] ?? json['ParticipantName'] ??
                        json['title'] ?? json['Title'] ??
                        json['fullName'] ?? json['FullName'] ?? 
                        json['userName'] ?? json['UserName'] ??
                        json['investorName'] ?? json['InvestorName'] ?? 
                        json['name'] ?? json['Name'] ?? 'Unknown').toString();
    }

    // 3. Resolve Partner Avatar
    String? partnerAvatarVal;
    if (partnerData is Map) {
       partnerAvatarVal = (partnerData['avatarUrl'] ?? partnerData['AvatarUrl'] ?? 
                           partnerData['profilePhotoURL'] ?? partnerData['ProfilePhotoURL'] ??
                           partnerData['partnerAvatar'] ?? partnerData['PartnerAvatar'])?.toString();
    } else {
       partnerAvatarVal = (json['partnerAvatar'] ?? json['PartnerAvatar'] ?? 
                           json['participantAvatarUrl'] ?? json['ParticipantAvatarUrl'] ??
                           json['avatarUrl'] ?? json['AvatarUrl'] ?? 
                           json['avatarURL'] ?? json['AvatarURL'])?.toString();
    }

    // 4. Resolve Partner Role
    String roleVal = (json['partnerRole'] ?? json['ParticipantRole'] ?? json['PartnerRole'] ?? '').toString();
    final mId = int.tryParse((json['mentorshipId'] ?? json['MentorshipId'])?.toString() ?? '') ?? 0;
    final cId = int.tryParse((json['connectionId'] ?? json['ConnectionId'])?.toString() ?? '0') ?? 0;

    if (roleVal.isEmpty) {
      if (mId > 0) roleVal = 'Advisor';
      else if (cId > 0) roleVal = 'Investor';
    }

    // Unified UI role naming
    String normalizedRole = 'NHÀ ĐẦU TƯ';
    if (roleVal.toLowerCase().contains('advisor') || roleVal.toLowerCase().contains('cố vấn')) {
      normalizedRole = 'CỐ VẤN';
    } else if (roleVal.toLowerCase().contains('startup')) {
      normalizedRole = 'STARTUP';
    }

    return ConversationModel(
      id: int.tryParse((json['id'] ?? json['Id'] ?? json['conversationId'] ?? json['ConversationId'])?.toString() ?? '0') ?? 0,
      partnerName: partnerNameVal,
      partnerAvatar: partnerAvatarVal,
      partnerRole: normalizedRole,
      lastMessage: (json['lastMessagePreview'] ?? json['LastMessagePreview'] ?? 
                    json['lastMessage'] ?? json['LastMessage'] ?? 
                    json['latestMessage'] ?? json['LatestMessage'] ??
                    json['lastMessageContent'] ?? json['LastMessageContent'])?.toString(),
      lastMessageTime: (json['lastMessageAt'] ?? json['LastMessageAt'] ?? 
                        json['lastMessageTime'] ?? json['LastMessageTime'] ?? 
                        json['sentAt'] ?? json['SentAt'] ??
                        json['createdAt'] ?? json['CreatedAt']) != null 
          ? DateTimeUtils.parseApiDate(json['lastMessageAt'] ?? json['LastMessageAt'] ?? 
                               json['lastMessageTime'] ?? json['LastMessageTime'] ?? 
                               json['sentAt'] ?? json['SentAt'] ??
                               json['createdAt'] ?? json['CreatedAt'])
          : null,
      unreadCount: int.tryParse((json['unreadCount'] ?? json['UnreadCount'])?.toString() ?? '0') ?? 0,
      status: _parseStatus((json['status'] ?? json['Status'])?.toString()),
      connectionId: cId,
      mentorshipId: mId,
      lastMessageSenderId: int.tryParse((json['lastMessageSenderId'] ?? json['LastMessageSenderId'])?.toString() ?? '0') ?? 0,
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
  final int? conversationId;
  final String content;
  final int senderId;
  final DateTime sentAt;
  final bool isRead;
  final bool isMine;

  const MessageModel({
    required this.id,
    this.conversationId,
    required this.content,
    required this.senderId,
    required this.sentAt,
    this.isRead = false,
    required this.isMine,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    // Resilient sender identify
    final senderId = int.tryParse((json['senderId'] ?? json['SenderId'] ?? json['senderID'] ?? json['SenderID'] ?? json['userID'] ?? json['UserID'] ?? json['senderUserId'] ?? json['SenderUserId'])?.toString() ?? '0') ?? 0;
    
    // Resilient content mapping
    final contentText = (json['content'] ?? json['Content'] ?? json['text'] ?? json['Text'] ?? json['body'] ?? json['Body'] ?? '').toString();
    
    // Resilient timestamp mapping
    final timestampVal = json['sentAt'] ?? json['SentAt'] ?? json['createdAt'] ?? json['CreatedAt'] ?? json['timestamp'] ?? json['Timestamp'] ?? json['date'] ?? json['Date'];
    
    return MessageModel(
      id: int.tryParse((json['messageId'] ?? json['MessageId'] ?? json['id'] ?? json['Id'])?.toString() ?? '0') ?? 0,
      conversationId: int.tryParse((json['conversationId'] ?? json['ConversationId'])?.toString() ?? '0'),
      content: contentText,
      senderId: int.tryParse((json['senderUserId'] ?? json['SenderUserId'] ?? json['senderId'] ?? json['SenderId'])?.toString() ?? '0') ?? 0,
      sentAt: DateTimeUtils.parseApiDate(timestampVal),
      isRead: (json['isRead'] ?? json['IsRead']) == true,
      isMine: (json['isMine'] ?? json['IsMine']) == true || (senderId == currentUserId && currentUserId != 0),
    );
  }

  MessageModel copyWith({
    int? id,
    int? conversationId,
    String? content,
    int? senderId,
    DateTime? sentAt,
    bool? isRead,
    bool? isMine,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      isMine: isMine ?? this.isMine,
    );
  }

  // Legacy compatibility
  String get text => content;
  DateTime get timestamp => sentAt;
  bool get isMe => isMine;
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

