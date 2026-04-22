import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/utils/datetime_utils.dart';

// Trạng thái kết nối (ConnectionStatus từ Backend)
enum ConnectionStatus {
  requested, // 0 - Chờ xử lý
  accepted,  // 1 - Đã kết nối thành công
  rejected,  // 2 - Đã từ chối
  withdrawn, // 3 - Đã thu hồi (bên gửi rút)
  closed,    // 5 - Đã đóng kết nối
  
  // Legacy aliases
  pending,
  received,
  active,
  cancelled,
  expired,
}

enum ConnectionRole {
  investor,
  advisor,
}

extension ConnectionStatusExtension on ConnectionStatus {
  int get value {
    switch (this) {
      case ConnectionStatus.requested: return 0;
      case ConnectionStatus.accepted: return 1;
      case ConnectionStatus.rejected: return 2;
      case ConnectionStatus.withdrawn: return 3;
      case ConnectionStatus.closed: return 5;
      default: return 0;
    }
  }

  static ConnectionStatus fromString(String? val) {
    if (val == null) return ConnectionStatus.requested;
    final normalized = val.toLowerCase();
    switch (normalized) {
      case '0':
      case 'requested': 
      case 'pending':
        return ConnectionStatus.requested;
      case '1':
      case 'accepted': 
      case 'active':
      case 'connected':
      case 'approved':
        return ConnectionStatus.accepted;
      case '2':
      case 'rejected': 
      case 'declined':
      case 'cancelled':
        return ConnectionStatus.rejected;
      case '3':
      case 'withdrawn': return ConnectionStatus.withdrawn;
      case '5':
      case 'closed': 
      case 'expired':
        return ConnectionStatus.closed;
      default: return ConnectionStatus.requested;
    }
  }

  static ConnectionStatus fromInt(int val) {
    switch (val) {
      case 0: return ConnectionStatus.requested;
      case 1: return ConnectionStatus.accepted;
      case 2: return ConnectionStatus.rejected;
      case 3: return ConnectionStatus.withdrawn;
      case 5: return ConnectionStatus.closed;
      default: return ConnectionStatus.requested;
    }
  }

  String get label {
    switch (this) {
      case ConnectionStatus.requested:
      case ConnectionStatus.pending:
      case ConnectionStatus.received:
        return 'Đang chờ';
      case ConnectionStatus.accepted:
      case ConnectionStatus.active:
        return 'Đã kết nối';
      case ConnectionStatus.rejected: return 'Đã từ chối';
      case ConnectionStatus.withdrawn:
      case ConnectionStatus.cancelled:
        return 'Đã thu hồi';
      case ConnectionStatus.closed:
      case ConnectionStatus.expired:
        return 'Đã đóng';
      default: return 'Đang chờ';
    }
  }

  Color get color {
    switch (this) {
      case ConnectionStatus.requested:
      case ConnectionStatus.pending:
      case ConnectionStatus.received:
        return Colors.orange;
      case ConnectionStatus.accepted:
      case ConnectionStatus.active:
        return Colors.green;
      case ConnectionStatus.rejected: return Colors.red;
      case ConnectionStatus.withdrawn:
      case ConnectionStatus.cancelled:
        return Colors.grey;
      case ConnectionStatus.closed:
      case ConnectionStatus.expired:
        return Colors.brown;
      default: return Colors.orange;
    }
  }
}

class ConnectionModel {
  final int id;
  final int investorId;
  final String investorName;
  final String? investorOrganization;
  final String? investorAvatarUrl;
  final String? message; // Tin nhắn đính kèm
  final ConnectionStatus status;
  final ConnectionRole role;
  final bool isVerified;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? conversationId; // New field to check if chat exists

  final String? investorType; // e.g. Individual Angel, Venture Capital
  final bool isReceived; // To distinguish incoming vs outgoing in the UI

