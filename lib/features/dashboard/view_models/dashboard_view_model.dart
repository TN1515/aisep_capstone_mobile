import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/dashboard/models/dashboard_stats_model.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardStats? _stats;
  String _userName = 'Nguyễn Alpha';
  String _startupName = 'BioCore AI';

  DashboardStats? get stats => _stats;
  String get userName => _userName;
  String get startupName => _startupName;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  Future<void> fetchDashboardData() async {
    setLoading(true);
    try {
      // Mock API call - (Removing artificial delay for speed)
      
      _stats = DashboardStats(
        profileCompletion: 0.65,
        kycStatus: DashboardKycStatus.pending,
        aiEvaluationScore: 82,
        documentCount: 12,
        connectionCount: 5,
        advisorCount: 3,
        tasks: [
          DashboardTask(
            title: 'Hồ sơ Startup',
            description: 'Thông tin đội ngũ & sản phẩm',
            actionText: 'Hoàn thiện',
            onAction: () => debugPrint('Navigate to Profile'),
            date: DateTime(2026, 4, 1),
            icon: Icons.business_center_rounded,
            category: 'Hồ sơ',
            progress: 0.65,
          ),
          DashboardTask(
            title: 'Xác thực KYC',
            description: 'Xác thực định danh doanh nghiệp',
            actionText: 'Tiếp tục',
            onAction: () => debugPrint('Navigate to KYC'),
            date: DateTime(2026, 4, 2),
            icon: Icons.verified_user_rounded,
            category: 'Pháp lý',
            progress: 0.46,
          ),
          DashboardTask(
            title: 'Đánh giá AI',
            description: 'Báo cáo phân tích chuyên sâu',
            actionText: 'Xem chi tiết',
            onAction: () => debugPrint('Navigate to AI Evaluation'),
            date: DateTime(2026, 4, 3),
            icon: Icons.analytics_rounded, // Analytics for AI score
            category: 'AI Score',
            progress: 0.82,
          ),
          DashboardTask(
            title: 'Advisor & Tư vấn',
            description: 'Kết nối mạng lưới hỗ trợ',
            actionText: 'Khám phá',
            onAction: () => debugPrint('Navigate to Consulting'),
            date: DateTime(2026, 4, 3),
            icon: Icons.chat_bubble_outline_rounded,
            category: 'Tư vấn',
            progress: 0.24,
          ),
        ],
        activities: [
          RecentActivity(
            description: 'Tài liệu "Product_Roadmap_2026.pdf" đã được xác thực blockchain.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            type: 'document',
          ),
          RecentActivity(
            description: 'Bạn có yêu cầu kết nối mới từ Investor "Alpha Capital".',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            type: 'connection',
          ),
          RecentActivity(
            description: 'Đánh giá AI hoàn tất. Điểm số của bạn là 82/100.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: 'ai',
          ),
        ],
      );
    } catch (e) {
      setError('Không thể tải dữ liệu Dashboard. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  }
}
