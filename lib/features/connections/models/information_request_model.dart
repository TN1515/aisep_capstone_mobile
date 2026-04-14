import 'package:flutter/material.dart';

// Trạng thái yêu cầu thông tin (RequestStatus từ Backend)
enum InfoRequestStatus {
  pending,  // 0 - Chờ Startup phản hồi
  approved, // 1 - Đã cung cấp thông tin
  rejected, // 2 - Từ chối cung cấp
}

extension InfoRequestStatusExtension on InfoRequestStatus {
  int get value {
    switch (this) {
      case InfoRequestStatus.pending: return 0;
      case InfoRequestStatus.approved: return 1;
      case InfoRequestStatus.rejected: return 2;
    }
  }

  static InfoRequestStatus fromInt(int val) {
    switch (val) {
      case 0: return InfoRequestStatus.pending;
      case 1: return InfoRequestStatus.approved;
      case 2: return InfoRequestStatus.rejected;
      default: return InfoRequestStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case InfoRequestStatus.pending: return 'Đang chờ';
      case InfoRequestStatus.approved: return 'Đã hoàn thành';
      case InfoRequestStatus.rejected: return 'Đã từ chối';
    }
  }

  Color get color {
    switch (this) {
      case InfoRequestStatus.pending: return Colors.orange;
      case InfoRequestStatus.approved: return Colors.green;
      case InfoRequestStatus.rejected: return Colors.red;
    }
  }
}

class InfoRequestModel {
  final int id;
  final int connectionId;
  final String title;
  final String? description;
  final InfoRequestStatus status;
  final DateTime createdAt;
  final String? fulfillmentNotes;
  final List<String> attachmentUrls;

  InfoRequestModel({
    required this.id,
    required this.connectionId,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    this.fulfillmentNotes,
    this.attachmentUrls = const [],
  });

  factory InfoRequestModel.fromJson(Map<String, dynamic> json) {
    return InfoRequestModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      connectionId: int.tryParse(json['connectionId']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Untitled Request',
      description: json['description']?.toString(),
      status: InfoRequestStatusExtension.fromInt(int.tryParse(json['status']?.toString() ?? '0') ?? 0),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      fulfillmentNotes: json['fulfillmentNotes']?.toString(),
      attachmentUrls: (json['attachmentUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