  ConnectionModel({
    required this.id,
    required this.investorId,
    required this.investorName,
    this.investorOrganization,
    this.investorAvatarUrl,
    this.message,
    required this.status,
    this.role = ConnectionRole.investor,
    this.isVerified = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isReceived = false,
    this.conversationId,
    this.investorType,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    // Highly resilient parsing to support various backend DTO naming conventions (PascalCase, camelCase)
    final idVal = json['id'] ?? json['Id'] ?? json['connectionID'] ?? json['ConnectionID'];
    final statusVal = json['status'] ?? json['Status'] ?? json['connectionStatus'] ?? json['ConnectionStatus'] ?? json['requestStatus'] ?? json['RequestStatus'];
    final msgVal = json['message'] ?? json['Message'] ?? json['personalizedMessage'] ?? json['PersonalizedMessage'] ?? json['note'] ?? json['Note'];
    // Nested parsing support: check if investor info is wrapped in "investor", "partner", "user", "advisor"
    final partnerData = json['investor'] ?? json['Investor'] ?? json['partner'] ?? json['Partner'] ?? json['user'] ?? json['User'] ?? json['advisor'] ?? json['Advisor'];
    final Map<String, dynamic> targetJson = (partnerData is Map<String, dynamic>) ? partnerData : json;

    final createdVal = json['createdAt'] ?? json['CreatedAt'] ?? json['requestedAt'] ?? json['RequestedAt'] ?? json['requested_at'] ?? json['requestAt'] ?? json['createdDate'] ?? json['CreatedDate'] ?? json['created_at'] ??
                       targetJson['createdAt'] ?? targetJson['CreatedAt'] ?? targetJson['requestedAt'] ?? targetJson['RequestedAt'] ?? targetJson['requested_at'] ?? targetJson['requestAt'];
    final updatedVal = json['updatedAt'] ?? json['UpdatedAt'] ?? json['respondedAt'] ?? json['RespondedAt'] ?? json['responded_at'] ?? json['respondedAt'] ?? json['modifiedDate'] ?? json['ModifiedDate'] ?? json['updated_at'] ?? json['modified_at'] ??
                       targetJson['updatedAt'] ?? targetJson['UpdatedAt'] ?? targetJson['respondedAt'] ?? targetJson['RespondedAt'] ?? targetJson['responded_at'] ?? targetJson['respondedAt'];

    // Super-resilient avatar key search
    final avatarUrlVal = json['avatarUrl'] ?? json['AvatarUrl'] ?? json['AvatarURL'] ?? 
                        json['profilePhotoURL'] ?? json['ProfilePhotoURL'] ?? json['ProfilePhotoUrl'] ??
                        json['investorPhotoURL'] ?? json['InvestorPhotoURL'] ??
                        json['profileImage'] ?? json['ProfileImage'] ?? 
                        json['imageUrl'] ?? json['ImageUrl'] ?? 
                        json['picture'] ?? json['Picture'] ??
                        targetJson['avatarUrl'] ?? targetJson['AvatarUrl'] ?? targetJson['AvatarURL'] ??
                        targetJson['profilePhotoURL'] ?? targetJson['ProfilePhotoURL'] ?? targetJson['ProfilePhotoUrl'] ??
                        targetJson['investorPhotoURL'] ?? targetJson['InvestorPhotoURL'] ??
                        targetJson['investorAvatarUrl'] ?? targetJson['InvestorAvatarUrl'] ??
                        targetJson['profileImage'] ?? targetJson['ProfileImage'] ??
                        targetJson['imageUrl'] ?? targetJson['ImageUrl'] ??
                        targetJson['profilePicture'] ?? targetJson['ProfilePicture'] ??
                        targetJson['logo'] ?? targetJson['Logo'] ??
                        targetJson['picture'] ?? targetJson['Picture'];

    return ConnectionModel(
      id: int.tryParse(idVal?.toString() ?? '0') ?? 0,
      investorId: int.tryParse((targetJson['investorId'] ?? targetJson['InvestorId'] ?? targetJson['investorID'] ?? targetJson['InvestorID'] ?? targetJson['partnerId'] ?? targetJson['PartnerId'] ?? targetJson['id'] ?? targetJson['Id'])?.toString() ?? '0') ?? 0,
      investorName: (targetJson['fullName'] ?? targetJson['FullName'] ?? targetJson['investorName'] ?? targetJson['InvestorName'] ?? targetJson['name'] ?? targetJson['Name'] ?? targetJson['partnerName'] ?? targetJson['PartnerName'] ?? 'Unknown').toString(),
      investorOrganization: (targetJson['firmName'] ?? targetJson['FirmName'] ?? targetJson['investorOrganization'] ?? targetJson['InvestorOrganization'] ?? targetJson['organization'] ?? targetJson['Organization'])?.toString(),
      investorAvatarUrl: avatarUrlVal?.toString(),
      message: msgVal?.toString(),
      status: ConnectionStatusExtension.fromString(statusVal?.toString()),
      role: (json['role'] ?? json['Role'] ?? targetJson['role'] ?? targetJson['Role'])?.toString() == 'Advisor' ? ConnectionRole.advisor : ConnectionRole.investor,
      isVerified: (targetJson['isVerified'] ?? targetJson['IsVerified'] ?? targetJson['profileStatus'] == 'Approved' ?? targetJson['ProfileStatus'] == 'Approved') == true,
      tags: (targetJson['tags'] ?? targetJson['Tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTimeUtils.parseRaw(createdVal),
      updatedAt: DateTimeUtils.parseRaw(updatedVal),
      conversationId: (json['conversationId'] ?? json['ConversationId']) != null ? int.tryParse((json['conversationId'] ?? json['ConversationId']).toString()) : null,
      investorType: (json['investorType'] ?? json['InvestorType'] ?? json['investor_type'] ?? json['investorTypeName'] ?? json['investor_type_name'] ?? json['type'] ?? json['Type'] ?? json['title'] ??
                     targetJson['investorType'] ?? targetJson['InvestorType'] ?? targetJson['investor_type'] ?? targetJson['investorTypeName'] ?? targetJson['investor_type_name'] ?? targetJson['type'] ?? targetJson['Type'] ?? targetJson['title'])?.toString(),
    );
  }

  ConnectionModel copyWith({ConnectionStatus? status, int? conversationId, bool? isReceived, String? investorType}) {
    return ConnectionModel(
      id: id,
      investorId: investorId,
      investorName: investorName,
      investorOrganization: investorOrganization,
      investorAvatarUrl: investorAvatarUrl,
      message: message,
      status: status ?? this.status,
      role: role,
      isVerified: isVerified,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isReceived: isReceived ?? this.isReceived,
      conversationId: conversationId ?? this.conversationId,
      investorType: investorType ?? this.investorType,
    );
  }

  // --- Legacy Compatibility ---
  String get name => investorName;
  String? get organization => investorOrganization;
  String get position {
    if (investorType == null || investorType!.isEmpty) {
      return role == ConnectionRole.advisor ? 'Cố vấn' : 'Nhà đầu tư';
    }
    
    // Format: INDIVIDUAL_ANGEL -> Individual Angel
    return investorType!
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
  DateTime get lastUpdated => updatedAt;
  String? get bio => message;
  double get matchScore => 0.0; // Use real data or default to 0 to trigger hidden indicator
}
