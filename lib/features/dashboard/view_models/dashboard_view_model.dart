import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/dashboard/models/dashboard_stats_model.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardStats? _stats;
  String _userName = '';
  String _startupName = '';

  DashboardStats? get stats => _stats;
  String get userName => _userName;
  String get startupName => _startupName;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  Future<void> fetchDashboardData({
    String? userName, 
    String? startupName,
    int? aiScore,
    int? advisorCount,
    double? advisorProgress,
    double? kycProgress,
    double? profileProgress,
  }) async {
    if (userName != null) _userName = userName;
    if (startupName != null) _startupName = startupName;
    setLoading(true);
    try {
      _stats = DashboardStats(
        profileCompletion: profileProgress ?? 0.0,
        kycStatus: DashboardKycStatus.none,
        aiEvaluationScore: aiScore,
        documentCount: 0,
        connectionCount: 0,
        advisorCount: advisorCount ?? 0,
        tasks: [
          DashboardTask(
            title: 'Xác thực',
            description: 'Định danh doanh nghiệp',
            actionText: 'Tiếp tục',
            onAction: () => debugPrint('Navigate to KYC'),
            date: DateTime.now(),
            icon: Icons.verified_user_rounded,
            category: 'Pháp lý',
            progress: kycProgress ?? 0.0,
            unit: '%',
          ),
          DashboardTask(
            title: 'Đánh giá AI',
            description: 'Phân tích chuyên sâu',
            actionText: 'Xem chi tiết',
            onAction: () => debugPrint('Navigate to AI Evaluation'),
            date: DateTime.now(),
            icon: Icons.analytics_rounded,
            category: 'AI Score',
            progress: aiScore != null ? (aiScore.toDouble() / 100.0) : 0.0,
            unit: 'điểm',
          ),
          DashboardTask(
            title: 'Kết nối',
            description: 'Nhà đầu tư',
            actionText: 'Khám phá',
            onAction: () => debugPrint('Navigate to Connections'),
            date: DateTime.now(),
            icon: Icons.handshake_rounded,
            category: 'Kết nối',
            progress: 0.1, // Placeholder progress
            unit: 'lượt',
          ),
          DashboardTask(
            title: 'Liên hệ',
            description: 'Advisor & Tư vấn',
            actionText: 'Khám phá',
            onAction: () => debugPrint('Navigate to Consulting'),
            date: DateTime.now(),
            icon: Icons.chat_bubble_outline_rounded,
            category: 'Tư vấn',
            progress: advisorProgress ?? 0.0,
            unit: 'lượt',
          ),
        ],
        activities: [],
      );
    } catch (e) {
      setError('Không thể tải dữ liệu Dashboard. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  }
}
