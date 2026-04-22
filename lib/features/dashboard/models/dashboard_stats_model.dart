import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum DashboardKycStatus { none, pending, verified, rejected }

class DashboardStats {
  final double profileCompletion;
  final DashboardKycStatus kycStatus;
  final int? aiEvaluationScore;
  final int documentCount;
  final int connectionCount;
  final int advisorCount;
  final List<DashboardTask> tasks;
  final List<RecentActivity> activities;

  DashboardStats({
    required this.profileCompletion,
    required this.kycStatus,
    this.aiEvaluationScore,
    required this.documentCount,
    required this.connectionCount,
    required this.advisorCount,
    required this.tasks,
    required this.activities,
  });

  String get kycStatusText {
    switch (kycStatus) {
      case DashboardKycStatus.none: return 'Chưa xác thực';
      case DashboardKycStatus.pending: return 'Đang chờ duyệt';
      case DashboardKycStatus.verified: return 'Đã xác thực';
      case DashboardKycStatus.rejected: return 'Cần bổ sung';
    }
  }
}

class DashboardTask {
  final String title;
  final String description;
  final String actionText;
  final VoidCallback? onAction;
  final DateTime? _date;
  final IconData? _icon;
  final String? _category;
  final double? _progress;
  final String? _unit;

  DateTime get date => _date ?? DateTime.now();
  IconData get icon => _icon ?? Icons.folder_open_rounded;
  String get category => _category ?? 'Project';
  double get progress => _progress ?? 0.0;
  String get unit => _unit ?? '%';

  DashboardTask({
    required this.title,
    required this.description,
    required this.actionText,
    this.onAction,
    DateTime? date,
    IconData? icon,
    String? category,
    double? progress,
    String? unit,
  })  : _date = date,
        _icon = icon,
        _category = category,
        _progress = progress,
        _unit = unit;
}

class RecentActivity {
  final String description;
  final DateTime timestamp;
  final String type;

  RecentActivity({
    required this.description,
    required this.timestamp,
    required this.type,
  });
}
