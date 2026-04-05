import 'package:flutter/material.dart';

enum MembershipTier { free, pro, fundraising }

class MembershipFeature {
  final String name;
  final dynamic value; // bool for check/cross, String for counts/unlimited
  final bool isHighlight;

  const MembershipFeature({
    required this.name,
    required this.value,
    this.isHighlight = false,
  });
}

class MembershipPlan {
  final MembershipTier tier;
  final String name;
  final String tagline;
  final String price; // e.g., "0", "499.000", "1.999.000"
  final String period; // e.g., "tháng"
  final List<MembershipFeature> features;
  final bool isPopular;
  final Color? accentColor;

  const MembershipPlan({
    required this.tier,
    required this.name,
    required this.tagline,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.accentColor,
  });

  static List<MembershipPlan> get mockPlans => [
    const MembershipPlan(
      tier: MembershipTier.free,
      name: 'Free',
      tagline: 'Dành cho Startup mới bắt đầu',
      price: '0',
      period: 'mãi mãi',
      features: [
        MembershipFeature(name: 'Tạo hồ sơ Startup', value: true),
        MembershipFeature(name: 'Tìm kiếm Investor', value: true),
        MembershipFeature(name: 'Tìm kiếm Advisor', value: true),
        MembershipFeature(name: 'Đặt lịch tư vấn', value: true),
        MembershipFeature(name: 'Yêu cầu kết nối Investor', value: '3'),
        MembershipFeature(name: 'Yêu cầu tư vấn Advisor', value: '2'),
        MembershipFeature(name: 'Investor Matching', value: false),
        MembershipFeature(name: 'Phân tích Startup', value: false),
        MembershipFeature(name: 'Lịch sử AI Score', value: false),
        MembershipFeature(name: 'Xác thực Blockchain', value: false),
        MembershipFeature(name: 'Xem Investor quan tâm', value: false),
        MembershipFeature(name: 'Startup nổi bật', value: false),
        MembershipFeature(name: 'Hỗ trợ ưu tiên', value: false),
      ],
    ),
    const MembershipPlan(
      tier: MembershipTier.pro,
      name: 'Pro',
      tagline: 'Tăng tốc kết nối & dữ liệu',
      price: '499.000',
      period: 'tháng',
      isPopular: true,
      accentColor: Color(0xFFEAB308), // Gold
      features: [
        MembershipFeature(name: 'Tạo hồ sơ Startup', value: true),
        MembershipFeature(name: 'Tìm kiếm Investor', value: true),
        MembershipFeature(name: 'Tìm kiếm Advisor', value: true),
        MembershipFeature(name: 'Đặt lịch tư vấn', value: true),
        MembershipFeature(name: 'Yêu cầu kết nối Investor', value: '15', isHighlight: true),
        MembershipFeature(name: 'Yêu cầu tư vấn Advisor', value: '10', isHighlight: true),
        MembershipFeature(name: 'Investor Matching', value: true, isHighlight: true),
        MembershipFeature(name: 'Phân tích Startup', value: true, isHighlight: true),
        MembershipFeature(name: 'Lịch sử AI Score', value: true),
        MembershipFeature(name: 'Xác thực Blockchain', value: true),
        MembershipFeature(name: 'Xem Investor quan tâm', value: false),
        MembershipFeature(name: 'Startup nổi bật', value: false),
        MembershipFeature(name: 'Hỗ trợ ưu tiên', value: false),
      ],
    ),
    const MembershipPlan(
      tier: MembershipTier.fundraising,
      name: 'Fundraising',
      tagline: 'Giải pháp gọi vốn toàn diện',
      price: '1.490.000',
      period: 'tháng',
      accentColor: Color(0xFF6366F1), // Premium Indigo/Violet
      features: [
        MembershipFeature(name: 'Tạo hồ sơ Startup', value: true),
        MembershipFeature(name: 'Tìm kiếm Investor', value: true),
        MembershipFeature(name: 'Tìm kiếm Advisor', value: true),
        MembershipFeature(name: 'Đặt lịch tư vấn', value: true),
        MembershipFeature(name: 'Yêu cầu kết nối Investor', value: 'Vô hạn', isHighlight: true),
        MembershipFeature(name: 'Yêu cầu tư vấn Advisor', value: 'Vô hạn', isHighlight: true),
        MembershipFeature(name: 'Investor Matching', value: true),
        MembershipFeature(name: 'Phân tích Startup', value: true),
        MembershipFeature(name: 'Lịch sử AI Score', value: true),
        MembershipFeature(name: 'Xác thực Blockchain', value: true),
        MembershipFeature(name: 'Xem Investor quan tâm', value: true, isHighlight: true),
        MembershipFeature(name: 'Startup nổi bật', value: true, isHighlight: true),
        MembershipFeature(name: 'Hỗ trợ ưu tiên', value: true, isHighlight: true),
      ],
    ),
  ];
}
