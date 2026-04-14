import 'package:flutter/material.dart';

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
        return ConnectionStatus.accepted;
      case '2':
      case 'rejected': 
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
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    // Highly resilient parsing to support various backend DTO naming conventions (PascalCase, camelCase)
    final idVal = json['id'] ?? json['Id'] ?? json['connectionID'] ?? json['ConnectionID'];
    final statusVal = json['status'] ?? json['Status'] ?? json['connectionStatus'] ?? json['ConnectionStatus'];
    final msgVal = json['message'] ?? json['Message'] ?? json['personalizedMessage'] ?? json['PersonalizedMessage'];
    final createdVal = json['createdAt'] ?? json['CreatedAt'] ?? json['requestedAt'] ?? json['RequestedAt'];
    final updatedVal = json['updatedAt'] ?? json['UpdatedAt'] ?? json['respondedAt'] ?? json['RespondedAt'];

    return ConnectionModel(
      id: int.tryParse(idVal?.toString() ?? '0') ?? 0,
      investorId: int.tryParse((json['investorId'] ?? json['InvestorId'] ?? json['investorID'] ?? json['InvestorID'])?.toString() ?? '0') ?? 0,
      investorName: (json['fullName'] ?? json['FullName'] ?? json['investorName'] ?? json['InvestorName'] ?? json['name'] ?? json['Name'] ?? 'Unknown').toString(),
      investorOrganization: (json['firmName'] ?? json['FirmName'] ?? json['investorOrganization'] ?? json['InvestorOrganization'] ?? json['organization'] ?? json['Organization'])?.toString(),
      investorAvatarUrl: (json['avatarUrl'] ?? json['AvatarUrl'] ?? json['investorAvatarUrl'] ?? json['InvestorAvatarUrl'] ?? json['AvatarURL'])?.toString(),
      message: msgVal?.toString(),
      status: ConnectionStatusExtension.fromString(statusVal?.toString()),
      role: (json['role'] ?? json['Role'])?.toString() == 'Advisor' ? ConnectionRole.advisor : ConnectionRole.investor,
      isVerified: (json['isVerified'] ?? json['IsVerified']) == true,
      tags: (json['tags'] ?? json['Tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: createdVal != null ? DateTime.parse(createdVal.toString()) : DateTime.now(),
      updatedAt: updatedVal != null ? DateTime.parse(updatedVal.toString()) : DateTime.now(),
      conversationId: (json['conversationId'] ?? json['ConversationId']) != null ? int.tryParse((json['conversationId'] ?? json['ConversationId']).toString()) : null,
    );
  }

  ConnectionModel copyWith({ConnectionStatus? status, int? conversationId, bool? isReceived}) {
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
    );
  }

  // --- Legacy Compatibility ---
  String get name => investorName;
  String? get organization => investorOrganization;
  String get position => 'Nhà đầu tư';
  DateTime get lastUpdated => updatedAt;
  String? get bio => message;
  double get matchScore => 0.95;
}
